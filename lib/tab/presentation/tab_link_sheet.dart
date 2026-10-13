import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../drinks/domain/drink_entry.dart';

/// Which drink records to put on the tab, and which of them the user said are
/// the same shared bottle.
class LinkChoice {
  const LinkChoice(this.ids, this.merged);

  final List<String> ids;
  final Map<String, List<String>> merged;
}

/// "Incluir bebidas registradas": the records are only linked (by id). The
/// price always stays on the record, so nothing is copied.
Future<LinkChoice?> showTabLinkSheet(
  BuildContext context, {
  required List<DrinkEntry> available,
}) {
  return showModalBottomSheet<LinkChoice>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _LinkForm(available: available),
  );
}

class _LinkForm extends StatefulWidget {
  const _LinkForm({required this.available});

  final List<DrinkEntry> available;

  @override
  State<_LinkForm> createState() => _LinkFormState();
}

class _LinkFormState extends State<_LinkForm> {
  late final Set<String> _picked = {for (final e in widget.available) e.id};

  String _priceText(DrinkEntry e) {
    switch (e.priceKind) {
      case PriceKind.complimentary:
        return 'cortesia';
      case PriceKind.unknown:
        return 'sem preço';
      case PriceKind.informed:
        if (e.isShared) {
          if (e.billTotalCents != null) {
            return 'compartilhada · total ${formatCents(e.billTotalCents!)}';
          }
          return 'compartilhada · só a sua parte (${formatCents(e.paidCents ?? 0)}) '
              'é conhecida';
        }
        return formatCents(e.paidCents ?? 0);
    }
  }

  /// Shared records that look like the same bottle (same drink, size and
  /// total). The user decides; nothing is merged by guessing.
  Future<LinkChoice?> _resolve() async {
    final chosen = [
      for (final e in widget.available)
        if (_picked.contains(e.id)) e,
    ];
    final groups = <String, List<DrinkEntry>>{};
    for (final e in chosen) {
      if (!e.isShared || e.billTotalCents == null) continue;
      final key = [
        e.catalogItemId ?? e.name.toLowerCase(),
        e.containerMl,
        e.billTotalCents,
      ].join('|');
      groups.putIfAbsent(key, () => []).add(e);
    }
    final ids = [for (final e in chosen) e.id];
    final merged = <String, List<String>>{};
    for (final g in groups.values) {
      if (g.length < 2) continue;
      if (!mounted) return null;
      final same = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Mesma garrafa ou outra?'),
          content: Text(
            '${g.length} registros compartilhados de "${g.first.name}" têm o '
            'mesmo total (${formatCents(g.first.billTotalCents!)}). Foi a mesma '
            'garrafa/jarra ou ${g.length} separadas?\n\n'
            'O total entra na comanda uma vez por garrafa; o app não adivinha.',
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('${g.length} separadas')),
            TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Mesma garrafa')),
          ],
        ),
      );
      if (same == null) return null;
      if (same) {
        final keep = g.first.id;
        merged[keep] = [for (final e in g.skip(1)) e.id];
        for (final e in g.skip(1)) {
          ids.remove(e.id);
        }
      }
    }
    return LinkChoice(ids, merged);
  }

  @override
  Widget build(BuildContext context) {
    final all = widget.available;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpace.xl, 0, AppSpace.xl, AppSpace.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Bebidas já registradas', style: AppText.title),
                  const SizedBox(height: AppSpace.xs),
                  const Text(
                    'Elas só são ligadas à comanda: o preço continua no '
                    'registro e uma correção lá vale aqui. Seus registros não '
                    'mostram tudo o que a mesa pediu.',
                    style: AppText.caption,
                  ),
                  Row(children: [
                    TextButton(
                      onPressed: () => setState(
                          () => _picked.addAll([for (final e in all) e.id])),
                      child: const Text('Todas'),
                    ),
                    TextButton(
                      onPressed: () => setState(_picked.clear),
                      child: const Text('Nenhuma'),
                    ),
                  ]),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final e in all)
                    CheckboxListTile(
                      activeColor: AppColors.amber,
                      value: _picked.contains(e.id),
                      onChanged: (v) => setState(() {
                        if (v == true) {
                          _picked.add(e.id);
                        } else {
                          _picked.remove(e.id);
                        }
                      }),
                      title: Text(e.name),
                      subtitle: Text(
                          '${formatTime(e.consumedAt)} · ${_priceText(e)}',
                          style: AppText.caption),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpace.lg),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _picked.isEmpty
                      ? null
                      : () async {
                          final choice = await _resolve();
                          if (choice != null && context.mounted) {
                            Navigator.of(context).pop(choice);
                          }
                        },
                  child: Text('Incluir ${_picked.length} na comanda'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
