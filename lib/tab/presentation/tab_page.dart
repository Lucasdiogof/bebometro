import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/state_views.dart';
import '../../drinks/data/drink_repository.dart';
import '../../drinks/domain/drink_entry.dart';
import '../../drinks/presentation/drink_entry_page.dart';
import '../../outings/data/outing_repository.dart';
import '../data/tab_repository.dart';
import '../domain/tab_calc.dart';
import '../domain/tab_models.dart';
import '../domain/tab_share.dart';
import 'split_page.dart';
import 'tab_cubit.dart';
import 'tab_extra_sheet.dart';
import 'tab_link_sheet.dart';
import 'tab_share_page.dart';
import '../../l10n/l10n.dart';

/// "Comanda": what the table ordered, extras, service, discount and the way
/// to split. Optional and separate from the drink records: adding something
/// here never creates consumption, and registering a payment never adds to
/// the spending.
class TabPage extends StatelessWidget {
  const TabPage({super.key, required this.outingId});

  final String outingId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TabCubit(
        outingId,
        getIt<TabRepository>(),
        getIt<DrinkRepository>(),
        getIt<OutingRepository>(),
      ),
      child: const _TabView(),
    );
  }
}

class _TabView extends StatelessWidget {
  const _TabView();

  Future<void> _addExtra(BuildContext context, TabCubit cubit) async {
    final extra = await showTabExtraSheet(
      context,
      newId: cubit.newId(),
      participants: cubit.state.doc.participants,
    );
    if (extra != null) await cubit.saveExtra(extra);
  }

  Future<void> _link(BuildContext context, TabCubit cubit) async {
    final choice =
        await showTabLinkSheet(context, available: cubit.state.available);
    if (choice != null) {
      await cubit.linkEntries(choice.ids, merged: choice.merged);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TabCubit>();
    return BlocBuilder<TabCubit, TabState>(
      builder: (context, state) {
        final r = state.result;
        final ended = state.outing?.isActive == false;
        return Scaffold(
          appBar: AppBar(
            title: Text(tr.tabTitle),
            actions: [
              IconButton(
                tooltip: tr.tabShareSplitTooltip,
                onPressed: state.doc.isEmpty
                    ? null
                    : () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => TabSharePage(
                            outing: state.outing!,
                            doc: state.doc,
                            result: state.result,
                          ),
                        )),
                icon: const Icon(Icons.ios_share_rounded),
              ),
            ],
          ),
          body: Column(children: [
            Expanded(
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                    AppSpace.gutter, 0, AppSpace.gutter, AppSpace.xl),
                children: [
                  Text(tr.tabIntro, style: AppText.caption),
                  if (ended) ...[
                    const SizedBox(height: AppSpace.sm),
                    InfoPill(
                      tr.tabEnded,
                      icon: Icons.info_outline_rounded,
                    ),
                  ],
                  const SizedBox(height: AppSpace.md),
                  _TotalsCard(state: state),
                  const SizedBox(height: AppSpace.md),
                  _ServiceDiscountCard(state: state),
                  SectionTitle(
                    tr.tabItemsTitle('${r.results.length}'),
                    trailing: TextButton.icon(
                      onPressed: () => _addExtra(context, cubit),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: Text(tr.commonAdd),
                    ),
                  ),
                  if (r.groups.isEmpty)
                    EmptyView(
                      icon: Icons.receipt_long_outlined,
                      title: tr.tabEmptyTitle,
                      message: tr.tabEmptyBody,
                    )
                  else
                    for (final g in r.groups)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpace.sm),
                        child: _GroupTile(group: g, state: state),
                      ),
                  const SizedBox(height: AppSpace.sm),
                  OutlinedButton.icon(
                    onPressed: state.available.isEmpty
                        ? null
                        : () => _link(context, cubit),
                    icon: const Icon(Icons.local_bar_outlined),
                    label: Text(state.available.isEmpty
                        ? tr.tabNoDrinksToLink
                        : tr.tabLinkDrinks('${state.available.length}')),
                  ),
                ],
              ),
            ),
            BottomActionBar(
              child: FilledButton.icon(
                onPressed: () async {
                  await cubit.ensureMe();
                  if (!context.mounted) return;
                  await Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => SplitPage(cubit: cubit),
                  ));
                },
                icon: const Icon(Icons.call_split_rounded),
                label: Text(tr.tabSplitBill),
              ),
            ),
          ]),
        );
      },
    );
  }
}

// ---- Totals ------------------------------------------------------------------

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.strong = false, this.muted = false});

  final String label;
  final String value;
  final bool strong;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final style = strong
        ? AppText.title
        : (muted ? AppText.caption : AppText.body);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: style),
      ]),
    );
  }
}

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({required this.state});

  final TabState state;

  @override
  Widget build(BuildContext context) {
    final r = state.result;
    final d = state.doc;
    final partial = r.isPartial;
    final me = d.me;
    return SurfaceCard(
      highlight: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Row(partial ? tr.tabSubtotalKnown : tr.tabSubtotal,
              formatCents(r.subtotal)),
          if (r.discount > 0) _Row(tr.tabDiscount, '− ${formatCents(r.discount)}'),
          if (d.serviceOn)
            _Row(
              tr.tabServiceLine(
                  formatBp(d.serviceBp), formatCents(r.serviceBase)),
              '+ ${formatCents(r.service)}',
            ),
          const Divider(height: 20),
          _Row(partial ? tr.tabTotalKnown : tr.tabTotalTab,
              formatCents(r.total),
              strong: true),
          if (partial) ...[
            const SizedBox(height: AppSpace.sm),
            InfoPill(
              tr.tabPartialPill(r.pendingCount),
              icon: Icons.warning_amber_rounded,
              warning: true,
            ),
          ],
          if (me != null && d.participants.length > 1) ...[
            const Divider(height: 20),
            _Row(
              partial || r.unassigned != 0
                  ? tr.tabYourShareProvisional
                  : tr.tabYourShare,
              formatCents(r.shareOf(me.id)),
              strong: true,
            ),
          ],
          const SizedBox(height: AppSpace.sm),
          Text(tr.tabOrderNote, style: AppText.caption),
        ],
      ),
    );
  }
}

// ---- Service and discount ----------------------------------------------------

class _ServiceDiscountCard extends StatefulWidget {
  const _ServiceDiscountCard({required this.state});

  final TabState state;

  @override
  State<_ServiceDiscountCard> createState() => _ServiceDiscountCardState();
}

class _ServiceDiscountCardState extends State<_ServiceDiscountCard> {
  late final TextEditingController _pct;
  late final TextEditingController _discount;

  @override
  void initState() {
    super.initState();
    final d = widget.state.doc;
    _pct = TextEditingController(text: _bpText(d.serviceBp));
    _discount = TextEditingController(text: _discountText(d));
  }

  @override
  void dispose() {
    _pct.dispose();
    _discount.dispose();
    super.dispose();
  }

  static String _bpText(int bp) => decimalToInput(bp / 100);

  static String _discountText(TabDoc d) {
    if (d.discountKind == DiscountKind.none || d.discountValue == 0) return '';
    return d.discountKind == DiscountKind.amount
        ? centsToInput(d.discountValue)
        : _bpText(d.discountValue);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TabCubit>();
    final d = widget.state.doc;
    final r = widget.state.result;
    final capped = d.discountKind == DiscountKind.amount &&
        d.discountValue > r.subtotal;
    return SurfaceCard(
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
        childrenPadding: const EdgeInsets.fromLTRB(
            AppSpace.lg, 0, AppSpace.lg, AppSpace.lg),
        shape: const Border(),
        collapsedShape: const Border(),
        title: Text(tr.tabServiceAndDiscount, style: AppText.subtitle),
        subtitle: Text(
          [
            d.serviceOn
                ? tr.tabServiceSummary(formatBp(d.serviceBp))
                : tr.tabNoService,
            if (d.discountKind != DiscountKind.none && r.discount > 0)
              tr.tabDiscountSummary(formatCents(r.discount)),
          ].join(' · '),
          style: AppText.caption,
        ),
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(tr.tabChargeService),
            subtitle: Text(tr.tabChargeServiceHint),
            value: d.serviceOn,
            onChanged: (v) => cubit.setService(on: v),
          ),
          if (d.serviceOn) ...[
            // Common rates in one tap; any other value in the field below.
            // Switching the charge off removes it from every total again.
            Wrap(spacing: AppSpace.sm, children: [
              for (final bp in const [500, 1000, 2000])
                ChoiceChip(
                  label: Text('${bp ~/ 100}%'),
                  selected: d.serviceBp == bp,
                  showCheckmark: false,
                  onSelected: (_) {
                    _pct.text = _bpText(bp);
                    cubit.setService(on: true, bp: bp);
                  },
                ),
            ]),
            const SizedBox(height: AppSpace.sm),
            Row(children: [
              SizedBox(
                width: 120,
                child: TextField(
                  controller: _pct,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      labelText: tr.tabPercent,
                      suffixText: '%',
                      errorText: numberInputError(_pct.text),
                      errorMaxLines: 3),
                  onChanged: (v) {
                    final bp = parseBp(v);
                    if (bp != null) cubit.setService(on: true, bp: bp);
                  },
                ),
              ),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Text(
                  tr.tabServiceBase(
                      formatCents(r.serviceBase), formatCents(r.service)),
                  style: AppText.caption,
                ),
              ),
            ]),
          ],
          const Divider(height: 24),
          Text(tr.tabDiscount, style: AppText.subtitle),
          const SizedBox(height: AppSpace.sm),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<DiscountKind>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                    value: DiscountKind.none, label: Text(tr.tabDiscountNone)),
                const ButtonSegment(
                    value: DiscountKind.amount, label: Text(r'R$')),
                const ButtonSegment(
                    value: DiscountKind.percent, label: Text('%')),
              ],
              selected: {d.discountKind},
              onSelectionChanged: (s) {
                _discount.clear();
                cubit.setDiscount(s.first, 0);
              },
            ),
          ),
          if (d.discountKind != DiscountKind.none) ...[
            const SizedBox(height: AppSpace.md),
            TextField(
              controller: _discount,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: d.discountKind == DiscountKind.amount
                    ? tr.tabDiscountAmountLabel
                    : tr.tabDiscountPercentLabel,
                errorText: numberInputError(_discount.text),
                errorMaxLines: 3,
                prefixText: d.discountKind == DiscountKind.amount ? r'R$ ' : null,
                suffixText: d.discountKind == DiscountKind.percent ? '%' : null,
                helperText: capped
                    ? tr.tabDiscountCapped(formatCents(r.subtotal))
                    : tr.tabDiscountHelper,
                helperMaxLines: 3,
              ),
              onChanged: (v) {
                final value = d.discountKind == DiscountKind.amount
                    ? parseCents(v)
                    : parseBp(v);
                cubit.setDiscount(d.discountKind, value ?? 0);
              },
            ),
          ],
        ],
      ),
    );
  }
}

// ---- Items -------------------------------------------------------------------

class _GroupTile extends StatelessWidget {
  const _GroupTile({required this.group, required this.state});

  final TabGroup group;
  final TabState state;

  String _header() {
    final l = group.first;
    if (group.count > 1 && group.isPriced) {
      return tr.tabGroupHeaderMulti(l.title, '${group.count}',
          formatCents(group.unitCents!), formatCents(group.sumCents!));
    }
    if (group.count > 1) return tr.tabGroupHeaderNoPrice(l.title, '${group.count}');
    if (l.quantity > 1) {
      return l.totalCents == null
          ? tr.tabGroupQtyNoPrice(l.title, '${l.quantity}')
          : tr.tabGroupQtyTotal(l.title, '${l.quantity}', formatCents(l.totalCents!));
    }
    return l.title;
  }

  String? _sub() {
    final l = group.first;
    if (group.count == 1) {
      if (l.totalCents != null) {
        return [
          if (l.detail != null) l.detail!,
          l.complimentary ? tr.tabComplimentary : formatCents(l.totalCents!),
        ].join(' · ');
      }
      if (l.isPersonalOnly) {
        return tr.tabPersonalOnly(formatCents(l.personalOnlyCents!));
      }
      return [if (l.detail != null) l.detail!, tr.tabNoPrice].join(' · ');
    }
    if (!group.isPriced) {
      return l.isPersonalOnly ? tr.tabPersonalOnlyShort : tr.tabNoPrice;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l = group.first;
    final pending = group.lines.any((x) => x.isPending);
    final byId = {for (final r in state.result.results) r.line.id: r};
    return SurfaceCard(
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
        leading: Icon(
          l.source == LineSource.entry
              ? Icons.local_bar_outlined
              : (l.extra?.category.icon ?? Icons.receipt_long_outlined),
          color: pending ? AppColors.textMuted : AppColors.amber,
        ),
        title: Text(_header(), style: AppText.subtitle),
        subtitle: _sub() == null ? null : Text(_sub()!, style: AppText.caption),
        childrenPadding: const EdgeInsets.fromLTRB(
            AppSpace.lg, 0, AppSpace.sm, AppSpace.sm),
        children: [
          for (final line in group.lines)
            _LineRow(line: line, result: byId[line.id], state: state),
        ],
      ),
    );
  }
}

class _LineRow extends StatelessWidget {
  const _LineRow({required this.line, required this.result, required this.state});

  final TabLine line;
  final LineResult? result;
  final TabState state;

  Future<int?> _askMoney(BuildContext context, String title, String label) {
    final c = TextEditingController();
    return showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: c,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: label,
            prefixText: r'R$ ',
            helperText: tr.moneyFieldHelper,
            helperMaxLines: 3,
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(tr.commonCancel)),
          TextButton(
            onPressed: () {
              final cents = parseCents(c.text);
              if (cents != null) {
                Navigator.pop(ctx, cents);
              } else {
                showToast(ctx, numberInputError(c.text) ?? tr.numberInvalid);
              }
            },
            child: Text(tr.commonSave),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TabCubit>();
    final entry = line.entry;
    final extra = line.extra;
    final parts = <String>[
      formatTime(line.at),
      if (line.totalCents != null)
        line.complimentary ? tr.tabComplimentary : formatCents(line.totalCents!),
      if (line.totalCents == null)
        line.isPersonalOnly
            ? tr.tabLineOnlyYourShare(formatCents(line.personalOnlyCents!))
            : tr.tabNoPrice,
      if (result != null && result!.discount > 0)
        tr.tabLineDiscount(formatCents(result!.discount)),
      if (result != null && result!.service > 0)
        tr.tabLineService(formatCents(result!.service)),
    ];
    final canQuickFill = entry != null &&
        ((!entry.isShared && entry.priceKind == PriceKind.unknown) ||
            (entry.isShared &&
                entry.priceKind == PriceKind.informed &&
                entry.billTotalCents == null));
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(parts.join(' · '), style: AppText.body),
      subtitle: Text(
        entry != null
            ? tr.tabLineRegisteredDrink
            : (line.detail ?? tr.tabLineItem),
        style: AppText.caption,
      ),
      trailing: PopupMenuButton<String>(
        tooltip: tr.tabActions,
        onSelected: (v) async {
          switch (v) {
            case 'fill':
              final cents = await _askMoney(
                context,
                entry!.isShared ? tr.tabFillTotalTitle : tr.tabFillPriceTitle,
                entry.isShared ? tr.tabFillTotalLabel : tr.priceFixPaidLabel,
              );
              if (cents != null) await cubit.fillEntryPrice(entry, cents);
            case 'edit':
              if (entry != null) {
                await Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => DrinkEntryPage.edit(entry: entry)));
              } else if (extra != null) {
                final next = await showTabExtraSheet(
                  context,
                  newId: cubit.newId(),
                  participants: state.doc.participants,
                  existing: extra,
                );
                if (next != null) await cubit.saveExtra(next);
              }
            case 'service':
              await cubit.setLineService(line, !line.service);
            case 'remove':
              if (entry != null) {
                await cubit.unlink(entry.id);
              } else if (extra != null) {
                await cubit.removeExtra(extra.id);
              }
          }
        },
        itemBuilder: (_) => [
          if (canQuickFill)
            PopupMenuItem(
              value: 'fill',
              child: Text(entry!.isShared ? tr.tabFillTotal : tr.tabFillPrice),
            ),
          PopupMenuItem(
            value: 'edit',
            child: Text(entry != null ? tr.entryFix : tr.commonEdit),
          ),
          PopupMenuItem(
            value: 'service',
            child:
                Text(line.service ? tr.tabNoServiceItem : tr.tabChargeService),
          ),
          PopupMenuItem(
            value: 'remove',
            child:
                Text(entry != null ? tr.tabRemoveFromTab : tr.tabDeleteItem),
          ),
        ],
      ),
    );
  }
}
