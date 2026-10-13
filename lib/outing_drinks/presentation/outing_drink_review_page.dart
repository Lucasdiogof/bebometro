import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../drinks/data/drink_repository.dart';
import '../../drinks/domain/abv_source.dart';
import '../../drinks/domain/catalog_item.dart';
import '../../drinks/domain/drink_category.dart';
import '../../drinks/domain/recipe.dart';
import '../../outings/data/outing_repository.dart';
import '../../scan/domain/catalog_matcher.dart';
import '../../scan/domain/menu_parser.dart';
import '../../scan/presentation/photo_widgets.dart';
import '../data/outing_drink_repository.dart';
import '../domain/outing_drink.dart';

/// Values the review screen starts from (what was read, or nothing for a
/// manual sign-up). Anything null stays unknown and empty on screen.
class ReviewPrefill {
  const ReviewPrefill({
    this.name,
    this.category,
    this.brand,
    this.volumeMl,
    this.abvPercent,
    this.abvSource,
    this.ingredients,
    this.origin = OutingDrinkOrigin.manual,
    this.photoIds = const [],
    this.sourceText,
    this.notes = const [],
    this.nameCandidates = const [],
  });

  final String? name;
  final DrinkCategory? category;
  final String? brand;
  final int? volumeMl;
  final double? abvPercent;
  final AbvSource? abvSource;
  final List<String>? ingredients;
  final OutingDrinkOrigin origin;
  final List<String> photoIds;
  final String? sourceText;

  /// Doubts to show to the user (several volumes, unsure name...).
  final List<String> notes;
  final List<String> nameCandidates;
}

class ReviewResult {
  const ReviewResult(this.drink, {required this.register});

  final OutingDrink drink;

  /// "Confirmar e continuar": go on to register the consumption.
  final bool register;
}

class _CompRow {
  _CompRow(this.base)
      : name = TextEditingController(text: base.name),
        alcoholic = base.alcoholic;

  final EntryComponent base;
  final TextEditingController name;
  bool alcoholic;

  EntryComponent toComponent() =>
      base.copyWith(name: name.text.trim(), alcoholic: alcoholic);
}

/// Reviews and saves a drink that belongs to this outing only. It never
/// touches the catalog or "Minhas bebidas". Pops a [ReviewResult].
class OutingDrinkReviewPage extends StatefulWidget {
  const OutingDrinkReviewPage({
    super.key,
    required this.outingId,
    this.existing,
    this.prefill = const ReviewPrefill(),
  });

  final String outingId;

  /// Editing an item already saved in this outing.
  final OutingDrink? existing;
  final ReviewPrefill prefill;

  @override
  State<OutingDrinkReviewPage> createState() => _OutingDrinkReviewPageState();
}

class _OutingDrinkReviewPageState extends State<OutingDrinkReviewPage> {
  final _repo = getIt<OutingDrinkRepository>();
  late final String _id;
  late final TextEditingController _name;
  late final TextEditingController _brand;
  late final TextEditingController _style;
  late final TextEditingController _description;
  late final TextEditingController _volume;
  late final TextEditingController _abv;
  late final TextEditingController _ingredients;
  late final TextEditingController _price;
  final _rows = <_CompRow>[];
  DrinkCategory? _category;
  AbvSource? _abvSource;
  String? _referenceId;
  late List<String> _photoIds;
  late OutingDrinkOrigin _origin;
  String? _sourceText;
  List<CatalogMatch> _matches = const [];
  bool _searched = false;
  bool _saving = false;
  bool _showErrors = false;
  bool _dirty = false;

  OutingDrink? get _existing => widget.existing;

  @override
  void initState() {
    super.initState();
    final e = _existing;
    final p = widget.prefill;
    _id = e?.id ?? _repo.newId();
    _name = TextEditingController(text: e?.name ?? p.name ?? '');
    _brand = TextEditingController(text: e?.brand ?? p.brand ?? '');
    _style = TextEditingController(text: e?.style ?? '');
    _description = TextEditingController(text: e?.description ?? '');
    final volume = e?.volumeMl ?? p.volumeMl;
    _volume = TextEditingController(text: volume == null ? '' : '$volume');
    final abv = e != null ? e.abvPercent : p.abvPercent;
    _abv = TextEditingController(text: abv == null ? '' : decimalToInput(abv));
    final ingredients = e != null ? e.ingredients : p.ingredients;
    _ingredients = TextEditingController(text: ingredients?.join(', ') ?? '');
    _price = TextEditingController(
        text: e?.advertisedCents == null ? '' : centsToInput(e!.advertisedCents!));
    _category = e?.category ?? p.category;
    _abvSource = abv == null ? null : (e?.abvSource ?? p.abvSource);
    _referenceId = e?.referenceItemId;
    _photoIds = [...(e?.photoIds ?? p.photoIds)];
    _origin = e?.origin ?? p.origin;
    _sourceText = e?.sourceText ?? p.sourceText;
    for (final c in e?.components ?? const <EntryComponent>[]) {
      _rows.add(_CompRow(c));
    }
    for (final i in (e == null ? p.ingredients : null) ?? const <String>[]) {
      // Only drinks (cocktails) get an ingredient list; others keep the text.
      if (_category == DrinkCategory.cocktail) {
        _rows.add(_CompRow(EntryComponent(
            name: i, alcoholic: ingredientLooksAlcoholic(i))));
      }
    }
    if (_category == DrinkCategory.cocktail && _rows.isNotEmpty) {
      _ingredients.clear();
    }
    if (_name.text.trim().isNotEmpty) _search();
  }

  @override
  void dispose() {
    for (final c in [
      _name, _brand, _style, _description, _volume, _abv, _ingredients, _price
    ]) {
      c.dispose();
    }
    for (final r in _rows) {
      r.name.dispose();
    }
    super.dispose();
  }

  void _touch() {
    if (!_dirty) setState(() => _dirty = true);
  }

  void _search() {
    final query = MatchQuery(
      name: _name.text.trim(),
      brand: _brand.text.trim().isEmpty ? null : _brand.text.trim(),
      volumeMl: parseInteger(_volume.text),
      abvPercent: parseDecimal(_abv.text),
      category: _category,
      ingredients: [
        for (final r in _rows)
          if (r.name.text.trim().isNotEmpty) r.name.text.trim(),
      ],
    );
    final results = query.name.isEmpty
        ? const <CatalogMatch>[]
        : matchCatalog(getIt<DrinkRepository>().catalog(), query);
    setState(() {
      _matches = results;
      _searched = true;
    });
  }

  void _fillEmptyFrom(CatalogItem item) {
    setState(() {
      if (_name.text.trim().isEmpty) _name.text = item.name;
      if (_brand.text.trim().isEmpty && item.brand != null) {
        _brand.text = item.brand!;
      }
      if (_style.text.trim().isEmpty && item.style != null) {
        _style.text = item.style!;
      }
      _category ??= item.category;
      final docs = item.documentedPresentations;
      if (_volume.text.trim().isEmpty && docs.length == 1) {
        _volume.text = '${docs.first.volumeMl}';
      }
      if (_abv.text.trim().isEmpty && item.abvPercent != null) {
        _abv.text = decimalToInput(item.abvPercent!);
        _abvSource = AbvSource.catalog;
      }
      if (_ingredients.text.trim().isEmpty && item.ingredients != null) {
        _ingredients.text = item.ingredients!.join(', ');
      }
      _referenceId = item.id;
      _dirty = true;
    });
  }

  /// Copies only the ingredient names of a reference recipe, with unknown
  /// amounts: a menu description does not say how much of each was served.
  void _fillIngredientsFrom(CatalogItem item) {
    final recipe = item.recipe;
    if (recipe == null) return;
    setState(() {
      _category = DrinkCategory.cocktail;
      for (final c in recipe.components) {
        if (_rows.any((r) =>
            r.name.text.trim().toLowerCase() == c.name.toLowerCase())) {
          continue;
        }
        _rows.add(_CompRow(EntryComponent(
          name: c.name,
          alcoholic: c.alcoholic,
          role: c.role,
          unit: c.unit,
        )));
      }
      _referenceId = item.id;
      _dirty = true;
    });
  }

  String? _validate() {
    if (_name.text.trim().isEmpty) return 'Dê um nome para a bebida.';
    if (_category == null) return 'Escolha o tipo da bebida.';
    final vol = _volume.text.trim();
    if (vol.isNotEmpty && (parseInteger(vol) ?? 0) <= 0) {
      return 'O volume precisa ser maior que zero.';
    }
    final abv = _abv.text.trim();
    if (abv.isNotEmpty) {
      final v = parseDecimal(abv);
      if (v == null || v < 0 || v > 100) return 'O teor vai de 0 a 100%.';
    }
    final price = _price.text.trim();
    if (price.isNotEmpty && parseCents(price) == null) {
      return 'Preço inválido.';
    }
    return null;
  }

  String? _clean(String text) => text.trim().isEmpty ? null : text.trim();

  Future<void> _save({required bool register}) async {
    if (_saving) return;
    final problem = _validate();
    if (problem != null) {
      setState(() => _showErrors = true);
      showToast(context, problem);
      return;
    }
    setState(() => _saving = true);
    try {
      final now = DateTime.now();
      final cocktail = _category == DrinkCategory.cocktail;
      final comps = cocktail && _rows.isNotEmpty
          ? [for (final r in _rows) r.toComponent()]
          : null;
      final abv = parseDecimal(_abv.text);
      final ingredientList = (comps == null && _ingredients.text.trim().isNotEmpty)
          ? _ingredients.text
              .split(RegExp(r'[,;\n]'))
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList()
          : null;
      final volume = parseInteger(_volume.text);
      // Only photos that still exist are linked: a lost file (web session
      // ended) leaves the structured data intact and simply has no photo.
      final photoIds = await _repo.existingPhotos(_photoIds);
      final drink = OutingDrink(
        id: _id,
        outingId: widget.outingId,
        name: _name.text.trim(),
        category: _category!,
        origin: _origin,
        brand: _clean(_brand.text),
        style: _clean(_style.text),
        description: _clean(_description.text),
        volumeMl: volume,
        abvPercent: abv,
        abvSource: abv == null ? null : (_abvSource ?? AbvSource.typed),
        ingredients: ingredientList,
        components: comps,
        referenceItemId: _referenceId,
        advertisedCents: parseCents(_price.text),
        photoIds: photoIds,
        sourceText: _sourceText,
        createdAt: _existing?.createdAt ?? now,
        updatedAt: now,
      );
      await _repo.confirmPhotos(
        widget.outingId,
        _origin == OutingDrinkOrigin.menu
            ? OutingPhotoKind.menu
            : OutingPhotoKind.label,
        photoIds,
      );
      await _repo.save(drink);
      if (mounted) {
        Navigator.of(context).pop(ReviewResult(drink, register: register));
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      showToast(context, 'Não foi possível salvar. Seus dados continuam aqui.');
    }
  }

  Future<void> _confirmDiscard() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Descartar alterações?'),
        content: const Text('O que você preencheu aqui será perdido.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Continuar editando')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Descartar',
                  style: TextStyle(color: AppColors.danger))),
        ],
      ),
    );
    if (leave == true && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final editing = _existing != null;
    final outing = getIt<OutingRepository>().byId(widget.outingId);
    final ended = outing?.endedAt != null;
    final abvFieldVisible = _category?.canBeAlcoholic ?? true;
    final cocktail = _category == DrinkCategory.cocktail;
    final notes = widget.prefill.notes;
    return PopScope(
      canPop: !_dirty || _saving,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmDiscard();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(editing ? 'Editar bebida do rolê' : 'Bebida deste rolê'),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                    AppSpace.gutter, 0, AppSpace.gutter, AppSpace.xl),
                children: [
                  const Text(
                    'Esta bebida existe só neste rolê. Ela não entra no '
                    'catálogo, nem em Minhas bebidas, nem em outros rolês.',
                    style: AppText.caption,
                  ),
                  if (ended) ...[
                    const SizedBox(height: AppSpace.sm),
                    const InfoPill(
                      'Este rolê já foi encerrado. O item fica salvo nele.',
                      icon: Icons.info_outline_rounded,
                      warning: true,
                    ),
                  ],
                  if (_photoIds.isNotEmpty) ...[
                    const SectionTitle('Foto'),
                    SizedBox(
                      height: 88,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          for (final id in _photoIds)
                            Padding(
                              padding: const EdgeInsets.only(right: AppSpace.sm),
                              child: PhotoThumb(
                                photoId: id,
                                size: 88,
                                onTap: () =>
                                    showPhotoViewer(context, photoId: id),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                  if (notes.isNotEmpty) ...[
                    const SizedBox(height: AppSpace.md),
                    for (final n in notes)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpace.xs),
                        child: InfoPill(n,
                            icon: Icons.help_outline_rounded, warning: true),
                      ),
                  ],
                  const SectionTitle('Bebida'),
                  TextField(
                    controller: _name,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => _touch(),
                    decoration: InputDecoration(
                      labelText: 'Nome da bebida',
                      errorText: _showErrors && _name.text.trim().isEmpty
                          ? 'Dê um nome para a bebida'
                          : null,
                    ),
                  ),
                  if (widget.prefill.nameCandidates.length > 1) ...[
                    const SizedBox(height: AppSpace.sm),
                    const Text('Outras linhas lidas (toque para usar):',
                        style: AppText.caption),
                    const SizedBox(height: AppSpace.xs),
                    Wrap(
                      spacing: AppSpace.sm,
                      runSpacing: AppSpace.xs,
                      children: [
                        for (final c in widget.prefill.nameCandidates)
                          ActionChip(
                            label: Text(c),
                            onPressed: () => setState(() {
                              _name.text = c;
                              _dirty = true;
                            }),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSpace.md),
                  Wrap(
                    spacing: AppSpace.sm,
                    runSpacing: AppSpace.sm,
                    children: [
                      for (final c in DrinkCategory.values)
                        ChoiceChip(
                          label: Text(c.label),
                          selected: _category == c,
                          showCheckmark: false,
                          onSelected: (_) => setState(() {
                            _category = c;
                            _dirty = true;
                          }),
                        ),
                    ],
                  ),
                  if (_showErrors && _category == null)
                    const Padding(
                      padding: EdgeInsets.only(top: AppSpace.xs),
                      child: Text('Escolha o tipo da bebida',
                          style: TextStyle(color: AppColors.danger, fontSize: 12)),
                    )
                  else if (_category == null)
                    const Padding(
                      padding: EdgeInsets.only(top: AppSpace.xs),
                      child: Text('Tipo não identificado: escolha um.',
                          style: AppText.caption),
                    ),
                  const SizedBox(height: AppSpace.md),
                  TextField(
                    controller: _brand,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => _touch(),
                    decoration:
                        const InputDecoration(labelText: 'Marca (opcional)'),
                  ),
                  const SizedBox(height: AppSpace.md),
                  TextField(
                    controller: _style,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => _touch(),
                    decoration:
                        const InputDecoration(labelText: 'Estilo (opcional)'),
                  ),
                  if (_origin == OutingDrinkOrigin.menu ||
                      _description.text.isNotEmpty) ...[
                    const SizedBox(height: AppSpace.md),
                    TextField(
                      controller: _description,
                      minLines: 1,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (_) => _touch(),
                      decoration: const InputDecoration(
                          labelText: 'Descrição do cardápio (opcional)'),
                    ),
                  ],
                  const SectionTitle('Tamanho e teor'),
                  TextField(
                    controller: _volume,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _touch(),
                    decoration: const InputDecoration(
                      labelText: 'Volume da embalagem (opcional)',
                      suffixText: 'ml',
                      helperText:
                          'É o tamanho do produto, não o quanto você bebeu. '
                          'Em branco = desconhecido.',
                      helperMaxLines: 2,
                    ),
                  ),
                  if (abvFieldVisible && !cocktail) ...[
                    const SizedBox(height: AppSpace.md),
                    TextField(
                      controller: _abv,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (v) => setState(() {
                        _abvSource = v.trim().isEmpty ? null : AbvSource.typed;
                        _dirty = true;
                      }),
                      decoration: InputDecoration(
                        labelText: 'Teor alcoólico (opcional)',
                        suffixText: '% vol.',
                        helperText: _abv.text.trim().isEmpty
                            ? 'Em branco = desconhecido, não conta como zero.'
                            : 'Origem: ${(_abvSource ?? AbvSource.typed).label}',
                        helperMaxLines: 2,
                      ),
                    ),
                  ],
                  if (cocktail) ...[
                    const SectionTitle('Ingredientes'),
                    const Text(
                      'Só o que o cardápio ou você informaram. As quantidades '
                      'ficam desconhecidas até você completar ao registrar; '
                      'o álcool só é calculado com volume e teor conhecidos.',
                      style: AppText.caption,
                    ),
                    const SizedBox(height: AppSpace.sm),
                    for (var i = 0; i < _rows.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpace.sm),
                        child: Row(children: [
                          Expanded(
                            child: TextField(
                              controller: _rows[i].name,
                              onChanged: (_) => _touch(),
                              decoration:
                                  const InputDecoration(labelText: 'Ingrediente'),
                            ),
                          ),
                          const SizedBox(width: AppSpace.sm),
                          FilterChip(
                            label: const Text('Álcool'),
                            selected: _rows[i].alcoholic,
                            showCheckmark: false,
                            onSelected: (v) => setState(() {
                              _rows[i].alcoholic = v;
                              _dirty = true;
                            }),
                          ),
                          IconButton(
                            tooltip: 'Remover ingrediente',
                            onPressed: () => setState(() {
                              _rows.removeAt(i).name.dispose();
                              _dirty = true;
                            }),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ]),
                      ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => setState(() {
                          _rows.add(_CompRow(
                              const EntryComponent(name: '', alcoholic: false)));
                          _dirty = true;
                        }),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Adicionar ingrediente'),
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: AppSpace.md),
                    TextField(
                      controller: _ingredients,
                      minLines: 1,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (_) => _touch(),
                      decoration: const InputDecoration(
                        labelText: 'Ingredientes declarados (opcional)',
                        helperText: 'Separe por vírgula. Só o que está escrito.',
                        helperMaxLines: 2,
                      ),
                    ),
                  ],
                  if (_origin == OutingDrinkOrigin.menu ||
                      _existing?.advertisedCents != null) ...[
                    const SectionTitle('Preço anunciado'),
                    TextField(
                      controller: _price,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => _touch(),
                      decoration: const InputDecoration(
                        labelText: 'Preço do cardápio (opcional)',
                        prefixText: r'R$ ',
                        helperText:
                            'Só uma sugestão: ao registrar você confirma o que pagou.',
                        helperMaxLines: 2,
                      ),
                    ),
                  ],
                  SectionTitle('Parecidas no catálogo',
                      trailing: TextButton(
                        onPressed: _name.text.trim().isEmpty ? null : _search,
                        child: const Text('Buscar'),
                      )),
                  const Text(
                    'Opcional. Escolher uma é só uma referência: o produto do '
                    'catálogo nunca é alterado e nada é ligado sozinho.',
                    style: AppText.caption,
                  ),
                  const SizedBox(height: AppSpace.sm),
                  if (_searched && _matches.isEmpty)
                    const Text('Nada parecido encontrado. Este item fica só no rolê.',
                        style: AppText.caption),
                  for (final m in _matches)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpace.sm),
                      child: SurfaceCard(
                        selected: _referenceId == m.item.id,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m.item.displayName, style: AppText.subtitle),
                            Text(m.item.subtitle, style: AppText.caption),
                            const SizedBox(height: AppSpace.xs),
                            for (final n in m.notes)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      n.difference
                                          ? Icons.warning_amber_rounded
                                          : Icons.check_rounded,
                                      size: 16,
                                      color: n.difference
                                          ? AppColors.amber
                                          : AppColors.success,
                                    ),
                                    const SizedBox(width: AppSpace.xs),
                                    Expanded(
                                        child: Text(n.text, style: AppText.caption)),
                                  ],
                                ),
                              ),
                            const SizedBox(height: AppSpace.sm),
                            Wrap(spacing: AppSpace.sm, children: [
                              OutlinedButton(
                                onPressed: () => setState(() {
                                  _referenceId =
                                      _referenceId == m.item.id ? null : m.item.id;
                                  _dirty = true;
                                }),
                                child: Text(_referenceId == m.item.id
                                    ? 'Referência escolhida'
                                    : 'Usar como referência'),
                              ),
                              TextButton(
                                onPressed: () => _fillEmptyFrom(m.item),
                                child: const Text('Preencher campos vazios'),
                              ),
                              if (m.item.isRecipe)
                                TextButton(
                                  onPressed: () => _fillIngredientsFrom(m.item),
                                  child: const Text(
                                      'Copiar ingredientes (sem quantidades)'),
                                ),
                            ]),
                          ],
                        ),
                      ),
                    ),
                  const SectionTitle('Origem dos dados'),
                  SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_origin.label, style: AppText.subtitle),
                        const SizedBox(height: AppSpace.xs),
                        Text(
                          _origin == OutingDrinkOrigin.manual
                              ? 'Preenchido por você.'
                              : 'Lido da foto e conferido por você. Leitura '
                                  'automática pode errar: confira cada campo.',
                          style: AppText.caption,
                        ),
                        if (_referenceId != null)
                          const Padding(
                            padding: EdgeInsets.only(top: AppSpace.xs),
                            child: Text('Com referência do catálogo (não é o '
                                'mesmo registro).',
                                style: AppText.caption),
                          ),
                      ],
                    ),
                  ),
                  if (_sourceText != null && _sourceText!.trim().isNotEmpty)
                    Theme(
                      data: Theme.of(context)
                          .copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: const Text('Texto lido na foto',
                            style: AppText.subtitle),
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: SelectableText(_sourceText!,
                                style: AppText.caption),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            BottomActionBar(
              child: editing
                  ? FilledButton(
                      onPressed: _saving ? null : () => _save(register: false),
                      child: const Text('Salvar alterações'),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FilledButton(
                          onPressed: _saving ? null : () => _save(register: true),
                          child: const Text('Confirmar e continuar'),
                        ),
                        const SizedBox(height: AppSpace.sm),
                        OutlinedButton(
                          onPressed: _saving ? null : () => _save(register: false),
                          child: const Text('Salvar só neste rolê'),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
