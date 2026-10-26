import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../core/sync/sync_cubit.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../table/presentation/order_page.dart';
import '../../scan/data/scan_draft_store.dart';
import '../../scan/presentation/photo_widgets.dart';
import '../../scan/presentation/scan_label_page.dart';
import '../../scan/presentation/scan_menu_page.dart';
import '../data/outing_drink_repository.dart';
import '../domain/outing_drink.dart';
import 'outing_drink_review_page.dart';
import '../../l10n/l10n.dart';

/// What this outing keeps from photos: its own drinks, the photos themselves
/// and readings left unfinished. Everything here belongs to this outing and is
/// shown only here, also after it ended.
class OutingScanSection extends StatefulWidget {
  const OutingScanSection({super.key, required this.outingId});

  final String outingId;

  @override
  State<OutingScanSection> createState() => _OutingScanSectionState();
}

class _OutingScanSectionState extends State<OutingScanSection> {
  final _repo = getIt<OutingDrinkRepository>();
  final _drafts = getIt<ScanDraftStore>();
  StreamSubscription<void>? _sub;
  var _drinks = <OutingDrink>[];
  var _photos = <OutingPhoto>[];
  var _open = <ScanDraft>[];

  /// A repeated tap on "Continuar" must not open the same reading twice.
  bool _resuming = false;

  @override
  void initState() {
    super.initState();
    _load();
    _sub = _repo.changes.listen((_) {
      if (mounted) setState(_load);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _load() {
    _drinks = _repo.forOuting(widget.outingId);
    _photos = _repo.photosFor(widget.outingId);
    _open = _drafts.openFor(widget.outingId);
  }

  Future<void> _resume(ScanDraft draft) async {
    if (_resuming) return;
    _resuming = true;
    try {
      await _openDraft(draft);
    } finally {
      _resuming = false;
    }
  }

  Future<void> _openDraft(ScanDraft draft) async {
    final id = widget.outingId;
    if (draft.kind == OutingPhotoKind.menu) {
      await Navigator.of(context).push<MenuResult>(
        MaterialPageRoute(builder: (_) => ScanMenuPage(outingId: id)),
      );
    } else {
      final result = await Navigator.of(context).push<ReviewResult>(
        MaterialPageRoute(builder: (_) => ScanLabelPage(outingId: id)),
      );
      if (result != null && result.register && mounted) {
        await OrderPage.open(
          context,
          outingId: id,
          item: result.drink.toCatalogItem(),
        );
      }
    }
    if (mounted) setState(_load);
  }

  Future<void> _dropDraft(ScanDraft draft) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr.scanMenuDiscardTitle),
        content: Text(tr.scanMenuDiscardBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(tr.commonCancel),
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
    if (ok != true) return;
    for (final id in draft.photoIds) {
      await _repo.discardPhoto(id);
    }
    await _drafts.clear(draft.outingId, draft.kind);
    if (mounted) setState(_load);
  }

  @override
  Widget build(BuildContext context) {
    if (_drinks.isEmpty && _photos.isEmpty && _open.isEmpty) {
      return const SizedBox.shrink();
    }
    final localOnly = _photos.where((p) => !p.isUploaded).length;
    final cloudSync = getIt<SyncCubit>().cloudEnabled;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final d in _open)
          Padding(
            padding: const EdgeInsets.only(top: AppSpace.md),
            child: SurfaceCard(
              highlight: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d.kind == OutingPhotoKind.menu
                        ? tr.outingScanUnfinishedMenu
                        : tr.outingScanUnfinishedLabel,
                    style: AppText.subtitle,
                  ),
                  const SizedBox(height: AppSpace.xs),
                  Text(tr.outingScanUnfinishedNote, style: AppText.caption),
                  Wrap(
                    spacing: AppSpace.sm,
                    children: [
                      TextButton(
                        onPressed: () => _resume(d),
                        child: Text(tr.commonContinue),
                      ),
                      TextButton(
                        onPressed: () => _dropDraft(d),
                        child: Text(
                          tr.entryDiscard,
                          style: const TextStyle(color: AppColors.danger),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        if (_drinks.isNotEmpty) ...[
          SectionTitle(tr.outingDrinksSectionTitle),
          Text(tr.outingScanOnlyHere, style: AppText.caption),
          const SizedBox(height: AppSpace.sm),
          for (final d in _drinks)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.sm),
              child: SurfaceCard(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => OutingDrinkReviewPage(
                      outingId: widget.outingId,
                      existing: d,
                    ),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.md,
                  AppSpace.sm,
                  AppSpace.md,
                  AppSpace.sm,
                ),
                child: Row(
                  children: [
                    if (d.photoIds.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: AppSpace.md),
                        child: PhotoThumb(photoId: d.photoIds.first, size: 44),
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.displayName, style: AppText.subtitle),
                          Text(
                            [
                              d.origin.label,
                              if (d.volumeMl != null) formatMl(d.volumeMl!),
                              if (d.abvPercent != null)
                                formatAbv(d.abvPercent!),
                              if (d.advertisedCents != null)
                                tr.outingDrinksMenuPrice(
                                  formatCents(d.advertisedCents!),
                                ),
                            ].join(' · '),
                            style: AppText.caption,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
        if (_photos.isNotEmpty) ...[
          SectionTitle(tr.outingScanPhotosTitle),
          Wrap(
            spacing: AppSpace.sm,
            runSpacing: AppSpace.sm,
            children: [
              for (final p in _photos)
                PhotoThumb(
                  photoId: p.id,
                  size: 76,
                  onTap: () => showPhotoViewer(
                    context,
                    photoId: p.id,
                    onDelete: () => _repo.deletePhoto(p.id),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpace.xs),
          Text(
            localOnly == 0
                ? tr.outingScanAllUploaded
                : cloudSync
                ? tr.outingScanPending(localOnly)
                : tr.outingScanLocalOnly(localOnly),
            style: AppText.caption,
          ),
        ],
      ],
    );
  }
}
