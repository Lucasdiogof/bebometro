import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
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

  @override
  void initState() {
    super.initState();
    _restore();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _text.dispose();
    super.dispose();
  }

  Future<void> _restore() async {
    final draft = _drafts.load(widget.outingId, OutingPhotoKind.label);
    if (draft != null) {
      _text.text = draft.text;
      if (draft.photoIds.isNotEmpty) {
        final bytes = await _repo.files.read(draft.photoIds.first);
        if (bytes != null) {
          _photoId = draft.photoIds.first;
          _bytes = bytes;
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

  Future<void> _saveDraft() => _drafts.save(ScanDraft(
        outingId: widget.outingId,
        kind: OutingPhotoKind.label,
        photoIds: [if (_photoId != null) _photoId!],
        text: _text.text,
      ));

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
        setState(() => _error = 'Não foi possível guardar a foto no aparelho.');
      }
      return;
    }
    if (old != null) await _repo.files.delete(old);
    if (!mounted) return;
    setState(() {
      _photoId = id;
      _bytes = bytes;
      _ocr = null;
      _error = null;
      _text.clear();
    });
    await _saveDraft();
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
      if (mounted) setState(() => _error = 'Não foi possível girar a imagem.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _discard() async {
    final id = _photoId;
    if (id != null) await _repo.files.delete(id);
    await _drafts.clear(widget.outingId, OutingPhotoKind.label);
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
      setState(() =>
          _error = 'A foto não está disponível para leitura. Tire outra.');
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
        setState(() => _error = 'Nenhum texto foi encontrado. Tente outra foto '
            'mais de perto, com boa luz, ou digite o texto.');
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
        abvSource: r.abvPercent == null ? null : AbvSource.label,
        ingredients: r.ingredients,
        origin: OutingDrinkOrigin.label,
        photoIds: [if (_photoId != null) _photoId!],
        sourceText: text,
        notes: r.notes,
        nameCandidates: r.nameCandidates,
      );
    } else {
      prefill = ReviewPrefill(
        origin: _photoId == null
            ? OutingDrinkOrigin.manual
            : OutingDrinkOrigin.label,
        photoIds: [if (_photoId != null) _photoId!],
        sourceText: text.isEmpty ? null : text,
      );
    }
    final result = await Navigator.of(context).push<ReviewResult>(
      MaterialPageRoute(
        builder: (_) => OutingDrinkReviewPage(
          outingId: widget.outingId,
          prefill: prefill,
        ),
      ),
    );
    if (result == null || !mounted) return;
    await _drafts.clear(widget.outingId, OutingPhotoKind.label);
    if (mounted) Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = _bytes != null;
    final canRead = _recognizer.isSupported;
    return Scaffold(
      appBar: AppBar(title: const Text('Ler rótulo')),
      body: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(
            AppSpace.gutter, 0, AppSpace.gutter, AppSpace.xl),
        children: [
          const SurfaceCard(
            child: Text(
              'Enquadre o rótulo inteiro, de frente, com boa luz e sem reflexo. '
              'Volume e teor costumam ficar em outro lado da embalagem: '
              'fotografe esse lado ou complete na revisão. Você confere tudo '
              'antes de salvar.',
              style: AppText.body,
            ),
          ),
          if (!_repo.files.isDurable) ...[
            const SizedBox(height: AppSpace.sm),
            const Text(
              'No navegador a foto só fica guardada durante esta sessão.',
              style: AppText.caption,
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: AppSpace.md),
            InfoPill(_error!, icon: Icons.error_outline_rounded, warning: true),
          ],
          const SectionTitle('Foto'),
          if (!hasPhoto)
            Wrap(spacing: AppSpace.sm, runSpacing: AppSpace.sm, children: [
              if (_capture.supports(CaptureSource.camera))
                FilledButton.icon(
                  onPressed: () => _pick(CaptureSource.camera),
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Tirar foto'),
                ),
              if (_capture.supports(CaptureSource.gallery))
                OutlinedButton.icon(
                  onPressed: () => _pick(CaptureSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Escolher da galeria'),
                ),
            ])
          else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 320),
                child: Stack(alignment: Alignment.center, children: [
                  Image.memory(_bytes!, fit: BoxFit.contain, gaplessPlayback: true),
                  if (_busy || _reading)
                    const ColoredBox(
                      color: Color(0x88000000),
                      child: SizedBox.expand(
                          child: Center(child: CircularProgressIndicator())),
                    ),
                ]),
              ),
            ),
            const SizedBox(height: AppSpace.sm),
            Wrap(spacing: AppSpace.sm, runSpacing: AppSpace.xs, children: [
              IconButton.outlined(
                tooltip: 'Girar para a esquerda',
                onPressed: _busy || _reading ? null : () => _rotate(270),
                icon: const Icon(Icons.rotate_left_rounded),
              ),
              IconButton.outlined(
                tooltip: 'Girar para a direita',
                onPressed: _busy || _reading ? null : () => _rotate(90),
                icon: const Icon(Icons.rotate_right_rounded),
              ),
              if (_capture.supports(CaptureSource.camera))
                OutlinedButton.icon(
                  onPressed:
                      _reading ? null : () => _pick(CaptureSource.camera),
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Nova foto'),
                ),
              if (_capture.supports(CaptureSource.gallery))
                OutlinedButton.icon(
                  onPressed:
                      _reading ? null : () => _pick(CaptureSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Trocar'),
                ),
              TextButton.icon(
                onPressed: _reading ? null : _discard,
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.danger),
                label: const Text('Descartar leitura',
                    style: TextStyle(color: AppColors.danger)),
              ),
            ]),
          ],
          if (hasPhoto && canRead) ...[
            const SizedBox(height: AppSpace.md),
            if (_reading) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: AppSpace.sm),
              const Text('Lendo o texto da foto neste aparelho…',
                  style: AppText.caption),
              TextButton(
                  onPressed: _cancelReading, child: const Text('Cancelar leitura')),
            ] else
              FilledButton.icon(
                onPressed: _read,
                icon: const Icon(Icons.text_snippet_outlined),
                label: Text(_text.text.trim().isEmpty
                    ? 'Ler rótulo'
                    : 'Ler de novo'),
              ),
          ],
          if (!canRead) ...[
            const SizedBox(height: AppSpace.md),
            const InfoPill(
              'A leitura automática não está disponível aqui (só no app para '
              'Android e iOS). Veja a foto e digite ou cole o texto do rótulo, '
              'ou preencha direto.',
              icon: Icons.info_outline_rounded,
            ),
          ],
          const SectionTitle('Texto do rótulo'),
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
                  ? 'O texto lido aparece aqui. Você pode corrigir.'
                  : 'Digite ou cole o texto do rótulo (opcional)',
            ),
          ),
          const SizedBox(height: AppSpace.md),
          Wrap(spacing: AppSpace.sm, runSpacing: AppSpace.sm, children: [
            if (_text.text.trim().isNotEmpty)
              FilledButton(
                onPressed: _reading ? null : () => _review(parse: true),
                child: const Text('Interpretar texto'),
              ),
            OutlinedButton(
              onPressed: _reading ? null : () => _review(parse: false),
              child: const Text('Preencher manualmente'),
            ),
          ]),
        ],
      ),
    );
  }
}
