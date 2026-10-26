import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/money_field.dart';
import '../../drinks/domain/drink_entry.dart';
import '../domain/tab_models.dart';
import '../../l10n/l10n.dart';

/// Add or edit an extra line of the tab. Returns the extra, or null when
/// cancelled. Nothing here touches drink records or the catalog.
///
/// On a table ([explicitWho]) "who takes part" is always written as the ticked
/// people (so a person who arrives later never inherits the dish), starts with
/// everybody still present, and is shown open. [categories] limits the kinds
/// offered (food, or the "other" ones).
Future<TabExtra?> showTabExtraSheet(
  BuildContext context, {
  required String newId,
  required List<Participant> participants,
  TabExtra? existing,
  bool explicitWho = false,
  ExtraCategory? defaultCategory,
  List<ExtraCategory>? categories,
  String? title,
}) {
  return showModalBottomSheet<TabExtra>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _ExtraForm(
      newId: newId,
      participants: participants,
      existing: existing,
      explicitWho: explicitWho,
      defaultCategory: defaultCategory,
      categories: categories,
      title: title,
    ),
  );
}

class _ExtraForm extends StatefulWidget {
  const _ExtraForm({
    required this.newId,
    required this.participants,
    this.existing,
    this.explicitWho = false,
    this.defaultCategory,
    this.categories,
    this.title,
  });

  final String newId;
  final List<Participant> participants;
  final TabExtra? existing;
  final bool explicitWho;
  final ExtraCategory? defaultCategory;
  final List<ExtraCategory>? categories;
  final String? title;

  @override
  State<_ExtraForm> createState() => _ExtraFormState();
}

class _ExtraFormState extends State<_ExtraForm> {
  late final TextEditingController _description;
  late final TextEditingController _quantity;
  late final TextEditingController _price;
  late ExtraCategory _category;
  late PriceKind _kind;
  late PriceBasis _basis;
  late bool _service;
  bool _serviceTouched = false;
  late Set<String> _who;
  String? _error;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _description = TextEditingController(text: e?.description ?? '');
    _quantity = TextEditingController(text: '${e?.quantity ?? 1}');
    _price = TextEditingController(
      text: e?.cents == null ? '' : centsToInput(e!.cents!),
    );
    _category = e?.category ?? widget.defaultCategory ?? ExtraCategory.food;
    _kind = e?.priceKind ?? PriceKind.informed;
    _basis = e?.basis ?? PriceBasis.total;
    _service = e?.service ?? _category.defaultService;
    _serviceTouched = e != null;
    _who = {
      for (final p in widget.participants)
        if (e != null
            ? (e.assign == null || e.assign!.containsKey(p.id))
            : (!widget.explicitWho || !p.left))
          p.id,
    };
  }

  @override
  void dispose() {
    _description.dispose();
    _quantity.dispose();
    _price.dispose();
    super.dispose();
  }

  int get _qty => (parseInteger(_quantity.text) ?? 1).clamp(1, 9999).toInt();

  void _save() {
    final description = _description.text.trim();
    if (description.isEmpty && _category != ExtraCategory.transport) {
      setState(() => _error = tr.scanMenuNeedName);
      return;
    }
    int? cents;
    if (_kind == PriceKind.informed) {
      cents = parseCents(_price.text);
      if (cents == null) {
        setState(
          () => _error = numberInputError(_price.text) ?? tr.tabExtraNeedValue,
        );
        return;
      }
    }
    final old = widget.existing;
    // Everybody ticked (or nobody to choose from) = shared by all. On a table
    // the ticked people are always written out: "everybody" never means
    // someone who arrives later.
    Map<String, int>? assign;
    if (widget.explicitWho && widget.participants.isNotEmpty) {
      assign = {for (final id in _who) id: old?.assign?[id] ?? 1};
    } else if (widget.participants.isNotEmpty &&
        _who.length != widget.participants.length) {
      assign = {for (final id in _who) id: old?.assign?[id] ?? 1};
    } else if (old?.assign != null && widget.participants.isNotEmpty) {
      assign = null;
    }
    Navigator.of(context).pop(
      TabExtra(
        id: old?.id ?? widget.newId,
        description: description,
        category: _category,
        createdAt: old?.createdAt ?? DateTime.now(),
        quantity: _qty,
        priceKind: _kind,
        basis: _basis,
        cents: cents,
        service: _service,
        assign: assign,
        consumers: old?.consumers,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final qty = _qty;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpace.xl,
            0,
            AppSpace.xl,
            AppSpace.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title ??
                    (widget.existing == null
                        ? tr.tabExtraNew
                        : tr.scanMenuEditItem),
                style: AppText.title,
              ),
              const SizedBox(height: AppSpace.xs),
              Text(tr.tabExtraNote, style: AppText.caption),
              const SizedBox(height: AppSpace.md),
              Wrap(
                spacing: AppSpace.sm,
                runSpacing: AppSpace.sm,
                children: [
                  for (final c in widget.categories ?? ExtraCategory.values)
                    ChoiceChip(
                      avatar: Icon(c.icon, size: 18),
                      label: Text(c.label),
                      selected: _category == c,
                      showCheckmark: false,
                      onSelected: (_) => setState(() {
                        _category = c;
                        if (!_serviceTouched) _service = c.defaultService;
                      }),
                    ),
                ],
              ),
              const SizedBox(height: AppSpace.md),
              TextField(
                controller: _description,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: tr.tabExtraDescription,
                  hintText: _category == ExtraCategory.transport
                      ? tr.tabExtraHintTransport
                      : tr.tabExtraHint,
                ),
              ),
              const SizedBox(height: AppSpace.md),
              Row(
                children: [
                  SizedBox(
                    width: 110,
                    child: TextField(
                      controller: _quantity,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(labelText: tr.entryAmount),
                    ),
                  ),
                  const SizedBox(width: AppSpace.md),
                  Expanded(
                    child: SegmentedButton<PriceKind>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(
                          value: PriceKind.informed,
                          label: Text(tr.entryPriceValue),
                        ),
                        ButtonSegment(
                          value: PriceKind.complimentary,
                          label: Text(tr.priceComplimentary),
                        ),
                        ButtonSegment(
                          value: PriceKind.unknown,
                          label: Text(tr.entryPriceDontKnow),
                        ),
                      ],
                      selected: {_kind},
                      onSelectionChanged: (s) =>
                          setState(() => _kind = s.first),
                    ),
                  ),
                ],
              ),
              if (_kind == PriceKind.informed) ...[
                const SizedBox(height: AppSpace.md),
                if (qty > 1)
                  SegmentedButton<PriceBasis>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: PriceBasis.unit,
                        label: Text(tr.tabBasisUnit),
                      ),
                      ButtonSegment(
                        value: PriceBasis.total,
                        label: Text(tr.tabBasisTotal('$qty')),
                      ),
                    ],
                    selected: {_basis},
                    onSelectionChanged: (s) => setState(() => _basis = s.first),
                  ),
                if (qty > 1) const SizedBox(height: AppSpace.sm),
                MoneyField(
                  controller: _price,
                  onChanged: (_) => setState(() {}),
                  label: qty > 1 && _basis == PriceBasis.unit
                      ? tr.tabValueEach
                      : (qty > 1
                            ? tr.tabValueTotalQty('$qty')
                            : tr.entryPriceValue),
                  helper: _helper(qty),
                ),
              ] else
                Padding(
                  padding: const EdgeInsets.only(top: AppSpace.sm),
                  child: Text(
                    _kind == PriceKind.complimentary
                        ? tr.entryComplimentaryNote(formatCents(0))
                        : tr.tabExtraNoPrice,
                    style: AppText.caption,
                  ),
                ),
              const SizedBox(height: AppSpace.sm),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(tr.tabExtraServiceItem),
                subtitle: Text(tr.tabExtraServiceHint),
                value: _service,
                onChanged: (v) => setState(() {
                  _service = v;
                  _serviceTouched = true;
                }),
              ),
              if (widget.participants.isNotEmpty)
                ExpansionTile(
                  key: const ValueKey('extra-who'),
                  initiallyExpanded:
                      widget.explicitWho && widget.participants.length > 1,
                  tilePadding: EdgeInsets.zero,
                  title: Text(tr.tabExtraWho, style: AppText.subtitle),
                  subtitle: Text(
                    _who.length == widget.participants.length
                        ? tr.tabExtraAll
                        : tr.tabExtraSome(
                            '${_who.length}',
                            '${widget.participants.length}',
                          ),
                    style: AppText.caption,
                  ),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        key: const ValueKey('extra-who-present'),
                        onPressed: () => setState(() {
                          _who = {
                            for (final p in widget.participants)
                              if (!p.left) p.id,
                          };
                        }),
                        child: Text(tr.extraWhoPresent),
                      ),
                    ),
                    for (final p in widget.participants)
                      CheckboxListTile(
                        key: ValueKey('extra-who-${p.id}'),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.amber,
                        title: Text(p.displayName),
                        value: _who.contains(p.id),
                        onChanged: (v) => setState(() {
                          if (v == true) {
                            _who.add(p.id);
                          } else if (_who.length > 1) {
                            _who.remove(p.id);
                          }
                        }),
                      ),
                    Text(tr.tabExtraWhoNote, style: AppText.caption),
                  ],
                ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpace.sm),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: AppColors.danger),
                  ),
                ),
              const SizedBox(height: AppSpace.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _save,
                  child: Text(tr.tabExtraSave),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _helper(int qty) {
    final cents = parseCents(_price.text);
    if (cents == null || qty <= 1) return null;
    return _basis == PriceBasis.unit
        ? tr.tabExtraHelperUnit(
            '$qty',
            formatCents(cents),
            formatCents(cents * qty),
          )
        : tr.tabExtraHelperLine(formatCents(cents));
  }
}
