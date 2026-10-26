import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../domain/catalog_item.dart';
import '../domain/drink_category.dart';
import '../domain/provenance.dart';
import 'catalog_cubit.dart';
import '../../l10n/l10n.dart';

/// What the user chose in the detail sheet.
enum DetailAction { register, edit, delete }

/// Small tag telling where a drink's data comes from. It never claims
/// certification or safety.
class OriginBadge extends StatelessWidget {
  const OriginBadge(this.origin, {super.key});

  final InfoOrigin origin;

  @override
  Widget build(BuildContext context) {
    final icon = switch (origin) {
      InfoOrigin.verified => Icons.menu_book_outlined,
      InfoOrigin.mixed => Icons.menu_book_outlined,
      InfoOrigin.secondary => Icons.label_outline_rounded,
      InfoOrigin.recipe => Icons.receipt_long_outlined,
      InfoOrigin.generic => Icons.layers_outlined,
      InfoOrigin.user => Icons.person_outline_rounded,
    };
    return InfoPill(
      origin.label,
      icon: icon,
      warning: origin == InfoOrigin.generic,
    );
  }
}

/// Shows a product's data (nothing here is edited) and lets the user favourite
/// it or go register it. Pops a [DetailAction] or null.
Future<DetailAction?> showDrinkDetail(
  BuildContext context, {
  required CatalogItem item,
  required CatalogCubit catalog,
}) {
  return showModalBottomSheet<DetailAction>(
    context: context,
    isScrollControlled: true,
    builder: (_) => BlocProvider.value(
      value: catalog,
      child: _DrinkDetailSheet(item: item),
    ),
  );
}

class _DrinkDetailSheet extends StatelessWidget {
  const _DrinkDetailSheet({required this.item});

  final CatalogItem item;

  @override
  Widget build(BuildContext context) {
    final catalog = context.read<CatalogCubit>();
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, controller) => SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.xl,
                  0,
                  AppSpace.xl,
                  AppSpace.lg,
                ),
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceHigh,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Icon(
                          item.category.icon,
                          color: AppColors.amber,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: AppSpace.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.displayName, style: AppText.title),
                            Text(
                              [
                                if (item.brand != null) item.brand!,
                                item.category.label,
                              ].join(' · '),
                              style: AppText.caption,
                            ),
                          ],
                        ),
                      ),
                      BlocBuilder<CatalogCubit, CatalogState>(
                        builder: (context, state) {
                          final fav = state.favorites.contains(item.id);
                          return IconButton(
                            tooltip: fav
                                ? tr.catalogUnfavorite
                                : tr.catalogFavorite,
                            onPressed: () => catalog.toggleFavorite(item.id),
                            icon: Icon(
                              fav
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: fav
                                  ? AppColors.amber
                                  : AppColors.textMuted,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.md),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OriginBadge(item.origin),
                  ),
                  const SizedBox(height: AppSpace.lg),
                  ...[
                    _Row(
                      tr.catalogStyle,
                      item.displayStyle ?? tr.detailNotGiven,
                    ),
                    SectionTitle(tr.detailPresentations),
                    if (item.category == DrinkCategory.spirit)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpace.sm),
                        child: Text(
                          tr.detailBottleNotDose,
                          style: AppText.caption,
                        ),
                      ),
                    if (item.documentedPresentations.isEmpty)
                      Text(tr.detailUnverifiedPackages, style: AppText.caption)
                    else ...[
                      Wrap(
                        spacing: AppSpace.sm,
                        runSpacing: AppSpace.sm,
                        children: [
                          for (final p in item.documentedPresentations)
                            Chip(label: Text(p.displayLabel)),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpace.sm),
                        child: Text(
                          tr.detailPackagesNote,
                          style: AppText.caption,
                        ),
                      ),
                    ],
                  ],
                  if (item.note != null) ...[
                    const SizedBox(height: AppSpace.md),
                    Text(item.note!, style: AppText.caption),
                  ],
                  const SizedBox(height: AppSpace.md),
                  _AboutDataTile(item: item),
                  if (item.isCustom) ...[
                    const SizedBox(height: AppSpace.md),
                    Row(
                      children: [
                        if (!item.isRecipe)
                          TextButton.icon(
                            onPressed: () =>
                                Navigator.pop(context, DetailAction.edit),
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: Text(tr.commonEdit),
                          ),
                        TextButton.icon(
                          onPressed: () =>
                              Navigator.pop(context, DetailAction.delete),
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                            color: AppColors.danger,
                          ),
                          label: Text(
                            tr.commonDelete,
                            style: const TextStyle(color: AppColors.danger),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.xl,
                AppSpace.sm,
                AppSpace.xl,
                AppSpace.sm,
              ),
              child: FilledButton(
                onPressed: () => Navigator.pop(context, DetailAction.register),
                child: Text(tr.entryLogDrink),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.caption),
          const SizedBox(height: 2),
          Text(value, style: AppText.body),
        ],
      ),
    );
  }
}

/// "About this data": where each field comes from. Folded by default so the
/// sheet stays quick; a field source always wins over the general source.
class _AboutDataTile extends StatelessWidget {
  const _AboutDataTile({required this.item});

  final CatalogItem item;

  @override
  Widget build(BuildContext context) {
    final fields = provenanceOf(item);
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        dense: true,
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        title: Text(
          tr.aboutDataTitle,
          style: AppText.caption.copyWith(color: AppColors.amber),
        ),
        children: [
          for (final f in fields) _FieldBlock(f),
          if (item.abvVariants.isNotEmpty) ...[
            Text(tr.aboutDataVariantsTitle, style: AppText.caption),
            for (final v in item.abvVariants)
              Text(
                '${formatAbv(v.value)}: ${v.displayScope}',
                style: AppText.caption,
              ),
            const SizedBox(height: AppSpace.sm),
          ],
          if (item.source != null) ...[
            Text(tr.aboutDataGeneralTitle, style: AppText.caption),
            _SourceLines(
              FieldSource(
                field: ProvenanceField.abv,
                kind: ProvenanceKind.general,
                label: item.source!.label,
                labelI18n: item.source!.labelI18n,
                url: item.source!.url,
                consultedOn: item.source!.consultedOn,
                market: item.market,
              ),
            ),
          ],
          Text(tr.detailMayVary, style: AppText.caption),
        ],
      ),
    );
  }
}

class _FieldBlock extends StatelessWidget {
  const _FieldBlock(this.p);

  final FieldProvenance p;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            p.field.label,
            style: AppText.body.copyWith(fontWeight: FontWeight.w600),
          ),
          if (p.fallback) Text(tr.aboutDataFallback, style: AppText.caption),
          for (final (i, s) in p.sources.indexed) ...[
            if ((p.presentations[i] ?? const []).isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpace.xs),
                child: Text(
                  p.presentations[i]!.map((x) => x.displayLabel).join(', '),
                  style: AppText.caption.copyWith(color: AppColors.text),
                ),
              ),
            _SourceLines(s),
          ],
        ],
      ),
    );
  }
}

/// One source: kind, name, market, consultation date and the address
/// (tap to open, button to copy).
class _SourceLines extends StatelessWidget {
  const _SourceLines(this.s);

  final FieldSource s;

  String? get _date {
    final raw = s.consultedOn;
    final d = raw == null ? null : DateTime.tryParse(raw);
    return d == null ? null : formatDate(d);
  }

  @override
  Widget build(BuildContext context) {
    final url = s.url;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.xs, bottom: AppSpace.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.kind.label,
            style: AppText.caption.copyWith(color: AppColors.amber),
          ),
          Text(s.displayLabel, style: AppText.caption),
          if (s.market != null || _date != null)
            Text(
              [
                if (s.market != null) tr.aboutDataMarket(s.market!),
                if (_date != null) tr.aboutDataConsulted(_date!),
              ].join(' · '),
              style: AppText.caption,
            ),
          if (s.displayNote != null)
            Text(s.displayNote!, style: AppText.caption),
          if (s.kind == ProvenanceKind.packagingRegistry)
            Text(tr.aboutDataRegistryNote, style: AppText.caption),
          if (url != null)
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final uri = Uri.tryParse(url);
                      if (uri == null) return;
                      final ok = await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                      if (!ok && context.mounted) {
                        showToast(context, tr.aboutDataOpenFailed);
                      }
                    },
                    child: Text(
                      url,
                      style: AppText.caption.copyWith(
                        fontSize: 12,
                        color: AppColors.amber,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: tr.detailCopyAddress,
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: url));
                    if (context.mounted) {
                      showToast(context, tr.detailAddressCopied);
                    }
                  },
                  icon: const Icon(Icons.copy_rounded, size: 18),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
