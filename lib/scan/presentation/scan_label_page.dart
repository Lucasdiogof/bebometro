import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../outings/data/outing_repository.dart';
import '../../drinks/domain/abv_source.dart';
import '../../outing_drinks/data/outing_drink_repository.dart';
import '../../outing_drinks/domain/outing_drink.dart';
import '../../outing_drinks/presentation/outing_drink_review_page.dart';
import '../data/image_capture.dart';
import '../data/image_tools.dart';
import '../data/scan_draft_store.dart';
import '../data/text_recognizer.dart';
import '../domain/label_parser.dart';
import '../domain/ocr_models.dart';
import '../../l10n/l10n.dart';

/// Reads a label from a photo: capture or import, view/rotate/replace, read
/// the text on the device, then review. Pops a [ReviewResult] once the user
/// confirmed a drink. The reading belongs to [outingId] and nothing else.
class ScanLabelPage extends StatefulWidget {
  const ScanLabelPage({super.key, required this.outingId});

  final String outingId;

  @override
  State<ScanLabelPage> createState() => _ScanLabelPageState();
}

class _ScanLabelPageState extends State<ScanLabelPage> {
  final _repo = getIt<OutingDrinkRepository>();
  final _drafts = getIt<ScanDraftStore>();
  final _capture = getIt<ImageCaptureService>();
  final _recognizer = getIt<TextRecognizer>();
  final _text = TextEditingController();

  String? _photoId;
  Uint8List? _bytes;
  OcrResult? _ocr;
  bool _busy = false;
  bool _reading = false;
  int _runId = 0;
  String? _error;
  Timer? _debounce;

  /// Set once the reading ended (confirmed or discarded): nothing may write
  /// the draft again, not even a pending delayed save.
  bool _done = false;

  /// Guards against a second review opened by a repeated tap.
  bool _reviewOpen = false;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  @override
  void dispose() {
    // Leaving within the debounce window must not lose the last edit.
    if (_debounce?.isActive ?? false) {
      _debounce!.cancel();
      unawaited(_saveDraft());
    }
    _text.dispose();
    super.dispose();
  }

  Future<void> _restore() async {
    final draft = _drafts.load(widget.outingId, OutingPhotoKind.photoLabel);
    if (draft != null) {
      _text.text = draft.text;
      if (draft.photoIds.isNotEmpty) {
        final bytes = await _repo.files.read(draft.photoIds.first);
        if (bytes != null) {
          _photoId = draft.photoIds.first;
          _bytes = bytes;
        } else {
          // Web session ended or file removed: the text stays, the photo is
          // gone and the person is told instead of seeing a blank screen.
          _error = tr.scanLabelPhotoGone;
        }
      }
      if (mounted) setState(() {});
    }
    if (_bytes == null) {
      final lost = await _capture.recoverLost();
      if (lost != null) await _setPhoto(lost);
    }
  }

  void _saveDraftSoon() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _saveDraft);
  }

  Future<void> _saveDraft() async {
    if (_done) return;
    await _drafts.save(
      ScanDraft(
        outingId: widget.outingId,
        kind: OutingPhotoKind.photoLabel,
        photoIds: [?_photoId],
        text: _text.text,
      ),
    );
  }

  Future<void> _pick(CaptureSource source) async {
    setState(() => _error = null);
    try {
      final bytes = await _capture.pick(source);
      if (bytes != null) await _setPhoto(bytes);
    } on CaptureException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Future<void> _setPhoto(Uint8List bytes) async {
    final old = _photoId;
    final id = _repo.newId();
    try {
      await _repo.files.write(id, bytes);
    } catch (_) {
      if (mounted) {
        setState(() => _error = tr.scanPhotoSaveFailed);
      }
      return;
    }
    if (!mounted) {
      await _repo.discardPhoto(id);
      return;
    }
    setState(() {
      _photoId = id;
      _bytes = bytes;
      _ocr = null;
      _error = null;
      _text.clear();
    });
    // The draft points to the new photo before the old file goes away.
    await _saveDraft();
    if (old != null) await _repo.discardPhoto(old);
  }

  Future<void> _rotate(int degrees) async {
    final bytes = _bytes;
    final id = _photoId;
    if (bytes == null || id == null || _busy) return;
    setState(() => _busy = true);
    try {
      final rotated = await rotateImage(bytes, degrees);
      await _repo.files.write(id, rotated);
      if (!mounted) return;
      setState(() {
        _bytes = rotated;
        _ocr = null; // positions changed: read again
      });
    } catch (_) {
      if (mounted) setState(() => _error = tr.scanRotateFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _discard() async {
    final id = _photoId;
    _debounce?.cancel();
    if (id != null) await _repo.discardPhoto(id);
    await _drafts.clear(widget.outingId, OutingPhotoKind.photoLabel);
    if (!mounted) return;
    setState(() {
      _photoId = null;
      _bytes = null;
      _ocr = null;
      _error = null;
      _text.clear();
    });
  }

  Future<void> _read() async {
    final id = _photoId;
    if (id == null || _reading) return;
    final path = await _repo.files.pathOf(id);
    if (path == null) {
      setState(() => _error = tr.scanPhotoUnavailableToRead);
      return;
    }
    final run = ++_runId;
    setState(() {
      _reading = true;
      _error = null;
    });
    try {
      final result = await _recognizer.recognizeFile(path);
      if (run != _runId || !mounted) return; // cancelled
      if (result.isEmpty) {
        setState(() => _error = tr.scanNoTextFound);
        return;
      }
      _ocr = result;
      _text.text = result.text;
      await _saveDraft();
      if (mounted) setState(() {});
      await _review(parse: true);
    } on OcrFailure catch (e) {
      if (run == _runId && mounted) setState(() => _error = e.message);
    } finally {
      if (run == _runId && mounted) setState(() => _reading = false);
    }
  }

  void _cancelReading() {
    _runId++;
    setState(() => _reading = false);
  }

  /// Opens the review. With [parse], the text is interpreted; otherwise the
  /// fields start empty (the photo and text are still kept with the item).
  Future<void> _review({required bool parse}) async {
    if (_reviewOpen) return;
    final text = _text.text.trim();
    ReviewPrefill prefill;
    if (parse && text.isNotEmpty) {
      final source = (_ocr != null && _ocr!.text == _text.text)
          ? _ocr!
          : OcrResult.fromText(_text.text);
      final r = parseLabel(source);
      prefill = ReviewPrefill(
        name: r.name,
        category: r.category,
        volumeMl: r.volumeMl,
        abvPercent: r.abvPercent,
        abvSource: r.abvPercent == null ? null : AbvSource.photoLabel,
        ingredients: r.ingredients,
        origin: OutingDrinkOrigin.photoLabel,
        photoIds: [?_photoId],
        sourceText: text,
        notes: r.notes,
        nameCandidates: r.nameCandidates,
      );
    } else {
      prefill = ReviewPrefill(
        origin: _photoId == null
            ? OutingDrinkOrigin.manual
            : OutingDrinkOrigin.photoLabel,
        photoIds: [?_photoId],
        sourceText: text.isEmpty ? null : text,
      );
    }
    _reviewOpen = true;
    final ReviewResult? result;
    try {
      result = await Navigator.of(context).push<ReviewResult>(
        MaterialPageRoute(
          builder: (_) => OutingDrinkReviewPage(
            outingId: widget.outingId,
            prefill: prefill,
          ),
        ),
      );
    } finally {
      _reviewOpen = false;
    }
    if (result == null) return;
    // The drink is saved: the reading is over for good, even if this screen
    // is already gone.
    _done = true;
    _debounce?.cancel();
    await _drafts.clear(widget.outingId, OutingPhotoKind.photoLabel);
    if (mounted) Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = _bytes != null;
    final canRead = _recognizer.isSupported;
    return Scaffold(
      appBar: AppBar(title: Text(tr.catalogScanLabel)),
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(
          AppSpace.gutter,
          0,
          AppSpace.gutter,
          AppSpace.xl,
        ),
        children: [
          SurfaceCard(child: Text(tr.scanLabelTip, style: AppText.body)),
          if (getIt<OutingRepository>().byId(widget.outingId)?.endedAt !=
              null) ...[
            const SizedBox(height: AppSpace.sm),
            InfoPill(
              tr.scanLabelEnded,
              icon: Icons.info_outline_rounded,
              warning: true,
            ),
          ],
          if (!_repo.files.isDurable) ...[
            const SizedBox(height: AppSpace.sm),
            Text(tr.scanWebPhotoSession, style: AppText.caption),
          ],
          if (_error != null) ...[
            const SizedBox(height: AppSpace.md),
            InfoPill(_error!, icon: Icons.error_outline_rounded, warning: true),
          ],
          SectionTitle(tr.scanPhoto),
          if (!hasPhoto)
            Wrap(
              spacing: AppSpace.sm,
              runSpacing: AppSpace.sm,
              children: [
                if (_capture.supports(CaptureSource.camera))
                  FilledButton.icon(
                    onPressed: () => _pick(CaptureSource.camera),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: Text(tr.scanTakePhoto),
                  ),
                if (_capture.supports(CaptureSource.gallery))
                  OutlinedButton.icon(
                    onPressed: () => _pick(CaptureSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(tr.scanChooseGallery),
                  ),
              ],
            )
          else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.memory(
                      _bytes!,
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                    ),
                    if (_busy || _reading)
                      const ColoredBox(
                        color: Color(0x88000000),
                        child: SizedBox.expand(
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpace.sm),
            Wrap(
              spacing: AppSpace.sm,
              runSpacing: AppSpace.xs,
              children: [
                IconButton.outlined(
                  tooltip: tr.scanRotateLeft,
                  onPressed: _busy || _reading ? null : () => _rotate(270),
                  icon: const Icon(Icons.rotate_left_rounded),
                ),
                IconButton.outlined(
                  tooltip: tr.scanRotateRight,
                  onPressed: _busy || _reading ? null : () => _rotate(90),
                  icon: const Icon(Icons.rotate_right_rounded),
                ),
                if (_capture.supports(CaptureSource.camera))
                  OutlinedButton.icon(
                    onPressed: _reading
                        ? null
                        : () => _pick(CaptureSource.camera),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: Text(tr.scanNewPhoto),
                  ),
                if (_capture.supports(CaptureSource.gallery))
                  OutlinedButton.icon(
                    onPressed: _reading
                        ? null
                        : () => _pick(CaptureSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(tr.scanReplacePhoto),
                  ),
                TextButton.icon(
                  onPressed: _reading ? null : _discard,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.danger,
                  ),
                  label: Text(
                    tr.scanDiscardReading,
                    style: const TextStyle(color: AppColors.danger),
                  ),
                ),
              ],
            ),
          ],
          if (hasPhoto && canRead) ...[
            const SizedBox(height: AppSpace.md),
            if (_reading) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: AppSpace.sm),
              Text(tr.scanReadingOnDevice, style: AppText.caption),
              TextButton(
                onPressed: _cancelReading,
                child: Text(tr.scanCancelReading),
              ),
            ] else
              FilledButton.icon(
                onPressed: _read,
                icon: const Icon(Icons.text_snippet_outlined),
                label: Text(
                  _text.text.trim().isEmpty
                      ? tr.catalogScanLabel
                      : tr.scanReadAgain,
                ),
              ),
          ],
          if (!canRead) ...[
            const SizedBox(height: AppSpace.md),
            InfoPill(tr.scanOcrUnavailable, icon: Icons.info_outline_rounded),
          ],
          SectionTitle(tr.scanLabelText),
          TextField(
            controller: _text,
            minLines: 3,
            maxLines: 8,
            onChanged: (_) {
              setState(() {});
              _saveDraftSoon();
            },
            decoration: InputDecoration(
              hintText: canRead
                  ? tr.scanTextHintCanRead
                  : tr.scanTextHintManual,
            ),
          ),
          const SizedBox(height: AppSpace.md),
          Wrap(
            spacing: AppSpace.sm,
            runSpacing: AppSpace.sm,
            children: [
              if (_text.text.trim().isNotEmpty)
                FilledButton(
                  onPressed: _reading ? null : () => _review(parse: true),
                  child: Text(tr.scanInterpret),
                ),
              OutlinedButton(
                onPressed: _reading ? null : () => _review(parse: false),
                child: Text(tr.scanFillManually),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
