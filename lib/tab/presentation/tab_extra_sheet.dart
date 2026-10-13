import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../drinks/domain/drink_entry.dart';
import '../domain/tab_models.dart';

/// Add or edit an extra line of the tab. Returns the extra, or null when
/// cancelled. Nothing here touches drink records or the catalog.
Future<TabExtra?> showTabExtraSheet(
  BuildContext context, {
  required String newId,
  required List<Participant> participants,
  TabExtra? existing,
}) {
  return showModalBottomSheet<TabExtra>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _ExtraForm(
      newId: newId,
      participants: participants,
      existing: existing,
    ),
  );
}

class _ExtraForm extends StatefulWidget {
  const _ExtraForm({
    required this.newId,
    required this.participants,
    this.existing,
  });

  final String newId;
  final List<Participant> participants;
  final TabExtra? existing;

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
        text: e?.cents == null ? '' : centsToInput(e!.cents!));
    _category = e?.category ?? ExtraCategory.food;
    _kind = e?.priceKind ?? PriceKind.informed;
    _basis = e?.basis ?? PriceBasis.total;
    _service = e?.service ?? _category.defaultService;
    _serviceTouched = e != null;
    _who = {
      for (final p in widget.participants)
        if (e?.assign == null || e!.assign!.containsKey(p.id)) p.id,
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
      setState(() => _error = 'Dê um nome ao item.');
      return;
    }
    int? cents;
    if (_kind == PriceKind.informed) {
      cents = parseCents(_price.text);
      if (cents == null) {
        setState(() => _error = 'Informe o valor, ou escolha Cortesia / Não sei.');
        return;
      }
    }
    final old = widget.existing;
    // Everybody ticked (or nobody to choose from) = shared by all.
    Map<String, int>? assign;
    if (widget.participants.isNotEmpty &&
        _who.length != widget.participants.length) {
      assign = {
        for (final id in _who) id: old?.assign?[id] ?? 1,
      };
    } else if (old?.assign != null && widget.participants.isNotEmpty) {
      assign = null;
    }
    Navigator.of(context).pop(TabExtra(
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
    ));
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
              AppSpace.xl, 0, AppSpace.xl, AppSpace.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.existing == null ? 'Novo item da comanda' : 'Editar item',
                  style: AppText.title),
              const SizedBox(height: AppSpace.xs),
              const Text(
                'Só na comanda deste rolê. Não vira consumo nem entra no '
                'catálogo.',
                style: AppText.caption,
              ),
              const SizedBox(height: AppSpace.md),
              Wrap(
                spacing: AppSpace.sm,
                runSpacing: AppSpace.sm,
                children: [
                  for (final c in ExtraCategory.values)
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
                  labelText: 'Descrição',
                  hintText: _category == ExtraCategory.transport
                      ? 'Ex.: Uber de volta (opcional)'
                      : 'Ex.: Porção de fritas',
                ),
              ),
              const SizedBox(height: AppSpace.md),
              Row(children: [
                SizedBox(
                  width: 110,
                  child: TextField(
                    controller: _quantity,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(labelText: 'Quantidade'),
                  ),
                ),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: SegmentedButton<PriceKind>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: PriceKind.informed, label: Text('Valor')),
                      ButtonSegment(
                          value: PriceKind.complimentary, label: Text('Cortesia')),
                      ButtonSegment(value: PriceKind.unknown, label: Text('Não sei')),
                    ],
                    selected: {_kind},
                    onSelectionChanged: (s) => setState(() => _kind = s.first),
                  ),
                ),
              ]),
              if (_kind == PriceKind.informed) ...[
                const SizedBox(height: AppSpace.md),
                if (qty > 1)
                  SegmentedButton<PriceBasis>(
                    showSelectedIcon: false,
                    segments: [
                      const ButtonSegment(
                          value: PriceBasis.unit, label: Text('Preço de cada um')),
                      ButtonSegment(
                          value: PriceBasis.total, label: Text('Total dos $qty')),
                    ],
                    selected: {_basis},
                    onSelectionChanged: (s) => setState(() => _basis = s.first),
                  ),
                if (qty > 1) const SizedBox(height: AppSpace.sm),
                TextField(
                  controller: _price,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: qty > 1 && _basis == PriceBasis.unit
                        ? 'Valor de cada unidade'
                        : (qty > 1 ? 'Valor total dos $qty' : 'Valor'),
                    prefixText: r'R$ ',
                    helperText: _helper(qty),
                  ),
                ),
              ] else
                Padding(
                  padding: const EdgeInsets.only(top: AppSpace.sm),
                  child: Text(
                    _kind == PriceKind.complimentary
                        ? 'Cortesia conta como R\$ 0,00 informado.'
                        : 'Sem preço: a conta fica parcial até você preencher.',
                    style: AppText.caption,
                  ),
                ),
              const SizedBox(height: AppSpace.sm),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Cobrar serviço neste item'),
                subtitle: const Text('Só vale se o serviço estiver ligado.'),
                value: _service,
                onChanged: (v) => setState(() {
                  _service = v;
                  _serviceTouched = true;
                }),
              ),
              if (widget.participants.isNotEmpty)
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: const Text('Quem divide este item',
                      style: AppText.subtitle),
                  subtitle: Text(
                    _who.length == widget.participants.length
                        ? 'Todos'
                        : '${_who.length} de ${widget.participants.length}',
                    style: AppText.caption,
                  ),
                  children: [
                    for (final p in widget.participants)
                      CheckboxListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.amber,
                        title: Text(p.name),
                        value: _who.contains(p.id),
                        onChanged: (v) => setState(() {
                          if (v == true) {
                            _who.add(p.id);
                          } else if (_who.length > 1) {
                            _who.remove(p.id);
                          }
                        }),
                      ),
                    const Text(
                      'Vale no modo "Por item" da divisão.',
                      style: AppText.caption,
                    ),
                  ],
                ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpace.sm),
                  child: Text(_error!,
                      style: const TextStyle(color: AppColors.danger)),
                ),
              const SizedBox(height: AppSpace.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                    onPressed: _save, child: const Text('Salvar item')),
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
        ? '$qty × ${formatCents(cents)} = ${formatCents(cents * qty)}'
        : 'Total da linha: ${formatCents(cents)}';
  }
}
