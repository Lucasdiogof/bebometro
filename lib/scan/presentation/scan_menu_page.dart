import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../drinks/domain/drink_category.dart';
import '../../drinks/domain/recipe.dart';
import '../../outings/data/outing_repository.dart';
import '../../outing_drinks/data/outing_drink_repository.dart';
import '../../outing_drinks/domain/outing_drink.dart';
import '../data/image_capture.dart';
import '../data/image_tools.dart';
import '../data/scan_draft_store.dart';
import '../data/text_recognizer.dart';
import '../domain/menu_parser.dart';
import '../domain/ocr_models.dart';
import '../../l10n/l10n.dart';

/// How many menu items were saved into the outing.
class MenuResult {
  const MenuResult(this.saved);

  final int saved;
}

/// Reads one or more menu photos, lets the user fix every item and saves the
/// confirmed ones as drinks of this outing. Nothing is registered as consumed
/// and nothing leaves the outing. Pops a [MenuResult].
class ScanMenuPage extends StatefulWidget {
  const ScanMenuPage({super.key, required this.outingId});

  final String outingId;

  @override
  State<ScanMenuPage> createState() => _ScanMenuPageState();
}

class _ScanMenuPageState extends State<ScanMenuPage> {
  static const _uuid = Uuid();
  final _repo = getIt<OutingDrinkRepository>();
  final _drafts = getIt<ScanDraftStore>();
  final _capture = getIt<ImageCaptureService>();
  final _recognizer = getIt<TextRecognizer>();
  final _pasted = TextEditingController();

  final _photoIds = <String>[];
  final _bytes = <String, Uint8List>{};
  final _ocr = <String, OcrResult>{};
  var _candidates = <MenuCandidate>[];
  var _notes = <String>[];
  late String _session;
  bool _reviewing = false;
  bool _busy = false;
  bool _reading = false;
  bool _saving = false;
  int _runId = 0;
  String? _error;
  Timer? _debounce;

  /// Set once the reading ended (saved or discarded): nothing may write the
  /// draft again, not even a pending delayed save.
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _session = _uuid.v4();
    _restore();
  }

  @override
  void dispose() {
    // Leaving within the debounce window must not lose the last edit.
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
      unawaited(_saveDraft());
    }
    _pasted.dispose();
    super.dispose();
  }

  // ---- Draft -------------------------------------------------------------

  Future<void> _restore() async {
    final draft = _drafts.load(widget.outingId, OutingPhotoKind.menu);
    if (draft != null) {
      final p = draft.payload;
      _session = p['session'] as String? ?? _session;
      _pasted.text = draft.text;
      // Items point to their photo by position. Photos that are gone (web
      // session ended, file removed) are dropped, so the positions of the
      // others are remapped and the items of a lost photo are kept without
      // a photo: the text the person confirmed is never thrown away.
      final remap = <int, int>{};
      for (var i = 0; i < draft.photoIds.length; i++) {
        final id = draft.photoIds[i];
        final b = await _repo.files.read(id);
        if (b != null) {
          remap[i] = _photoIds.length;
          _photoIds.add(id);
          _bytes[id] = b;
        }
      }
      final lostPhotos = draft.photoIds.length - _photoIds.length;
      if (lostPhotos > 0) {
        _error = tr.scanMenuLostPhotos(lostPhotos);
      }
      final ocr = p['ocr'];
      if (ocr is Map) {
        ocr.forEach((k, v) {
          if (_photoIds.contains(k) && v is List) {
            _ocr[k as String] = OcrResult.fromJson(v);
          }
        });
      }
      _candidates = [
        for (final c in (p['candidates'] as List? ?? const []))
          _remapped(
              MenuCandidate.fromJson(Map<String, dynamic>.from(c as Map)),
              remap),
      ];
      _notes = (p['notes'] as List?)?.cast<String>() ?? <String>[];
      _reviewing = p['reviewing'] as bool? ?? false;
      if (mounted) setState(() {});
    }
    if (_photoIds.isEmpty) {
      final lost = await _capture.recoverLost();
      if (lost != null) await _addPhoto(lost);
    }
  }

  MenuCandidate _remapped(MenuCandidate c, Map<int, int> remap) {
    if (c.sourceIndex < 0) return c;
    return c.copyWith(sourceIndex: remap[c.sourceIndex] ?? -1);
  }

  void _saveDraftSoon() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _saveDraft);
  }

  Future<void> _saveDraft() async {
    if (_done) return;
    await _drafts.save(ScanDraft(
        outingId: widget.outingId,
        kind: OutingPhotoKind.menu,
        photoIds: List.of(_photoIds),
        text: _pasted.text,
        payload: _candidates.isEmpty && _photoIds.isEmpty && _pasted.text.isEmpty
            ? const {}
            : {
                'session': _session,
                'reviewing': _reviewing,
                'notes': _notes,
                'ocr': {for (final e in _ocr.entries) e.key: e.value.toJson()},
                'candidates': [for (final c in _candidates) c.toJson()],
              },
      ));
  }

  void _changed(VoidCallback fn) {
    setState(fn);
    _saveDraftSoon();
  }

  // ---- Photos ------------------------------------------------------------

  Future<void> _pick(CaptureSource source) async {
    setState(() => _error = null);
    try {
      final bytes = await _capture.pick(source);
      if (bytes != null) await _addPhoto(bytes);
    } on CaptureException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Future<void> _addPhoto(Uint8List bytes) async {
    final id = _repo.newId();
    try {
      await _repo.files.write(id, bytes);
    } catch (_) {
      if (mounted) {
        setState(() => _error = tr.scanPhotoSaveFailed);
      }
      return;
    }
    if (!mounted) return;
    _changed(() {
      _photoIds.add(id);
      _bytes[id] = bytes;
      _error = null;
    });
    await _saveDraft();
  }

  Future<void> _rotate(String id, int degrees) async {
    final bytes = _bytes[id];
    if (bytes == null || _busy || _reading) return;
    setState(() => _busy = true);
    try {
      final rotated = await rotateImage(bytes, degrees);
      await _repo.files.write(id, rotated);
      if (!mounted) return;
      _changed(() {
        _bytes[id] = rotated;
        _ocr.remove(id); // read this image again
      });
    } catch (_) {
      if (mounted) setState(() => _error = tr.scanRotateFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _removePhoto(String id) async {
    final index = _photoIds.indexOf(id);
    if (index < 0) return;
    await _repo.discardPhoto(id);
    _changed(() {
      _photoIds.removeAt(index);
      _bytes.remove(id);
      _ocr.remove(id);
      // Items read from this photo go with it; later photos shift down.
      _candidates = [
        for (final c in _candidates)
          if (c.sourceIndex != index)
            c.sourceIndex > index
                ? c.copyWith(sourceIndex: c.sourceIndex - 1)
                : c,
      ];
    });
  }

  // ---- Reading -----------------------------------------------------------

  Future<void> _read() async {
    if (_reading) return;
    final run = ++_runId;
    setState(() {
      _reading = true;
      _error = null;
    });
    try {
      final pending = [for (final id in _photoIds) if (!_ocr.containsKey(id)) id];
      for (final id in pending) {
        final path = await _repo.files.pathOf(id);
        if (path == null) continue;
        final result = await _recognizer.recognizeFile(path);
        if (run != _runId || !mounted) return; // cancelled
        _ocr[id] = result;
        _merge(_photoIds.indexOf(id), id, result);
      }
      if (_candidates.isEmpty) {
        _error = tr.scanMenuNoItemsRead;
      } else {
        _reviewing = true;
      }
    } on OcrFailure catch (e) {
      if (run == _runId) _error = e.message;
    } finally {
      if (run == _runId && mounted) {
        setState(() => _reading = false);
        _saveDraftSoon();
      }
    }
  }

  void _cancelReading() {
    _runId++;
    setState(() => _reading = false);
  }

  /// Items read from [index] replace the older ones from the same photo; items
  /// already present (same name, size and price) are flagged, never doubled.
  void _merge(int index, String idPrefix, OcrResult result) {
    final parsed = parseMenu(result, sourceIndex: index, idPrefix: idPrefix);
    final others = [for (final c in _candidates) if (c.sourceIndex != index) c];
    final marked = markDuplicates(others, parsed.candidates);
    _candidates = [...others, ...marked];
    _notes = {..._notes, ...parsed.notes}.toList();
  }

  void _interpretPasted() {
    final text = _pasted.text.trim();
    if (text.isEmpty) return;
    final parsed = parseMenu(OcrResult.fromText(text),
        sourceIndex: -1, idPrefix: 'text');
    final others = [for (final c in _candidates) if (c.sourceIndex != -1) c];
    _changed(() {
      _candidates = [...others, ...markDuplicates(others, parsed.candidates)];
      _notes = {..._notes, ...parsed.notes}.toList();
      _reviewing = true;
      _error = _candidates.isEmpty ? tr.scanMenuNoItems : null;
    });
  }

  // ---- Items -------------------------------------------------------------

  void _update(MenuCandidate old, MenuCandidate next) => _changed(() {
        _candidates = [for (final c in _candidates) c.id == old.id ? next : c];
      });

  Future<void> _edit(MenuCandidate c) async {
    final edited = await showModalBottomSheet<MenuCandidate>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _CandidateEditor(candidate: c),
    );
    if (edited != null) _update(c, edited);
  }

  Future<void> _addManual() async {
    final blank = MenuCandidate(
      id: 'm:${_uuid.v4()}',
      name: '',
      sourceIndex: -1,
    );
    final edited = await showModalBottomSheet<MenuCandidate>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _CandidateEditor(candidate: blank, isNew: true),
    );
    if (edited != null) {
      _changed(() {
        _candidates = [..._candidates, edited];
        _reviewing = true;
      });
    }
  }

  List<MenuCandidate> get _kept =>
      [for (final c in _candidates) if (!c.discarded) c];

  Future<void> _confirm() async {
    if (_saving) return;
    final kept = _kept;
    if (kept.isEmpty) {
      showToast(context, tr.scanMenuNoneSelected);
      return;
    }
    if (kept.any((c) => c.name.trim().isEmpty)) {
      showToast(context, tr.scanMenuUnnamed);
      return;
    }
    if (kept.any((c) => c.category == null)) {
      showToast(context, tr.scanMenuNeedType);
      return;
    }
    setState(() => _saving = true);
    try {
      await _repo.confirmPhotos(
          widget.outingId, OutingPhotoKind.menu, List.of(_photoIds));
      final now = DateTime.now();
      for (final c in kept) {
        // Stable per draft session and item: confirming again after a failure
        // updates the same drink instead of creating a second one.
        final id = _uuid.v5(
            Namespace.url.value, '${widget.outingId}|$_session|${c.id}');
        final cocktail = c.category == DrinkCategory.cocktail;
        final photo = c.sourceIndex >= 0 && c.sourceIndex < _photoIds.length
            ? [_photoIds[c.sourceIndex]]
            : <String>[];
        await _repo.save(OutingDrink(
          id: id,
          outingId: widget.outingId,
          name: c.name.trim(),
          category: c.category!,
          origin: OutingDrinkOrigin.menu,
          description: c.description,
          volumeMl: c.volumeMl,
          // The menu rarely states the ABV; it stays unknown here.
          ingredients: !cocktail && c.ingredients.isNotEmpty
              ? c.ingredients
              : null,
          components: cocktail && c.ingredients.isNotEmpty
              ? [
                  for (final i in c.ingredients)
                    EntryComponent(
                        name: i, alcoholic: ingredientLooksAlcoholic(i)),
                ]
              : null,
          advertisedCents: c.priceCents,
          photoIds: photo,
          sourceText: c.snippets.join('\n'),
          createdAt: now,
          updatedAt: now,
        ));
      }
      _done = true;
      _debounce?.cancel();
      await _drafts.clear(widget.outingId, OutingPhotoKind.menu);
      if (mounted) Navigator.of(context).pop(MenuResult(kept.length));
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      showToast(context, tr.scanMenuSaveFailed);
    }
  }

  Future<void> _discardAll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr.scanMenuDiscardTitle),
        content: Text(tr.scanMenuDiscardBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(tr.commonCancel)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(tr.entryDiscard,
                  style: const TextStyle(color: AppColors.danger))),
        ],
      ),
    );
    if (ok != true) return;
    _done = true;
    _debounce?.cancel();
    for (final id in _photoIds) {
      await _repo.discardPhoto(id);
    }
    await _drafts.clear(widget.outingId, OutingPhotoKind.menu);
    if (mounted) Navigator.of(context).pop();
  }

  // ---- UI ----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_reviewing ? tr.scanMenuReviewTitle : tr.catalogScanMenu),
        actions: [
          if (_photoIds.isNotEmpty || _candidates.isNotEmpty)
            IconButton(
              tooltip: tr.scanDiscardReading,
              onPressed: _saving ? null : _discardAll,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
        ],
      ),
      body: _reviewing ? _reviewBody() : _captureBody(),
    );
  }

  Widget _captureBody() {
    final canRead = _recognizer.isSupported;
    final unread = _photoIds.any((id) => !_ocr.containsKey(id));
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(
          AppSpace.gutter, 0, AppSpace.gutter, AppSpace.xl),
      children: [
        SurfaceCard(
          child: Text(tr.scanMenuTip, style: AppText.body),
        ),
        if (getIt<OutingRepository>().byId(widget.outingId)?.endedAt !=
            null) ...[
          const SizedBox(height: AppSpace.sm),
          InfoPill(
            tr.scanMenuEnded,
            icon: Icons.info_outline_rounded,
            warning: true,
          ),
        ],
        if (!_repo.files.isDurable) ...[
          const SizedBox(height: AppSpace.sm),
          Text(tr.scanMenuWebPhotos, style: AppText.caption),
        ],
        if (_error != null) ...[
          const SizedBox(height: AppSpace.md),
          InfoPill(_error!, icon: Icons.error_outline_rounded, warning: true),
        ],
        SectionTitle(tr.scanMenuPhotos('${_photoIds.length}')),
        for (var i = 0; i < _photoIds.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpace.sm),
            child: SurfaceCard(
              padding: const EdgeInsets.all(AppSpace.sm),
              child: Row(children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: SizedBox(
                    width: 84,
                    height: 84,
                    child: _bytes[_photoIds[i]] == null
                        ? const ColoredBox(color: AppColors.surfaceHigh)
                        : Image.memory(_bytes[_photoIds[i]]!,
                            fit: BoxFit.cover, gaplessPlayback: true),
                  ),
                ),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tr.scanMenuPhotoN('${i + 1}'), style: AppText.subtitle),
                      Text(
                        _ocr.containsKey(_photoIds[i])
                            ? tr.scanMenuRead
                            : tr.scanMenuUnread,
                        style: AppText.caption,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: tr.scanRotateLeft,
                  onPressed: () => _rotate(_photoIds[i], 270),
                  icon: const Icon(Icons.rotate_left_rounded),
                ),
                IconButton(
                  tooltip: tr.scanRotateRight,
                  onPressed: () => _rotate(_photoIds[i], 90),
                  icon: const Icon(Icons.rotate_right_rounded),
                ),
                IconButton(
                  tooltip: tr.scanRemovePhoto,
                  onPressed: _reading ? null : () => _removePhoto(_photoIds[i]),
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.danger),
                ),
              ]),
            ),
          ),
        Wrap(spacing: AppSpace.sm, runSpacing: AppSpace.sm, children: [
          if (_capture.supports(CaptureSource.camera))
            OutlinedButton.icon(
              onPressed: _reading ? null : () => _pick(CaptureSource.camera),
              icon: const Icon(Icons.photo_camera_outlined),
              label: Text(
                  _photoIds.isEmpty ? tr.scanTakePhoto : tr.scanAnotherPhoto),
            ),
          if (_capture.supports(CaptureSource.gallery))
            OutlinedButton.icon(
              onPressed: _reading ? null : () => _pick(CaptureSource.gallery),
              icon: const Icon(Icons.photo_library_outlined),
              label: Text(tr.scanChooseGallery),
            ),
        ]),
        if (_photoIds.isNotEmpty && canRead) ...[
          const SizedBox(height: AppSpace.md),
          if (_reading) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: AppSpace.sm),
            Text(tr.scanMenuReadingMany, style: AppText.caption),
            TextButton(
                onPressed: _cancelReading,
                child: Text(tr.scanCancelReading)),
          ] else
            FilledButton.icon(
              onPressed: unread ? _read : () => setState(() => _reviewing = true),
              icon: const Icon(Icons.text_snippet_outlined),
              label: Text(unread ? tr.catalogScanMenu : tr.scanMenuSeeRead),
            ),
        ],
        if (!canRead) ...[
          const SizedBox(height: AppSpace.md),
          InfoPill(
            tr.scanMenuOcrUnavailable,
            icon: Icons.info_outline_rounded,
          ),
        ],
        SectionTitle(tr.scanMenuPastedSection),
        TextField(
          controller: _pasted,
          minLines: 3,
          maxLines: 8,
          onChanged: (_) {
            setState(() {});
            _saveDraftSoon();
          },
          decoration: InputDecoration(
            hintText: tr.scanMenuPastedHint,
          ),
        ),
        const SizedBox(height: AppSpace.md),
        Wrap(spacing: AppSpace.sm, runSpacing: AppSpace.sm, children: [
          if (_pasted.text.trim().isNotEmpty)
            FilledButton(
              onPressed: _reading ? null : _interpretPasted,
              child: Text(tr.scanInterpret),
            ),
          OutlinedButton(
            onPressed: _reading ? null : _addManual,
            child: Text(tr.scanMenuAddManual),
          ),
          if (_candidates.isNotEmpty)
            TextButton(
              onPressed: () => setState(() => _reviewing = true),
              child: Text(tr.scanMenuSeeCount(_candidates.length)),
            ),
        ]),
      ],
    );
  }

  Widget _reviewBody() {
    final kept = _kept.length;
    return Column(children: [
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSpace.gutter, 0, AppSpace.gutter, AppSpace.xl),
          children: [
            Text(tr.scanMenuReviewIntro, style: AppText.caption),
            for (final n in _notes)
              Padding(
                padding: const EdgeInsets.only(top: AppSpace.sm),
                child: InfoPill(menuNoteText(n),
                    icon: Icons.help_outline_rounded, warning: true),
              ),
            const SizedBox(height: AppSpace.md),
            Wrap(spacing: AppSpace.sm, children: [
              TextButton.icon(
                onPressed: () => setState(() => _reviewing = false),
                icon: const Icon(Icons.photo_outlined),
                label: Text(tr.scanMenuPhotosAndReading),
              ),
              TextButton.icon(
                onPressed: _addManual,
                icon: const Icon(Icons.add_rounded),
                label: Text(tr.scanMenuAddItem),
              ),
            ]),
            for (final c in _candidates)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpace.sm),
                child: _CandidateCard(
                  candidate: c,
                  onToggle: () => _update(c, c.copyWith(discarded: !c.discarded)),
                  onEdit: () => _edit(c),
                  onCategory: (cat) => _update(c, c.copyWith(category: () => cat)),
                  onPrice: (cents) =>
                      _update(c, c.copyWith(priceCents: () => cents)),
                ),
              ),
          ],
        ),
      ),
      BottomActionBar(
        child: FilledButton(
          onPressed: _saving || kept == 0 ? null : _confirm,
          child: Text(tr.scanMenuSave(kept)),
        ),
      ),
    ]);
  }
}

class _CandidateCard extends StatelessWidget {
  const _CandidateCard({
    required this.candidate,
    required this.onToggle,
    required this.onEdit,
    required this.onCategory,
    required this.onPrice,
  });

  final MenuCandidate candidate;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final ValueChanged<DrinkCategory?> onCategory;
  final ValueChanged<int?> onPrice;

  @override
  Widget build(BuildContext context) {
    final c = candidate;
    final dim = c.discarded;
    return Opacity(
      opacity: dim ? 0.55 : 1,
      child: SurfaceCard(
        padding: const EdgeInsets.fromLTRB(
            AppSpace.xs, AppSpace.sm, AppSpace.md, AppSpace.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Checkbox(
                value: !c.discarded,
                onChanged: (_) => onToggle(),
                activeColor: AppColors.amber,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.name.isEmpty ? tr.scanMenuNoName : c.name,
                          style: AppText.subtitle),
                      if (c.description != null)
                        Text(c.description!, style: AppText.caption),
                      if (c.volumeMl != null)
                        Text(tr.scanMenuSize(formatMl(c.volumeMl!)),
                            style: AppText.caption),
                      if (c.ingredients.isNotEmpty)
                        Text(tr.scanMenuIngredientsCited(c.ingredients.join(', ')),
                            style: AppText.caption),
                    ],
                  ),
                ),
              ),
              IconButton(
                tooltip: tr.scanMenuEditItem,
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
            ]),
            Padding(
              padding: const EdgeInsets.only(left: AppSpace.md),
              child: Wrap(
                spacing: AppSpace.sm,
                runSpacing: AppSpace.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  DropdownButton<DrinkCategory>(
                    value: c.category,
                    hint: Text(tr.scanMenuTypeHint),
                    isDense: true,
                    underline: const SizedBox.shrink(),
                    items: [
                      for (final cat in DrinkCategory.values)
                        DropdownMenuItem(value: cat, child: Text(cat.label)),
                    ],
                    onChanged: onCategory,
                  ),
                  if (c.duplicate)
                    InfoPill(tr.scanMenuDuplicate, icon: Icons.copy_rounded),
                  if (c.promo)
                    InfoPill(tr.scanMenuPromo,
                        icon: Icons.local_offer_outlined, warning: true),
                  if (c.priceCents != null)
                    InfoPill(tr.scanMenuPriceOnMenu(formatCents(c.priceCents!)),
                        icon: Icons.sell_outlined)
                  else if (c.priceOptions.isEmpty)
                    InfoPill(tr.scanMenuNoPriceRead, icon: Icons.sell_outlined),
                ],
              ),
            ),
            if (c.needsPriceChoice) ...[
              const SizedBox(height: AppSpace.sm),
              Padding(
                padding: const EdgeInsets.only(left: AppSpace.md),
                child: Text(tr.scanMenuPriceUnsure, style: AppText.caption),
              ),
              Padding(
                padding: const EdgeInsets.only(left: AppSpace.md),
                child: Wrap(spacing: AppSpace.sm, children: [
                  for (final p in c.priceOptions)
                    Tooltip(
                      message: p.snippet,
                      child: ActionChip(
                        label: Text('${formatCents(p.cents)} · "${_short(p.snippet)}"'),
                        onPressed: () => onPrice(p.cents),
                      ),
                    ),
                ]),
              ),
            ] else if (c.priceCents != null && c.priceOptions.length > 1) ...[
              Padding(
                padding: const EdgeInsets.only(left: AppSpace.md),
                child: TextButton(
                  onPressed: () => onPrice(null),
                  child: Text(tr.scanMenuChangePrice),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _short(String s) => s.length > 26 ? '${s.substring(0, 25)}…' : s;
}

class _CandidateEditor extends StatefulWidget {
  const _CandidateEditor({required this.candidate, this.isNew = false});

  final MenuCandidate candidate;
  final bool isNew;

  @override
  State<_CandidateEditor> createState() => _CandidateEditorState();
}

class _CandidateEditorState extends State<_CandidateEditor> {
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _volume;
  late final TextEditingController _price;
  late final TextEditingController _ingredients;
  DrinkCategory? _category;
  String? _problem;

  @override
  void initState() {
    super.initState();
    final c = widget.candidate;
    _name = TextEditingController(text: c.name);
    _description = TextEditingController(text: c.description ?? '');
    _volume = TextEditingController(text: c.volumeMl?.toString() ?? '');
    _price = TextEditingController(
        text: c.priceCents == null ? '' : centsToInput(c.priceCents!));
    _ingredients = TextEditingController(text: c.ingredients.join(', '));
    _category = c.category;
  }

  @override
  void dispose() {
    for (final c in [_name, _description, _volume, _price, _ingredients]) {
      c.dispose();
    }
    super.dispose();
  }

  void _apply() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _problem = tr.scanMenuNeedName);
      return;
    }
    final volumeText = _volume.text.trim();
    final volume = parseInteger(volumeText);
    if (volumeText.isNotEmpty && (volume == null || volume <= 0)) {
      setState(() => _problem = tr.scanMenuInvalidSize);
      return;
    }
    final priceText = _price.text.trim();
    final price = parseCents(priceText);
    if (priceText.isNotEmpty && price == null) {
      setState(() => _problem =
          numberInputError(priceText) ?? tr.scanMenuInvalidPrice);
      return;
    }
    final description = _description.text.trim();
    Navigator.of(context).pop(widget.candidate.copyWith(
      name: name,
      description: () => description.isEmpty ? null : description,
      category: () => _category,
      volumeMl: () => volume,
      priceCents: () => price,
      ingredients: _ingredients.text
          .split(RegExp(r'[,;\n]'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpace.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.isNew ? tr.scanMenuNewItem : tr.scanMenuEditItem,
                  style: AppText.title),
              const SizedBox(height: AppSpace.md),
              TextField(
                controller: _name,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(labelText: tr.scanMenuName),
              ),
              const SizedBox(height: AppSpace.md),
              TextField(
                controller: _description,
                minLines: 1,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration:
                    InputDecoration(labelText: tr.scanMenuDescription),
              ),
              const SizedBox(height: AppSpace.md),
              Wrap(
                spacing: AppSpace.sm,
                runSpacing: AppSpace.sm,
                children: [
                  for (final c in DrinkCategory.values)
                    ChoiceChip(
                      label: Text(c.label),
                      selected: _category == c,
                      showCheckmark: false,
                      onSelected: (_) => setState(() => _category = c),
                    ),
                ],
              ),
              const SizedBox(height: AppSpace.md),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _volume,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: tr.scanMenuSizeOptional, suffixText: 'ml'),
                  ),
                ),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: TextField(
                    controller: _price,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                        labelText: tr.scanMenuPriceOptional, prefixText: r'R$ '),
                  ),
                ),
              ]),
              const SizedBox(height: AppSpace.md),
              TextField(
                controller: _ingredients,
                minLines: 1,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: tr.scanMenuCitedOptional,
                  helperText: tr.scanMenuCitedHelper,
                ),
              ),
              if (_problem != null) ...[
                const SizedBox(height: AppSpace.sm),
                Text(_problem!,
                    style: const TextStyle(color: AppColors.danger)),
              ],
              const SizedBox(height: AppSpace.lg),
              FilledButton(onPressed: _apply, child: Text(tr.commonApply)),
            ],
          ),
        ),
      ),
    );
  }
}
