import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/money_field.dart';
import '../../drinks/data/drink_repository.dart';
import '../../drinks/domain/catalog_item.dart';
import '../../drinks/domain/drink_category.dart';
import '../../drinks/domain/drink_entry.dart';
import '../../drinks/presentation/add_drink_page.dart';
import '../../outings/data/outing_repository.dart';
import '../../l10n/l10n.dart';
import '../../tab/data/tab_repository.dart';
import '../../tab/domain/tab_calc.dart';
import '../../tab/domain/tab_models.dart';
import '../domain/order_builder.dart';
import '../domain/table_orders.dart';
import 'person_avatar.dart';

/// What the order form saved: the drink records or the extra line, and whether
/// it was a correction.
class OrderOutcome {
  const OrderOutcome({
    this.entries = const [],
    this.extra,
    this.edited = false,
  });

  final List<DrinkEntry> entries;
  final TabExtra? extra;
  final bool edited;
}

/// A lock-screen tap that could not be saved on its own, reviewed here: the
/// record keeps the command's id, the time of the tap and its origin.
class OrderReview {
  const OrderReview({
    required this.entryId,
    required this.at,
    required this.origin,
    required this.note,
  });

  final String entryId;
  final DateTime at;
  final EntryOrigin origin;
  final String note;
}

/// "New order" / "Correct order": what was ordered, how many, the price, who
/// consumed it and who pays. Name is free text (the catalog only suggests it);
/// nothing about volume, ABV or recipes is asked. Pops an [OrderOutcome].
class OrderPage extends StatefulWidget {
  const OrderPage({
    super.key,
    required this.outingId,
    required this.doc,
    this.preselected = const {},
    this.initialText = '',
    this.item,
    this.edit,
    this.seed,
    this.kind = OrderKind.alcoholic,
    this.review,
  });

  final String outingId;
  final TabDoc doc;

  /// People marked as consumers from the start (the person being viewed).
  final Set<String> preselected;
  final String initialText;

  /// A catalog product chosen before opening the form (name and kind only).
  final CatalogItem? item;

  /// Correcting this order instead of making a new one.
  final OrderRow? edit;

  /// Reviewing a lock-screen tap (one record, saved with the command's id).
  final OrderReview? review;

  /// What a new order starts as (drink, food or other); a catalog product
  /// or a copy overrides it.
  final OrderKind kind;

  /// A new order that starts as a copy of this one (consumers, payers, price):
  /// what "Repetir" opens when somebody of the order is no longer at the table.
  final OrderRow? seed;

  /// Opens the form to correct [row] of [outingId].
  static Future<OrderOutcome?> editRow(
    BuildContext context, {
    required String outingId,
    required OrderRow row,
  }) {
    final doc = getIt<TabRepository>().load(outingId);
    return Navigator.of(context).push<OrderOutcome>(
      MaterialPageRoute(
        builder: (_) => OrderPage(outingId: outingId, doc: doc, edit: row),
      ),
    );
  }

  /// Opens the form to correct the food/other line [extra].
  static Future<OrderOutcome?> editExtra(
    BuildContext context, {
    required String outingId,
    required TabExtra extra,
  }) {
    final doc = getIt<TabRepository>().load(outingId);
    for (final r in TableOrders.rows(
      doc,
      const {},
      const PersonFilter.table(),
    )) {
      if (r.extra?.id == extra.id) {
        return editRow(context, outingId: outingId, row: r);
      }
    }
    return Future.value();
  }

  /// Opens the form to correct the order of the record [entry].
  static Future<OrderOutcome?> editEntry(
    BuildContext context, {
    required DrinkEntry entry,
  }) {
    final tabs = getIt<TabRepository>();
    final doc = tabs.load(entry.outingId);
    final row = TableOrders.rowOfEntry(doc, entry);
    if (row == null) return Future.value();
    return editRow(context, outingId: entry.outingId, row: row);
  }

  /// Opens the form for [outingId], making sure the tab has the owner first.
  static Future<OrderOutcome?> open(
    BuildContext context, {
    required String outingId,
    Set<String> preselected = const {},
    String initialText = '',
    CatalogItem? item,
    OrderRow? seed,
    OrderKind kind = OrderKind.alcoholic,
  }) async {
    final tabs = getIt<TabRepository>();
    var doc = tabs.load(outingId);
    if (doc.me == null) {
      final me = Participant(
        id: getIt<DrinkRepository>().newId(),
        name: tr.tabMe,
        isMe: true,
      );
      await tabs.update(
        outingId,
        (d) => d.me != null
            ? d
            : d.copyWith(
                participants: [me, ...d.participants],
                equalIds: [me.id, ...d.equalIds],
              ),
      );
      doc = tabs.load(outingId);
    }
    if (!context.mounted) return null;
    return Navigator.of(context).push<OrderOutcome>(
      MaterialPageRoute(
        builder: (_) => OrderPage(
          outingId: outingId,
          doc: doc,
          preselected: preselected,
          initialText: initialText,
          item: item,
          seed: seed,
          kind: kind,
        ),
      ),
    );
  }

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  late final TextEditingController _name = TextEditingController(
    text: widget.initialText,
  );
  final _price = TextEditingController();
  final _payerCtl = <String, TextEditingController>{};

  OrderKind _kind = OrderKind.alcoholic;
  CatalogItem? _item;
  Presentation? _presentation;
  int _quantity = 1;

  final List<String> _consumers = [];
  bool _unitsMode = false;
  final Map<String, int> _units = {};

  final List<String> _payers = [];
  bool _customPayers = false;

  PriceKind _priceKind = PriceKind.informed;
  PriceBasis _basis = PriceBasis.unit;

  bool _showErrors = false;

  /// The screen is closing because the order was saved (no discard question).
  bool _leaving = false;
  bool _saving = false;

  /// Hidden legacy data of the record being corrected (see [OrderInput]).
  DrinkEntry? _template;

  /// The time of the record being corrected (only when the order is one
  /// record) and the one picked now. Null = not shown / unchanged.
  DateTime? _originalAt;
  DateTime? _at;

  bool get _editing => widget.edit != null;

  /// The order the form was filled from: the one corrected or the one copied.
  OrderRow? get _row => widget.edit ?? widget.seed;

  String get _ownerId => widget.doc.me?.id ?? '';

  /// Who can be picked: the people at the table, plus anybody already on the
  /// order being corrected (even if they left since).
  late final List<Participant> _people = () {
    final keep = {..._consumers, ..._payers};
    return [
      for (final p in widget.doc.participants)
        if (!p.left || keep.contains(p.id)) p,
    ];
  }();

  @override
  void initState() {
    super.initState();
    final row = _row;
    if (row != null) {
      _loadRow(row);
      if (_payers.isEmpty && _ownerId.isNotEmpty) _payers.add(_ownerId);
    } else {
      _kind = widget.kind;
      final item = widget.item;
      if (item != null) _applyItem(item);
      final pre = [
        for (final p in widget.doc.present)
          if (widget.preselected.contains(p.id)) p.id,
      ];
      // Alone at the table: the only person is the consumer.
      if (pre.isEmpty && widget.doc.present.length == 1) {
        pre.add(widget.doc.present.first.id);
      }
      _consumers.addAll(pre);
      if (_ownerId.isNotEmpty) _payers.add(_ownerId);
    }
  }

  /// Fills the form from the order being corrected: nothing is guessed, what
  /// was saved is what is shown.
  void _loadRow(OrderRow row) {
    final doc = widget.doc;
    // Correcting keeps everybody; a copy only takes people still present.
    final known = {
      for (final p in doc.participants)
        if (_editing || !p.left) p.id,
    };
    _consumers.addAll([
      for (final id in row.consumerIds)
        if (known.contains(id)) id,
    ]);
    _quantity = _editing ? row.quantity : 1;
    final x = row.extra;
    if (x != null) {
      _name.text = x.description;
      _kind = x.category == ExtraCategory.food
          ? OrderKind.food
          : OrderKind.other;
      _priceKind = x.priceKind;
      _basis = x.basis;
      _quantity = _editing ? x.quantity : 1;
      if (x.priceKind == PriceKind.informed && x.cents != null) {
        _price.text = centsToInput(x.cents!);
      }
      final w = x.assign ?? {for (final p in doc.present) p.id: 1};
      _payers.addAll([
        for (final id in w.keys)
          if (known.contains(id)) id,
      ]);
      _loadCustomPayers(w, x.totalCents);
      return;
    }
    final first = row.entries.first;
    _template = first;
    if (_editing && row.entries.length == 1) {
      _originalAt = _at = first.consumedAt;
    }
    _name.text = first.name;
    _kind = first.isAlcoholic ? OrderKind.alcoholic : OrderKind.soft;
    _priceKind = first.priceKind;
    _basis = PriceBasis.unit;
    final unit = first.totalCostCents;
    if (first.priceKind == PriceKind.informed && unit != null) {
      _price.text = centsToInput(unit);
    }
    final payerIds = TableOrders.payersOf(first, doc);
    _payers.addAll([
      for (final id in payerIds)
        if (known.contains(id)) id,
    ]);
    // Typed amounts: what each payer bears of the whole order.
    final typed = doc.linkFor(first.id)?.assign ?? first.payers;
    if (typed != null && typed.values.toSet().length > 1) {
      final cents = <String, int>{};
      for (final e in _editing ? row.entries : [row.entries.last]) {
        final w = {
          for (final id in TableOrders.payersOf(e, doc))
            if (known.contains(id)) id: _weightOf(e, id, doc),
        };
        final cost = e.totalCostCents;
        if (cost == null || w.isEmpty) continue;
        final ids = w.keys.toList();
        final parts = TabCalculator.allocate(cost, [
          for (final k in ids) w[k]!,
        ]);
        for (var k = 0; k < ids.length; k++) {
          cents[ids[k]] = (cents[ids[k]] ?? 0) + parts[k];
        }
      }
      if (cents.isNotEmpty) {
        _customPayers = true;
        for (final id in _payers) {
          _payerCtl[id] = TextEditingController(
            text: centsToInput(cents[id] ?? 0),
          );
        }
      }
    }
  }

  int _weightOf(DrinkEntry e, String id, TabDoc doc) {
    final typed = doc.linkFor(e.id)?.assign;
    if (typed != null) return typed[id] ?? 1;
    final key = id == doc.me?.id ? ownerPortionKey : id;
    return e.payers?[key] ?? 1;
  }

  void _loadCustomPayers(Map<String, int> w, int? total) {
    if (w.values.toSet().length < 2 || total == null) return;
    final ids = [for (final id in _payers) id];
    final parts = TabCalculator.allocate(total, [for (final k in ids) w[k]!]);
    _customPayers = true;
    for (var k = 0; k < ids.length; k++) {
      _payerCtl[ids[k]] = TextEditingController(text: centsToInput(parts[k]));
    }
  }

  /// Something was typed or chosen: leaving asks first.
  bool get _dirty =>
      _editing ||
      _name.text.trim() != widget.initialText.trim() ||
      _price.text.trim().isNotEmpty ||
      _consumers.isNotEmpty ||
      _item != null;

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
    if (leave == true && mounted) {
      setState(() => _leaving = true);
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    for (final c in _payerCtl.values) {
      c.dispose();
    }
    super.dispose();
  }

  int? get _priceCents {
    final t = _price.text.trim();
    return t.isEmpty ? null : parseCents(t);
  }

  TextEditingController _ctl(String id) =>
      _payerCtl.putIfAbsent(id, () => TextEditingController());

  Map<String, int>? get _payerCents {
    if (!_customPayers || _payers.length < 2) return null;
    return {for (final id in _payers) id: parseCents(_ctl(id).text) ?? 0};
  }

  OrderInput _input() {
    final item = _item;
    final p = _presentation;
    return OrderInput(
      outingId: widget.outingId,
      name: _name.text,
      kind: _kind,
      ownerId: _ownerId,
      at: DateTime.now(),
      quantity: _quantity,
      consumers: _consumers,
      units: _unitsActive ? Map.of(_units) : null,
      payers: _payers,
      payerCents: _payerCents,
      priceKind: _priceKind,
      priceCents: _priceCents,
      basis: _quantity > 1 ? _basis : PriceBasis.unit,
      category: item?.category,
      brand: item?.brand,
      style: item?.style,
      presentation: p?.label,
      catalogItemId: item?.id,
      containerMl: p?.volumeMl,
      template: _template,
      fixedId: widget.review?.entryId,
      fixedAt: widget.review?.at ?? (_at == _originalAt ? null : _at),
      origin: widget.review?.origin,
      existing: widget.edit?.entries ?? const [],
      existingExtra: widget.edit?.extra,
    );
  }

  bool get _unitsActive =>
      _unitsMode && _kind.isDrink && _quantity > 1 && _consumers.length > 1;

  List<CatalogItem> _suggestions() {
    final q = searchKey(_name.text);
    if (_item != null || q.length < 2 || _editing) return const [];
    final tokens = q.split(' ').where((t) => t.isNotEmpty).toList();
    final all = getIt<DrinkRepository>().catalog();
    final hits = [
      for (final i in all)
        if (!i.isOutingOnly && tokens.every(i.searchText.contains)) i,
    ];
    final wantsDraft = tokens.contains('chop');
    hits.sort((a, b) {
      if (wantsDraft) {
        final ad = a.category == DrinkCategory.draft;
        final bd = b.category == DrinkCategory.draft;
        if (ad != bd) return ad ? -1 : 1;
      }
      final an = normalizeText(a.displayName).startsWith(q) ? 0 : 1;
      final bn = normalizeText(b.displayName).startsWith(q) ? 0 : 1;
      if (an != bn) return an - bn;
      return normalizeText(a.displayName)
          .compareTo(normalizeText(b.displayName));
    });
    return hits.take(6).toList();
  }

  /// Takes only the name and the kind from the product; the rest of its data
  /// is never asked here.
  void _applyItem(CatalogItem item) {
    _item = item;
    _name.text = item.displayName;
    _kind = item.category.canBeAlcoholic ? OrderKind.alcoholic : OrderKind.soft;
    final docs = item.documentedPresentations;
    _presentation = docs.length == 1 ? docs.first : null;
  }

  void _pick(CatalogItem item) => setState(() => _applyItem(item));

  void _clearItem() => setState(() {
    _item = null;
    _presentation = null;
  });

  void _toggleConsumer(String id) => setState(() {
    if (!_consumers.remove(id)) _consumers.add(id);
    _rebalanceUnits();
  });

  void _togglePayer(String id) => setState(() {
    if (!_payers.remove(id)) _payers.add(id);
    if (_payers.length < 2) _customPayers = false;
  });

  void _setQuantity(int q) => setState(() {
    _quantity = q.clamp(1, OrderBuilder.maxQuantity).toInt();
    _rebalanceUnits();
  });

  /// Units per person start as an even split of the quantity; the person
  /// adjusts. Only touched when it no longer adds up.
  void _rebalanceUnits() {
    _units.removeWhere((k, _) => !_consumers.contains(k));
    final sum = _units.values.fold(0, (a, b) => a + b);
    if (_consumers.isEmpty ||
        (sum == _quantity && _units.length == _consumers.length)) {
      return;
    }
    final each = _quantity ~/ _consumers.length;
    var extra = _quantity % _consumers.length;
    for (final id in _consumers) {
      _units[id] = each + (extra-- > 0 ? 1 : 0);
    }
  }

  void _stepUnit(String id, int delta) => setState(() {
    _units[id] = ((_units[id] ?? 0) + delta).clamp(0, _quantity).toInt();
  });

  void _setCustom(bool on) => setState(() {
    _customPayers = on;
    if (on) {
      final amounts = OrderBuilder.payerAmounts(
        OrderInput(
          name: _name.text,
          kind: _kind,
          outingId: widget.outingId,
          ownerId: _ownerId,
          at: DateTime.now(),
          quantity: _quantity,
          consumers: _consumers,
          payers: _payers,
          priceKind: _priceKind,
          priceCents: _priceCents,
          basis: _quantity > 1 ? _basis : PriceBasis.unit,
        ),
      );
      for (final id in _payers) {
        _ctl(id).text = amounts == null ? '' : centsToInput(amounts[id] ?? 0);
      }
    }
  });

  String _namesOf(Iterable<String> ids) =>
      [for (final id in ids) widget.doc.participant(id)?.displayName ?? '?']
          .join(', ');

  /// Cost of the order as typed, for the helper under the price.
  String? _priceHelper() {
    if (_priceKind != PriceKind.informed) return null;
    final cents = _priceCents;
    if (cents == null || _quantity <= 1) return null;
    return _basis == PriceBasis.unit
        ? tr.orderLineSummary(
            _quantity,
            formatCents(cents),
            formatCents(cents * _quantity),
          )
        : tr.orderLineSummary(
            _quantity,
            formatCents((cents / _quantity).round()),
            formatCents(cents),
          );
  }

  /// "Open the catalog" only to find a name: the product comes back here.
  Future<void> _openCatalog() async {
    final item = await Navigator.of(context).push<CatalogItem>(
      MaterialPageRoute(
        builder: (_) => AddDrinkPage(outingId: widget.outingId, pickOnly: true),
      ),
    );
    if (item != null && mounted) _pick(item);
  }

  Future<void> _pickTime() async {
    final at = _at;
    if (at == null) return;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(at),
    );
    if (t == null || !mounted) return;
    setState(() => _at = DateTime(at.year, at.month, at.day, t.hour, t.minute));
  }

  /// A time that changed must stay inside the outing and not be in the future.
  String? _timeProblem() {
    final at = _at;
    if (at == null || at == _originalAt) return null;
    final outing = getIt<OutingRepository>().byId(widget.outingId);
    if (outing == null) return null;
    if (at.isBefore(outing.startedAt)) {
      return tr.draftBeforeStart(formatTime(outing.startedAt));
    }
    final end = outing.endedAt;
    if (end != null && at.isAfter(end)) {
      return tr.draftAfterEnd(formatTime(end));
    }
    if (at.isAfter(DateTime.now().add(const Duration(minutes: 5)))) {
      return tr.draftNotFuture;
    }
    return null;
  }

  Future<void> _save() async {
    if (_saving) return;
    final input = _input();
    if (OrderBuilder.problems(input).isNotEmpty) {
      setState(() => _showErrors = true);
      return;
    }
    final timeProblem = _timeProblem();
    if (timeProblem != null) {
      showToast(context, timeProblem);
      return;
    }
    setState(() => _saving = true);
    final repo = getIt<DrinkRepository>();
    final tabs = getIt<TabRepository>();
    final before = _editing ? tabs.compute(widget.outingId) : null;
    final result = OrderBuilder.build(input, newId: repo.newId);

    if (result.extra != null) {
      final x = result.extra!;
      await tabs.update(widget.outingId, (d) {
        final exists = d.extras.any((e) => e.id == x.id);
        return d.copyWith(
          extras: [
            for (final e in d.extras) e.id == x.id ? x : e,
            if (!exists) x,
          ],
        );
      });
    } else {
      await repo.saveAll(result.entries);
      final kept = {for (final e in result.entries) e.id};
      final dropped = [
        for (final e in input.existing)
          if (!kept.contains(e.id)) e.id,
      ];
      for (final id in dropped) {
        await repo.delete(id);
      }
      await tabs.update(widget.outingId, (d) {
        var next = d;
        // A tab made before people existed only charges linked records.
        if (!d.autoLink) {
          final covered = d.coveredEntryIds;
          next = next.copyWith(
            links: [
              ...d.links,
              for (final e in result.entries)
                if (!covered.contains(e.id)) TabLink(entryId: e.id),
            ],
          );
        }
        // A correction replaces an older typed split of the same records:
        // the payers just chosen are the ones that count.
        if (_editing) {
          final ids = {for (final e in result.entries) e.id};
          next = next.copyWith(
            links: [
              for (final l in next.links)
                ids.contains(l.entryId) ? l.copyWith(assign: () => null) : l,
            ],
          );
        }
        return next;
      });
    }

    if (_editing && before != null) await _explainBalances(before);
    if (!mounted) return;
    setState(() => _leaving = true);
    Navigator.of(context).pop(
      OrderOutcome(
        entries: result.entries,
        extra: result.extra,
        edited: _editing,
      ),
    );
  }

  /// A correction never deletes payments: when it changes what somebody owes,
  /// say so with the old and the new balance.
  Future<void> _explainBalances(TabResult before) async {
    final tabs = getIt<TabRepository>();
    final doc = tabs.load(widget.outingId);
    if (doc.payments.isEmpty) return;
    final after = tabs.compute(widget.outingId);
    final lines = <String>[];
    for (final p in doc.participants) {
      final a = before.balanceOf(p.id);
      final b = after.balanceOf(p.id);
      if (a != b) {
        lines.add(
          tr.orderBalanceLine(p.displayName, formatCents(a), formatCents(b)),
        );
      }
    }
    if (lines.isEmpty || !mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr.orderBalanceTitle),
        content: Text('${tr.orderBalanceBody}\n\n${lines.join('\n')}'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr.commonClose),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final input = _input();
    final problems = _showErrors
        ? OrderBuilder.problems(input)
        : const <OrderProblem>{};
    final suggestions = _suggestions();
    final item = _item;
    final text = _name.text.trim();
    final kinds = _editing
        ? (_row!.extra != null
              ? const [OrderKind.food, OrderKind.other]
              : const [OrderKind.alcoholic, OrderKind.soft])
        : OrderKind.values;
    final amounts = OrderBuilder.payerAmounts(input);
    return PopScope(
      canPop: _leaving || !_dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_editing ? tr.orderEditTitle : tr.orderTitle),
        ),
        body: SafeArea(
          bottom: false,
          child: Column(
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
                    ..._originNote(),
                    SectionTitle(tr.orderWhat),
                    TextField(
                      key: const ValueKey('order-name'),
                      controller: _name,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: tr.orderNameLabel,
                        hintText: tr.orderNameHint,
                        errorText: problems.contains(OrderProblem.nameMissing)
                            ? tr.orderErrName
                            : null,
                      ),
                      onChanged: (_) => setState(() {
                        if (_item != null &&
                            normalizeText(_name.text) !=
                                normalizeText(_item!.displayName)) {
                          _item = null;
                          _presentation = null;
                        }
                      }),
                    ),
                    if (item != null) ...[
                      const SizedBox(height: AppSpace.sm),
                      Row(
                        children: [
                          Expanded(
                            child: InfoPill(
                              tr.orderFromCatalog(item.displayName),
                              icon: Icons.menu_book_outlined,
                            ),
                          ),
                          TextButton(
                            onPressed: _clearItem,
                            child: Text(tr.orderUseTextOnly),
                          ),
                        ],
                      ),
                      if (item.documentedPresentations.length > 1) ...[
                        const SizedBox(height: AppSpace.sm),
                        Wrap(
                          spacing: AppSpace.sm,
                          runSpacing: AppSpace.sm,
                          children: [
                            for (final p in item.documentedPresentations)
                              ChoiceChip(
                                label: Text(p.displayLabel),
                                selected: _presentation?.label == p.label,
                                showCheckmark: false,
                                onSelected: (s) => setState(
                                  () => _presentation = s ? p : null,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ] else if (suggestions.isNotEmpty) ...[
                      const SizedBox(height: AppSpace.sm),
                      SizedBox(
                        height: 44,
                        child: ListView.separated(
                          key: const ValueKey('suggestions'),
                          scrollDirection: Axis.horizontal,
                          itemCount: suggestions.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: AppSpace.sm),
                          itemBuilder: (context, i) {
                            final s = suggestions[i];
                            return ActionChip(
                              key: ValueKey('suggest-${s.id}'),
                              avatar: Icon(
                                s.category.icon,
                                size: 18,
                                color: AppColors.amber,
                              ),
                              label: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 200,
                                ),
                                child: Text(
                                  s.displayName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              onPressed: () => _pick(s),
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpace.md),
                    Wrap(
                      spacing: AppSpace.sm,
                      runSpacing: AppSpace.sm,
                      children: [
                        for (final k in kinds)
                          ChoiceChip(
                            key: ValueKey('kind-${k.name}'),
                            avatar: Icon(_kindIcon(k), size: 18),
                            label: Text(_kindLabel(k)),
                            selected: _kind == k,
                            showCheckmark: false,
                            onSelected: (_) => setState(() {
                              _kind = k;
                              if (!k.isDrink) _unitsMode = false;
                            }),
                          ),
                      ],
                    ),
                    if (widget.review != null) ...[
                      const SizedBox(height: AppSpace.sm),
                      InfoPill(
                        widget.review!.note,
                        icon: Icons.info_outline_rounded,
                      ),
                    ],
                    if (widget.review == null) SectionTitle(tr.orderQuantity),
                    if (widget.review == null)
                      _Stepper(
                        key: const ValueKey('order-quantity'),
                        value: _quantity,
                        onMinus: _quantity > 1
                            ? () => _setQuantity(_quantity - 1)
                            : null,
                        onPlus: _quantity < OrderBuilder.maxQuantity
                            ? () => _setQuantity(_quantity + 1)
                            : null,
                        minusTip: tr.orderLess(tr.orderQuantity),
                        plusTip: tr.orderMore(tr.orderQuantity),
                      ),
                    SectionTitle(tr.orderPrice),
                    SegmentedButton<PriceKind>(
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
                      selected: {_priceKind},
                      onSelectionChanged: (s) =>
                          setState(() => _priceKind = s.first),
                    ),
                    if (_priceKind == PriceKind.informed) ...[
                      if (_quantity > 1) ...[
                        const SizedBox(height: AppSpace.sm),
                        SegmentedButton<PriceBasis>(
                          showSelectedIcon: false,
                          segments: [
                            ButtonSegment(
                              value: PriceBasis.unit,
                              label: Text(tr.orderPriceEach),
                            ),
                            ButtonSegment(
                              value: PriceBasis.total,
                              label: Text(tr.orderPriceTotal),
                            ),
                          ],
                          selected: {_basis},
                          onSelectionChanged: (s) =>
                              setState(() => _basis = s.first),
                        ),
                      ],
                      const SizedBox(height: AppSpace.sm),
                      MoneyField(
                        key: const ValueKey('order-price'),
                        controller: _price,
                        onChanged: (_) => setState(() {}),
                        label: _quantity > 1
                            ? (_basis == PriceBasis.total
                                  ? tr.orderPriceTotalLabel
                                  : tr.orderPriceEachLabel)
                            : tr.entryPriceValue,
                        helper: _priceHelper(),
                        errorText: problems.contains(OrderProblem.priceMissing)
                            ? tr.orderErrPrice
                            : null,
                      ),
                    ] else
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpace.sm),
                        child: Text(
                          _priceKind == PriceKind.complimentary
                              ? tr.entryComplimentaryNote(formatCents(0))
                              : tr.entryNoPriceNote,
                          style: AppText.caption,
                        ),
                      ),
                    if (_at != null)
                      ListTile(
                        key: const ValueKey('order-time'),
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.schedule_rounded),
                        title: Text(tr.entryTimeSection),
                        subtitle: Text(formatDateTime(_at!)),
                        trailing: const Icon(Icons.edit_outlined, size: 18),
                        onTap: _pickTime,
                      ),
                    SectionTitle(tr.orderWhoConsumed),
                    Text(tr.orderConsumedHint, style: AppText.caption),
                    const SizedBox(height: AppSpace.sm),
                    _PeoplePicker(
                      keyPrefix: 'consumer',
                      people: _people,
                      selected: _consumers,
                      onToggle: _toggleConsumer,
                    ),
                    if (problems.contains(OrderProblem.nobodyConsumed))
                      _error(tr.orderErrNobodyConsumed),
                    if (_kind.isDrink &&
                        _quantity > 1 &&
                        _consumers.length > 1) ...[
                      SwitchListTile(
                        key: const ValueKey('units-switch'),
                        contentPadding: EdgeInsets.zero,
                        title: Text(tr.orderUnitsPerPerson),
                        subtitle: Text(tr.orderUnitsHint),
                        value: _unitsMode,
                        activeThumbColor: AppColors.amber,
                        onChanged: (v) => setState(() {
                          _unitsMode = v;
                          if (v) _rebalanceUnits();
                        }),
                      ),
                      if (_unitsMode)
                        for (final id in _consumers)
                          _UnitsRow(
                            person: widget.doc.participant(id)!,
                            count: _units[id] ?? 0,
                            onMinus: () => _stepUnit(id, -1),
                            onPlus: () => _stepUnit(id, 1),
                          ),
                      if (problems.contains(OrderProblem.unitsMismatch))
                        _error(tr.orderErrUnits(_quantity)),
                    ],
                    SectionTitle(tr.orderWhoPays),
                    Text(tr.orderPayersHint, style: AppText.caption),
                    const SizedBox(height: AppSpace.sm),
                    _PeoplePicker(
                      keyPrefix: 'payer',
                      people: _people,
                      selected: _payers,
                      onToggle: _togglePayer,
                    ),
                    if (problems.contains(OrderProblem.nobodyPays))
                      _error(tr.orderErrNobodyPays),
                    if (_payers.length > 1) ...[
                      const SizedBox(height: AppSpace.sm),
                      SegmentedButton<bool>(
                        key: const ValueKey('payer-mode'),
                        showSelectedIcon: false,
                        segments: [
                          ButtonSegment(
                            value: false,
                            label: Text(tr.orderPayEqual),
                          ),
                          ButtonSegment(
                            value: true,
                            label: Text(tr.orderPayCustom),
                          ),
                        ],
                        selected: {_customPayers},
                        onSelectionChanged: (s) => _setCustom(s.first),
                      ),
                      if (_customPayers) ..._customFields(input, problems),
                    ],
                    if (amounts != null && _payers.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpace.sm),
                        child: Text(
                          [
                            for (final id in _payers)
                              tr.orderPayerBears(
                                widget.doc.participant(id)?.displayName ?? '?',
                                formatCents(amounts[id] ?? 0),
                              ),
                          ].join(' · '),
                          key: const ValueKey('payer-summary'),
                          style: AppText.caption,
                        ),
                      )
                    else if (_priceKind == PriceKind.unknown)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpace.sm),
                        child: Text(
                          tr.orderPayersPending,
                          style: AppText.caption,
                        ),
                      ),
                    const SizedBox(height: AppSpace.md),
                    if (!_editing)
                      OutlinedButton.icon(
                        key: const ValueKey('order-catalog'),
                        onPressed: _openCatalog,
                        icon: const Icon(Icons.menu_book_outlined),
                        label: Text(tr.orderOpenCatalog),
                      ),
                  ],
                ),
              ),
              BottomActionBar(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_consumers.isNotEmpty && text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpace.sm),
                        child: Text(
                          [
                            '${tr.orderSummaryFor(_namesOf(_consumers))} · $text',
                            if (_payers.isNotEmpty)
                              tr.orderSummaryPays(_namesOf(_payers)),
                          ].join(' · '),
                          key: const ValueKey('order-summary'),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.caption,
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        key: const ValueKey('order-save'),
                        onPressed: _saving ? null : _save,
                        icon: const Icon(Icons.check_rounded),
                        label: Text(_editing ? tr.orderSaveEdit : tr.orderSave),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// A record that came from the lock screen says so, with the tap time; the
  /// tap time never changes, even when the time of the record is corrected.
  List<Widget> _originNote() {
    final origin = _template?.entryOrigin;
    if (!_editing || origin == null || !origin.isLockScreen) return const [];
    final corrected = _template!.timeCorrected || _at != _originalAt;
    final tap = formatTime(origin.tappedAt);
    return [
      const SizedBox(height: AppSpace.sm),
      InfoPill(
        '${tr.entryFromLockScreen}. ${corrected ? tr.entryOriginalTapCorrected(tap) : tr.entryOriginalTap(tap)}',
        icon: Icons.lock_clock_outlined,
      ),
    ];
  }

  List<Widget> _customFields(OrderInput input, Set<OrderProblem> problems) {
    final total = input.totalCents;
    var sum = 0;
    for (final id in _payers) {
      sum += parseCents(_ctl(id).text) ?? 0;
    }
    final known = total != null && _priceKind == PriceKind.informed;
    final diff = known ? total - sum : 0;
    return [
      for (final id in _payers)
        Padding(
          padding: const EdgeInsets.only(top: AppSpace.sm),
          child: MoneyField(
            key: ValueKey('payer-amount-$id'),
            controller: _ctl(id),
            label: tr.orderPayerAmountLabel(
              widget.doc.participant(id)?.displayName ?? '?',
            ),
            helper: '',
            onChanged: (_) => setState(() {}),
          ),
        ),
      if (known)
        Padding(
          padding: const EdgeInsets.only(top: AppSpace.xs),
          child: Text(
            diff == 0
                ? tr.orderPayersExact
                : (diff > 0
                      ? tr.orderPayersMissing(formatCents(diff))
                      : tr.orderPayersOver(formatCents(-diff))),
            key: const ValueKey('payer-diff'),
            style: TextStyle(
              color: diff == 0 ? AppColors.textMuted : AppColors.danger,
            ),
          ),
        ),
      if (problems.contains(OrderProblem.payersSum))
        _error(tr.orderErrPayersSum),
    ];
  }

  IconData _kindIcon(OrderKind k) => switch (k) {
    OrderKind.alcoholic => Icons.local_bar_outlined,
    OrderKind.soft => Icons.emoji_food_beverage_rounded,
    OrderKind.food => Icons.restaurant_rounded,
    OrderKind.other => Icons.receipt_long_outlined,
  };

  String _kindLabel(OrderKind k) => switch (k) {
    OrderKind.alcoholic => tr.orderKindAlcoholic,
    OrderKind.soft => tr.orderKindSoft,
    OrderKind.food => tr.orderKindFood,
    OrderKind.other => tr.orderKindOther,
  };

  Widget _error(String text) => Padding(
    padding: const EdgeInsets.only(top: AppSpace.xs),
    child: Text(text, style: const TextStyle(color: AppColors.danger)),
  );
}

class _PeoplePicker extends StatelessWidget {
  const _PeoplePicker({
    required this.keyPrefix,
    required this.people,
    required this.selected,
    required this.onToggle,
  });

  final String keyPrefix;
  final List<Participant> people;
  final List<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpace.sm,
      runSpacing: AppSpace.sm,
      children: [
        for (final p in people)
          FilterChip(
            key: ValueKey('$keyPrefix-${p.id}'),
            avatar: PersonAvatar(person: p, size: 22),
            label: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 180),
              child: Text(
                p.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            selected: selected.contains(p.id),
            onSelected: (_) => onToggle(p.id),
          ),
      ],
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    super.key,
    required this.value,
    required this.onMinus,
    required this.onPlus,
    required this.minusTip,
    required this.plusTip,
  });

  final int value;
  final VoidCallback? onMinus;
  final VoidCallback? onPlus;
  final String minusTip;
  final String plusTip;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: minusTip,
          onPressed: onMinus,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        SizedBox(
          width: 48,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: AppText.title,
          ),
        ),
        IconButton(
          tooltip: plusTip,
          onPressed: onPlus,
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }
}

class _UnitsRow extends StatelessWidget {
  const _UnitsRow({
    required this.person,
    required this.count,
    required this.onMinus,
    required this.onPlus,
  });

  final Participant person;
  final int count;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.sm),
      child: Row(
        key: ValueKey('units-${person.id}'),
        children: [
          PersonAvatar(person: person, size: 28),
          const SizedBox(width: AppSpace.sm),
          Expanded(
            child: Text(
              person.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.subtitle,
            ),
          ),
          IconButton(
            tooltip: tr.orderLess(person.displayName),
            onPressed: count > 0 ? onMinus : null,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          SizedBox(
            width: 32,
            child: Text(
              '$count',
              textAlign: TextAlign.center,
              style: AppText.title,
            ),
          ),
          IconButton(
            tooltip: tr.orderMore(person.displayName),
            onPressed: onPlus,
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }
}
