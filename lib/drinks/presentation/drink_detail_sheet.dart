import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../domain/catalog_item.dart';
import 'catalog_cubit.dart';

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
      InfoOrigin.generic => Icons.layers_outlined,
      InfoOrigin.user => Icons.person_outline_rounded,
    };
    return InfoPill(origin.label, icon: icon, warning: origin == InfoOrigin.generic);
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
                    AppSpace.xl, 0, AppSpace.xl, AppSpace.lg),
                children: [
                  Row(children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Icon(item.category.icon,
                          color: AppColors.amber, size: 28),
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
                          tooltip: fav ? 'Remover dos favoritos' : 'Favoritar',
                          onPressed: () => catalog.toggleFavorite(item.id),
                          icon: Icon(
                            fav
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: fav ? AppColors.amber : AppColors.textMuted,
                          ),
                        );
                      },
                    ),
                  ]),
                  const SizedBox(height: AppSpace.md),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OriginBadge(item.origin),
                  ),
                  const SizedBox(height: AppSpace.lg),
                  _Row('Estilo', item.style ?? 'Não informado'),
                  _Row(
                    'Teor alcoólico',
                    item.abvPercent == null
                        ? 'Não informado'
                        : formatAbv(item.abvPercent!),
                  ),
                  _Row(
                    'Ingredientes declarados',
                    item.ingredients == null
                        ? 'Não informados'
                        : item.ingredients!.join(', '),
                  ),
                  const SectionTitle('Apresentações'),
                  if (item.presentations.isEmpty)
                    const Text(
                      'Tamanhos não verificados para este produto. Ao '
                      'registrar, você escolhe um tamanho comum ou digita o '
                      'volume.',
                      style: AppText.caption,
                    )
                  else
                    Wrap(
                      spacing: AppSpace.sm,
                      runSpacing: AppSpace.sm,
                      children: [
                        for (final p in item.presentations)
                          Chip(label: Text(p.label)),
                      ],
                    ),
                  if (item.presentations.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: AppSpace.sm),
                      child: Text(
                        'O tamanho da embalagem não é o que você bebeu: '
                        'isso você define ao registrar.',
                        style: AppText.caption,
                      ),
                    ),
                  if (item.note != null) ...[
                    const SizedBox(height: AppSpace.md),
                    Text(item.note!, style: AppText.caption),
                  ],
                  if (item.source != null) ...[
                    const SizedBox(height: AppSpace.md),
                    _SourceTile(source: item.source!),
                  ],
                  if (item.isCustom) ...[
                    const SizedBox(height: AppSpace.md),
                    Row(children: [
                      TextButton.icon(
                        onPressed: () =>
                            Navigator.pop(context, DetailAction.edit),
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Editar'),
                      ),
                      TextButton.icon(
                        onPressed: () =>
                            Navigator.pop(context, DetailAction.delete),
                        icon: const Icon(Icons.delete_outline_rounded,
                            size: 18, color: AppColors.danger),
                        label: const Text('Excluir',
                            style: TextStyle(color: AppColors.danger)),
                      ),
                    ]),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpace.xl, AppSpace.sm, AppSpace.xl, AppSpace.sm),
              child: FilledButton(
                onPressed: () => Navigator.pop(context, DetailAction.register),
                child: const Text('Registrar bebida'),
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

/// Discreet "where does this come from" line, expandable to the address.
class _SourceTile extends StatelessWidget {
  const _SourceTile({required this.source});

  final SourceRef source;

  String? get _date {
    final raw = source.consultedOn;
    final d = raw == null ? null : DateTime.tryParse(raw);
    return d == null ? null : formatDate(d);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        dense: true,
        title: Text(
          'Fonte dos dados',
          style: AppText.caption.copyWith(color: AppColors.amber),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${source.label}${_date == null ? '' : ' · consultado em $_date'}',
              style: AppText.caption,
            ),
          ),
          const SizedBox(height: AppSpace.xs),
          Row(children: [
            Expanded(
              child: SelectableText(
                source.url,
                style: AppText.caption.copyWith(fontSize: 12),
              ),
            ),
            IconButton(
              tooltip: 'Copiar endereço',
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: source.url));
                if (context.mounted) showToast(context, 'Endereço copiado');
              },
              icon: const Icon(Icons.copy_rounded, size: 18),
            ),
          ]),
          const Text(
            'Os dados podem variar por versão e mercado. Confira sempre o '
            'rótulo da embalagem.',
            style: AppText.caption,
          ),
        ],
      ),
    );
  }
}
