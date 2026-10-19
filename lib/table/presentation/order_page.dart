import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/money_field.dart';
import '../../drinks/data/drink_repository.dart';
import '../../drinks/domain/catalog_item.dart';
import '../../drinks/domain/common_sizes.dart';
import '../../drinks/domain/drink_category.dart';
import '../../drinks/domain/drink_entry.dart';
import '../../drinks/domain/recipe.dart';
import '../../drinks/presentation/add_drink_page.dart';
import '../../l10n/l10n.dart';
import '../../tab/data/tab_repository.dart';
import '../../tab/domain/tab_models.dart';
import '../domain/order_builder.dart';
import '../domain/table_orders.dart';
import 'person_avatar.dart';

/// "New order": what was ordered, for whom and how many, and the price. A
/// free name is enough (no volume, ABV or recipe needed); the catalog only
/// helps to fill things in. Pops with the saved records.
class OrderPage extends StatefulWidget {
  const OrderPage({
    super.key,
    required this.outingId,
    required this.doc,
    this.preselected = const {},
    this.initialText = '',
  });

  final String outingId;
  final TabDoc doc;

  /// People marked from the start (the person being viewed). Empty on the
  /// whole-table view: nothing is assumed, the person must be chosen.
  final Set<String> preselected;
  final String initialText;

  static Future<List<DrinkEntry>?> open(
    BuildContext context, {
    required String outingId,
    required PersonFilter filter,
    String initialText = '',
  }) {
    final doc = getIt<TabRepository>().load(outingId);
    return Navigator.of(context).push<List<DrinkEntry>>(
      MaterialPageRoute(
        builder: (_) => OrderPage(
          outingId: outingId,
          doc: doc,
          preselected: TableOrders.preselect(doc, filter),
          initialText: initialText,
        ),
      ),
    );
  }

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  static const _kinds = [
    DrinkCategory.draft,
    DrinkCategory.beer,
    DrinkCategory.cocktail,
    DrinkCategory.wine,
    DrinkCategory.spirit,
    DrinkCategory.readyToDrink,
    DrinkCategory.nonAlcoholic,
    DrinkCategory.water,
  ];

  late final TextEditingController _name = TextEditingController(
    text: widget.initialText,
  );
  final _price = TextEditingController();
  final _volume = TextEditingController();
  final _abv = TextEditingController();
  final _leftover = TextEditingController();
  final _portionCtl = <String, TextEditingController>{};

  late DrinkCategory _category = DrinkCategory.draft;
  CatalogItem? _item;
  bool _useRecipe = false;
  String? _presentationLabel;

  /// Individual order: person -> servings.
  late final Map<String, int> _units = {
    for (final id in widget.preselected)
      if (widget.doc.participant(id) != null) id: 1,
  };

  bool _shared = false;
  final _sharers = <String>{};
  int _bottles = 1;

  PriceKind _kind = PriceKind.informed;
  PriceBasis _basis = PriceBasis.unit;

  bool _showErrors = false;

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _volume.dispose();
    _abv.dispose();
    _leftover.dispose();
    for (final c in _portionCtl.values) {
      c.dispose();
    }
    super.dispose();
  }

  String get _ownerId => widget.doc.me?.id ?? '';

  List<Participant> get _people => widget.doc.present;

  int? get _priceCents {
    final t = _price.text.trim();
    return t.isEmpty ? null : parseCents(t);
  }

  int? get _volumeMl => parseInteger(_volume.text);

  double? get _abvPercent {
    final t = _abv.text.trim();
    return t.isEmpty ? null : parseDecimal(t);
  }

  int get _leftoverMl => parseInteger(_leftover.text) ?? 0;

  TextEditingController _ctl(String id) =>
      _portionCtl.putIfAbsent(id, () => TextEditingController());

  Map<String, int?> get _portions => {
    for (final id in _sharers) id: parseInteger(_ctl(id).text),
  };

  OrderInput _input() {
    final item = _item;
    final recipe = item?.recipe;
    return OrderInput(
      outingId: widget.outingId,
      name: _name.text,
      category: _category,
      ownerId: _ownerId,
      at: DateTime.now(),
      units: _units,
      shared: _shared,
      portions: _shared ? _portions : const {},
      bottles: _bottles,
      leftoverMl: _leftoverMl,
      priceKind: _kind,
      priceCents: _priceCents,
      basis: _shared ? PriceBasis.unit : _basis,
      containerMl: _volumeMl,
      abvPercent: _abvPercent,
      abvSource: null,
      brand: item?.brand,
      style: item?.style,
      presentation: _presentationLabel,
      catalogItemId: item?.id,
      composition: _useRecipe && recipe != null
          ? Composition(
              recipeId: recipe.id,
              recipeName: item!.name,
              sourceLabel: recipe.source?.displayLabel,
              sourceUrl: recipe.source?.url,
              components: recipe.components,
            )
          : null,
    );
  }

  List<CatalogItem> _suggestions() {
    final q = searchKey(_name.text);
    if (_item != null || q.length < 2) return const [];
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
      return normalizeText(a.displayName).compareTo(normalizeText(b.displayName));
    });
    return hits.take(6).toList();
  }

  void _pick(CatalogItem item) {
    setState(() {
      _item = item;
      _name.text = item.displayName;
      _category = item.category;
      _useRecipe = false;
      _presentationLabel = null;
      _abv.text = item.abvPercent == null ? '' : '${item.abvPercent}';
      final docs = item.documentedPresentations;
      if (docs.length == 1) {
        _volume.text = '${docs.first.volumeMl}';
        _presentationLabel = docs.first.label;
      }
    });
  }

  void _clearItem() => setState(() {
    _item = null;
    _useRecipe = false;
    _presentationLabel = null;
  });

  void _toggleUnits(String id) => setState(() {
    if (_units.containsKey(id)) {
      _units.remove(id);
    } else {
      _units[id] = 1;
    }
  });

  void _step(String id, int delta) => setState(() {
    final next = ((_units[id] ?? 1) + delta).clamp(1, OrderBuilder.maxPerPerson);
    _units[id] = next.toInt();
  });

  void _toggleSharer(String id) => setState(() {
    if (!_sharers.add(id)) _sharers.remove(id);
  });

  void _divideEqually() => setState(() {
    final eq = OrderBuilder.equalPortions(
      _sharers.toList(),
      _volumeMl,
      _leftoverMl,
    );
    for (final kv in eq.entries) {
      _ctl(kv.key).text = kv.value == null ? '' : '${kv.value}';
    }
  });

  String _namesOf(Iterable<String> ids) => [
    for (final id in ids) widget.doc.participant(id)?.displayName ?? '?',
  ].join(', ');

  int get _servings =>
      _shared ? _bottles : _units.values.fold(0, (a, b) => a + b);

  String? _summaryLine() {
    final cents = _priceCents;
    if (_kind != PriceKind.informed || cents == null || _servings <= 0) {
      return null;
    }
    if (_shared) return tr.orderSplitEach(formatCents(cents ~/ (_sharers.isEmpty ? 1 : _sharers.length)));
    if (_servings == 1) return null;
    return _basis == PriceBasis.unit
        ? tr.orderLineSummary(_servings, formatCents(cents), formatCents(cents * _servings))
        : tr.orderLineSummary(_servings, formatCents((cents / _servings).round()), formatCents(cents));
  }

  /// The full catalog, label or menu reading: the person already chosen is
  /// carried along; with none or several chosen the form asks.
  Future<void> _openCatalog() async {
    final ids = _units.keys.toList();
    final single = !_shared && ids.length == 1 ? ids.first : null;
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddDrinkPage(
          outingId: widget.outingId,
          consumerId: single == null || single == _ownerId ? null : single,
          choosePerson: single == null,
        ),
      ),
    );
    // Saved over there: the outing page only needs to know something was added.
    if (saved == true && mounted) Navigator.of(context).pop(<DrinkEntry>[]);
  }

  Future<void> _save() async {
    final problems = OrderBuilder.problems(_input());
    if (problems.isNotEmpty) {
      setState(() => _showErrors = true);
      return;
    }
    final repo = getIt<DrinkRepository>();
    final list = OrderBuilder.build(_input(), newId: repo.newId);
    await repo.saveAll(list);
    if (mounted) Navigator.of(context).pop(list);
  }

  @override
  Widget build(BuildContext context) {
    final problems = _showErrors ? OrderBuilder.problems(_input()) : const <OrderProblem>{};
    final suggestions = _suggestions();
    final item = _item;
    final text = _name.text.trim();
    final sizes = item != null && item.documentedPresentations.isNotEmpty
        ? item.documentedPresentations
        : commonSizesFor(_category);
    final who = _shared ? _sharers : _units.keys;
    return Scaffold(
      appBar: AppBar(title: Text(tr.orderTitle)),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.gutter,
                  0,
                  AppSpace.gutter,
                  AppSpace.xl,
                ),
                children: [
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
                        _useRecipe = false;
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
                              constraints: const BoxConstraints(maxWidth: 200),
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
                  ]
                  else if (text.length >= 2)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpace.sm),
                      child: Text(tr.orderNotInCatalog(_name.text.trim()), style: AppText.caption),
                    ),
                  const SizedBox(height: AppSpace.md),
                  Text(tr.orderKind, style: AppText.caption),
                  const SizedBox(height: AppSpace.sm),
                  Wrap(
                    spacing: AppSpace.sm,
                    runSpacing: AppSpace.sm,
                    children: [
                      for (final c in _kinds)
                        ChoiceChip(
                          key: ValueKey('kind-${c.code}'),
                          avatar: Icon(c.icon, size: 18),
                          label: Text(c.label),
                          selected: _category == c,
                          showCheckmark: false,
                          onSelected: (_) => setState(() => _category = c),
                        ),
                    ],
                  ),
                  SectionTitle(tr.orderFor),
                  SegmentedButton<bool>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(value: false, label: Text(tr.orderEach)),
                      ButtonSegment(value: true, label: Text(tr.orderSharedBottle)),
                    ],
                    selected: {_shared},
                    onSelectionChanged: (s) => setState(() => _shared = s.first),
                  ),
                  const SizedBox(height: AppSpace.sm),
                  Text(
                    _shared ? tr.orderSharers : tr.orderForHint,
                    style: AppText.caption,
                  ),
                  const SizedBox(height: AppSpace.sm),
                  Wrap(
                    spacing: AppSpace.sm,
                    runSpacing: AppSpace.sm,
                    children: [
                      for (final p in _people)
                        FilterChip(
                          key: ValueKey('who-${p.id}'),
                          avatar: PersonAvatar(person: p, size: 22),
                          label: Text(p.displayName),
                          selected: _shared
                              ? _sharers.contains(p.id)
                              : _units.containsKey(p.id),
                          onSelected: (_) =>
                              _shared ? _toggleSharer(p.id) : _toggleUnits(p.id),
                        ),
                    ],
                  ),
                  if (problems.contains(OrderProblem.nobodyPicked))
                    _error(tr.orderErrNobody),
                  if (problems.contains(OrderProblem.sharersNeeded))
                    _error(tr.orderErrSharers),
                  if (!_shared)
                    for (final id in _units.keys.toList())
                      _UnitsRow(
                        person: widget.doc.participant(id)!,
                        count: _units[id]!,
                        onMinus: () => _step(id, -1),
                        onPlus: () => _step(id, 1),
                        canMinus: _units[id]! > 1,
                      )
                  else ...[
                    const SizedBox(height: AppSpace.sm),
                    for (final id in _sharers)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpace.sm),
                        child: TextField(
                          key: ValueKey('portion-$id'),
                          controller: _ctl(id),
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            labelText: tr.orderPortionMl(
                              widget.doc.participant(id)?.displayName ?? '?',
                            ),
                            helperText: tr.orderPortionHint,
                          ),
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _leftover,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(labelText: tr.orderLeftover),
                          ),
                        ),
                        const SizedBox(width: AppSpace.md),
                        Column(
                          children: [
                            Text(tr.orderBottles, style: AppText.caption),
                            Row(
                              children: [
                                IconButton(
                                  tooltip: tr.orderLess(tr.orderBottles),
                                  onPressed: _bottles > 1
                                      ? () => setState(() => _bottles--)
                                      : null,
                                  icon: const Icon(Icons.remove_circle_outline),
                                ),
                                Text('$_bottles', style: AppText.subtitle),
                                IconButton(
                                  tooltip: tr.orderMore(tr.orderBottles),
                                  onPressed: () => setState(() => _bottles++),
                                  icon: const Icon(Icons.add_circle_outline),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    OutlinedButton.icon(
                      key: const ValueKey('divide-volume'),
                      onPressed: _sharers.length >= 2 ? _divideEqually : null,
                      icon: const Icon(Icons.balance_outlined),
                      label: Text(tr.orderDivideVolume),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpace.xs),
                      child: Text(tr.orderDivideNote, style: AppText.caption),
                    ),
                    if (problems.contains(OrderProblem.portionsOverBottle))
                      _error(tr.orderErrPortions),
                  ],
                  const SizedBox(height: AppSpace.md),
                  OutlinedButton.icon(
                    key: const ValueKey('order-catalog'),
                    onPressed: _openCatalog,
                    icon: const Icon(Icons.menu_book_outlined),
                    label: Text(tr.orderOpenCatalog),
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
                    selected: {_kind},
                    onSelectionChanged: (s) => setState(() => _kind = s.first),
                  ),
                  if (_kind == PriceKind.informed) ...[
                    if (!_shared && _servings > 1) ...[
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
                        onSelectionChanged: (s) => setState(() => _basis = s.first),
                      ),
                    ],
                    const SizedBox(height: AppSpace.sm),
                    MoneyField(
                      key: const ValueKey('order-price'),
                      controller: _price,
                      onChanged: (_) => setState(() {}),
                      label: _shared
                          ? tr.orderPriceBottleLabel
                          : (_servings > 1 && _basis == PriceBasis.total
                                ? tr.orderPriceTotalLabel
                                : (_servings > 1
                                      ? tr.orderPriceEachLabel
                                      : tr.entryPriceValue)),
                      helper: !_shared && _servings > 1 && _basis == PriceBasis.total
                          ? tr.orderPriceTotalHelper
                          : _summaryLine(),
                      errorText: problems.contains(OrderProblem.priceMissing)
                          ? tr.orderErrPrice
                          : null,
                    ),
                  ] else
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpace.sm),
                      child: Text(
                        _kind == PriceKind.complimentary
                            ? tr.entryComplimentaryNote(formatCents(0))
                            : tr.entryNoPriceNote,
                        style: AppText.caption,
                      ),
                    ),
                  const SizedBox(height: AppSpace.md),
                  Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      key: const ValueKey('order-details'),
                      tilePadding: EdgeInsets.zero,
                      title: Text(tr.orderDetails, style: AppText.subtitle),
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Wrap(
                            spacing: AppSpace.sm,
                            runSpacing: AppSpace.sm,
                            children: [
                              for (final p in sizes)
                                ChoiceChip(
                                  label: Text(p.label),
                                  selected: _volume.text == '${p.volumeMl}',
                                  showCheckmark: false,
                                  onSelected: (_) => setState(() {
                                    _volume.text = '${p.volumeMl}';
                                    _presentationLabel = p.isSuggestion ? null : p.label;
                                  }),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpace.xs),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(tr.orderVolumeNote, style: AppText.caption),
                        ),
                        const SizedBox(height: AppSpace.sm),
                        TextField(
                          key: const ValueKey('order-volume'),
                          controller: _volume,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() => _presentationLabel = null),
                          decoration: InputDecoration(
                            labelText: tr.orderVolume,
                            errorText: problems.contains(OrderProblem.volumeInvalid)
                                ? tr.orderErrVolume
                                : null,
                          ),
                        ),
                        const SizedBox(height: AppSpace.md),
                        TextField(
                          key: const ValueKey('order-abv'),
                          controller: _abv,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: tr.orderAbv,
                            errorText: problems.contains(OrderProblem.abvInvalid)
                                ? tr.orderErrAbv
                                : null,
                          ),
                        ),
                        if (item?.recipe != null)
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(tr.orderUseRecipe),
                            subtitle: Text(tr.orderUseRecipeNote),
                            value: _useRecipe,
                            activeThumbColor: AppColors.amber,
                            onChanged: (v) => setState(() => _useRecipe = v),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            BottomActionBar(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (who.isNotEmpty && text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpace.sm),
                      child: Text(
                        '${tr.orderSummaryFor(_namesOf(who))} · $text',
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
                      onPressed: _save,
                      icon: const Icon(Icons.check_rounded),
                      label: Text(tr.orderSave),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _error(String text) => Padding(
    padding: const EdgeInsets.only(top: AppSpace.xs),
    child: Text(text, style: const TextStyle(color: AppColors.danger)),
  );
}

class _UnitsRow extends StatelessWidget {
  const _UnitsRow({
    required this.person,
    required this.count,
    required this.onMinus,
    required this.onPlus,
    required this.canMinus,
  });

  final Participant person;
  final int count;
  final VoidCallback onMinus;
  final VoidCallback onPlus;
  final bool canMinus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.sm),
      child: Row(
        key: ValueKey('units-${person.id}'),
        children: [
          PersonAvatar(person: person, size: 28),
          const SizedBox(width: AppSpace.sm),
          Expanded(child: Text(person.displayName, style: AppText.subtitle)),
          IconButton(
            tooltip: tr.orderLess(person.displayName),
            onPressed: canMinus ? onMinus : null,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          SizedBox(
            width: 32,
            child: Text('$count', textAlign: TextAlign.center, style: AppText.title),
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
