import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/money_field.dart';
import '../../drinks/domain/abv_source.dart';
import '../../drinks/domain/drink_category.dart';
import '../../outings/data/outing_repository.dart';
import '../../scan/presentation/photo_widgets.dart';
import '../data/outing_drink_repository.dart';
import '../domain/outing_drink.dart';
import '../../l10n/l10n.dart';

/// Values the review screen starts from (what was read, or nothing for a
/// manual sign-up). Anything null stays unknown and empty on screen.
class ReviewPrefill {
  const ReviewPrefill({
    this.name,
    this.category,
    this.brand,
    this.volumeMl,
    this.abvPercent,
    this.abvSource,
    this.ingredients,
    this.origin = OutingDrinkOrigin.manual,
    this.photoIds = const [],
    this.sourceText,
    this.notes = const [],
    this.nameCandidates = const [],
  });

  final String? name;
  final DrinkCategory? category;
  final String? brand;
  final int? volumeMl;
  final double? abvPercent;
  final AbvSource? abvSource;
  final List<String>? ingredients;
  final OutingDrinkOrigin origin;
  final List<String> photoIds;
  final String? sourceText;

  /// Doubts to show to the user (several volumes, unsure name...).
  final List<String> notes;
  final List<String> nameCandidates;
}

class ReviewResult {
  const ReviewResult(this.drink, {required this.register});

  final OutingDrink drink;

  /// "Confirmar e continuar": go on to register the consumption.
  final bool register;
}

/// Reviews and saves a drink that belongs to this outing only. It never
/// touches the catalog or "Minhas bebidas". Pops a [ReviewResult].
class OutingDrinkReviewPage extends StatefulWidget {
  const OutingDrinkReviewPage({
    super.key,
    required this.outingId,
    this.existing,
    this.prefill = const ReviewPrefill(),
  });

  final String outingId;

  /// Editing an item already saved in this outing.
  final OutingDrink? existing;
  final ReviewPrefill prefill;

  @override
  State<OutingDrinkReviewPage> createState() => _OutingDrinkReviewPageState();
}

class _OutingDrinkReviewPageState extends State<OutingDrinkReviewPage> {
  final _repo = getIt<OutingDrinkRepository>();
  late final String _id;
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _price;
  DrinkCategory? _category;
  late List<String> _photoIds;
  late OutingDrinkOrigin _origin;
  String? _sourceText;
  bool _saving = false;
  bool _showErrors = false;
  bool _dirty = false;

  OutingDrink? get _existing => widget.existing;

  @override
  void initState() {
    super.initState();
    final e = _existing;
    final p = widget.prefill;
    _id = e?.id ?? _repo.newId();
    _name = TextEditingController(text: e?.name ?? p.name ?? '');
    _description = TextEditingController(text: e?.description ?? '');
    _price = TextEditingController(
      text: e?.advertisedCents == null ? '' : centsToInput(e!.advertisedCents!),
    );
    _category = e?.category ?? p.category;
    _photoIds = [...(e?.photoIds ?? p.photoIds)];
    _origin = e?.origin ?? p.origin;
    _sourceText = e?.sourceText ?? p.sourceText;
  }

  @override
  void dispose() {
    for (final c in [_name, _description, _price]) {
      c.dispose();
    }
    super.dispose();
  }

  void _touch() {
    if (!_dirty) setState(() => _dirty = true);
  }

  String? _validate() {
    if (_name.text.trim().isEmpty) return tr.outingReviewNeedName;
    if (_category == null) return tr.outingReviewNeedType;
    final price = _price.text.trim();
    if (price.isNotEmpty && parseCents(price) == null) {
      return numberInputError(price) ?? tr.scanMenuInvalidPrice;
    }
    return null;
  }

  String? _clean(String text) => text.trim().isEmpty ? null : text.trim();

  Future<void> _save({required bool register}) async {
    if (_saving) return;
    final problem = _validate();
    if (problem != null) {
      setState(() => _showErrors = true);
      showToast(context, problem);
      return;
    }
    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      // Only photos that still exist are linked: a lost file (web session
      // ended) leaves the structured data intact and simply has no photo.
      final photoIds = await _repo.existingPhotos(_photoIds);
      final drink = OutingDrink(
        id: _id,
        outingId: widget.outingId,
        name: _name.text.trim(),
        category: _category!,
        origin: _origin,
        // Not asked here: a correction keeps whatever an older version had.
        brand: _existing?.brand,
        style: _existing?.style,
        description: _clean(_description.text),
        volumeMl: _existing?.volumeMl,
        abvPercent: _existing?.abvPercent,
        abvSource: _existing?.abvSource,
        ingredients: _existing?.ingredients,
        components: _existing?.components,
        referenceItemId: _existing?.referenceItemId,
        advertisedCents: parseCents(_price.text),
        photoIds: photoIds,
        sourceText: _sourceText,
        createdAt: _existing?.createdAt ?? now,
        updatedAt: now,
      );
      await _repo.confirmPhotos(
        widget.outingId,
        _origin == OutingDrinkOrigin.menu
            ? OutingPhotoKind.menu
            : OutingPhotoKind.photoLabel,
        photoIds,
      );
      await _repo.save(drink);
      if (mounted) {
        Navigator.of(context).pop(ReviewResult(drink, register: register));
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      showToast(context, tr.customSaveFailed);
    }
  }

  Future<void> _confirmDiscard() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr.entryDiscardTitle),
        content: Text(tr.entryDiscardBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(tr.entryKeepEditing),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              tr.entryDiscard,
              style: const TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (leave == true && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final editing = _existing != null;
    final outing = getIt<OutingRepository>().byId(widget.outingId);
    final ended = outing?.endedAt != null;
    final notes = widget.prefill.notes;
    return PopScope(
      canPop: !_dirty || _saving,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            editing ? tr.outingReviewEditTitle : tr.outingReviewTitle,
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.gutter,
                  0,
                  AppSpace.gutter,
                  AppSpace.xl,
                ),
                children: [
                  Text(tr.outingReviewIsolation, style: AppText.caption),
                  if (ended) ...[
                    const SizedBox(height: AppSpace.sm),
                    InfoPill(
                      tr.outingReviewEnded,
                      icon: Icons.info_outline_rounded,
                      warning: true,
                    ),
                  ],
                  if (_photoIds.isNotEmpty) ...[
                    SectionTitle(tr.scanPhoto),
                    SizedBox(
                      height: 88,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (final id in _photoIds)
                            Padding(
                              padding: const EdgeInsets.only(
                                right: AppSpace.sm,
                              ),
                              child: PhotoThumb(
                                photoId: id,
                                size: 88,
                                onTap: () =>
                                    showPhotoViewer(context, photoId: id),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                  if (notes.isNotEmpty) ...[
                    const SizedBox(height: AppSpace.md),
                    for (final n in notes)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpace.xs),
                        child: InfoPill(
                          n,
                          icon: Icons.help_outline_rounded,
                          warning: true,
                        ),
                      ),
                  ],
                  SectionTitle(tr.outingReviewDrinkSection),
                  TextField(
                    controller: _name,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => _touch(),
                    decoration: InputDecoration(
                      labelText: tr.customName,
                      errorText: _showErrors && _name.text.trim().isEmpty
                          ? tr.customNameRequired
                          : null,
                    ),
                  ),
                  if (widget.prefill.nameCandidates.length > 1) ...[
                    const SizedBox(height: AppSpace.sm),
                    Text(tr.outingReviewOtherLines, style: AppText.caption),
                    const SizedBox(height: AppSpace.xs),
                    Wrap(
                      spacing: AppSpace.sm,
                      runSpacing: AppSpace.xs,
                      children: [
                        for (final c in widget.prefill.nameCandidates)
                          ActionChip(
                            label: Text(c),
                            onPressed: () => setState(() {
                              _name.text = c;
                              _dirty = true;
                            }),
                          ),
                      ],
                    ),
                  ],
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
                          onSelected: (_) => setState(() {
                            _category = c;
                            _dirty = true;
                          }),
                        ),
                    ],
                  ),
                  if (_showErrors && _category == null)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpace.xs),
                      child: Text(
                        tr.outingReviewPickType,
                        style: const TextStyle(
                          color: AppColors.danger,
                          fontSize: 12,
                        ),
                      ),
                    )
                  else if (_category == null)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpace.xs),
                      child: Text(
                        tr.outingReviewTypeUnknown,
                        style: AppText.caption,
                      ),
                    ),
                  if (_origin == OutingDrinkOrigin.menu ||
                      _description.text.isNotEmpty) ...[
                    const SizedBox(height: AppSpace.md),
                    TextField(
                      controller: _description,
                      minLines: 1,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (_) => _touch(),
                      decoration: InputDecoration(
                        labelText: tr.outingReviewDescription,
                      ),
                    ),
                  ],
                  SectionTitle(tr.outingReviewAdvertisedSection),
                  MoneyField(
                    controller: _price,
                    label: tr.outingReviewMenuPriceOptional,
                    helper: tr.outingReviewMenuPriceHelper,
                    onChanged: (_) => _touch(),
                  ),
                  SectionTitle(tr.outingReviewOriginSection),
                  SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_origin.label, style: AppText.subtitle),
                        const SizedBox(height: AppSpace.xs),
                        Text(
                          _origin == OutingDrinkOrigin.manual
                              ? tr.outingReviewOriginManual
                              : tr.outingReviewOriginPhoto,
                          style: AppText.caption,
                        ),
                      ],
                    ),
                  ),
                  if (_sourceText != null && _sourceText!.trim().isNotEmpty)
                    Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: Text(
                          tr.outingReviewSourceText,
                          style: AppText.subtitle,
                        ),
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: SelectableText(
                              _sourceText!,
                              style: AppText.caption,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            BottomActionBar(
              child: editing
                  ? FilledButton(
                      onPressed: _saving ? null : () => _save(register: false),
                      child: Text(tr.entrySaveChanges),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FilledButton(
                          onPressed: _saving
                              ? null
                              : () => _save(register: true),
                          child: Text(tr.outingReviewConfirmContinue),
                        ),
                        const SizedBox(height: AppSpace.sm),
                        OutlinedButton(
                          onPressed: _saving
                              ? null
                              : () => _save(register: false),
                          child: Text(tr.outingReviewSaveOnly),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
