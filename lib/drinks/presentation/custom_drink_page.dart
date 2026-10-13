import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../data/drink_repository.dart';
import '../domain/catalog_item.dart';
import '../domain/drink_category.dart';

/// Creates a reusable personal drink, or edits one ([editing]). Pops the
/// saved [CatalogItem]. Editing never changes records already made.
class CustomDrinkPage extends StatefulWidget {
  const CustomDrinkPage({super.key, this.initialName = '', this.editing});

  /// Pre-fills the name, e.g. with what the user was searching for.
  final String initialName;
  final CatalogItem? editing;

  @override
  State<CustomDrinkPage> createState() => _CustomDrinkPageState();
}

class _CustomDrinkPageState extends State<CustomDrinkPage> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _brand;
  late final TextEditingController _style;
  late final TextEditingController _volume;
  late final TextEditingController _abv;
  late final TextEditingController _ingredients;
  late DrinkCategory _category;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    _name = TextEditingController(text: e?.name ?? widget.initialName);
    _brand = TextEditingController(text: e?.brand ?? '');
    _style = TextEditingController(text: e?.style ?? '');
    _volume = TextEditingController(
      text: e == null || e.presentations.isEmpty
          ? ''
          : '${e.presentations.first.volumeMl}',
    );
    _abv = TextEditingController(
      text: e?.abvPercent == null ? '' : decimalToInput(e!.abvPercent!),
    );
    _ingredients = TextEditingController(text: e?.ingredients?.join(', ') ?? '');
    _category = e?.category ?? DrinkCategory.beer;
  }

  @override
  void dispose() {
    _name.dispose();
    _brand.dispose();
    _style.dispose();
    _volume.dispose();
    _abv.dispose();
    _ingredients.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final item = await getIt<DrinkRepository>().saveCustomDrink(
        itemId: widget.editing?.id,
        name: _name.text,
        category: _category,
        brand: _brand.text,
        style: _style.text,
        volumeMl: parseInteger(_volume.text)!,
        abvPercent: parseDecimal(_abv.text),
        ingredients: _ingredients.text.split(RegExp(r'[,;\n]')),
      );
      if (mounted) Navigator.of(context).pop(item);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      showToast(context, 'Não foi possível salvar. Seus dados continuam aqui.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.editing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? 'Editar bebida' : 'Cadastrar bebida'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: _form,
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                    AppSpace.gutter, 0, AppSpace.gutter, AppSpace.xl),
                children: [
                  Text(
                    editing
                        ? 'As mudanças valem para os próximos registros. O '
                            'que você já registrou continua como estava.'
                        : 'Fica salva para você usar de novo nos próximos rolês.',
                    style: AppText.caption,
                  ),
                  const SectionTitle('Tipo'),
                  Wrap(
                    spacing: AppSpace.sm,
                    runSpacing: AppSpace.sm,
                    children: [
                      for (final c in DrinkCategory.values)
                        ChoiceChip(
                          label: Text(c.label),
                          selected: _category == c,
                          showCheckmark: false,
                          onSelected: (_) => setState(() => _category = c),
                        ),
                    ],
                  ),
                  const SectionTitle('Identificação'),
                  TextFormField(
                    controller: _name,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    decoration:
                        const InputDecoration(labelText: 'Nome da bebida'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Dê um nome para a bebida'
                        : null,
                  ),
                  const SizedBox(height: AppSpace.md),
                  TextFormField(
                    controller: _brand,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration:
                        const InputDecoration(labelText: 'Marca (opcional)'),
                  ),
                  const SizedBox(height: AppSpace.md),
                  TextFormField(
                    controller: _style,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.next,
                    decoration:
                        const InputDecoration(labelText: 'Estilo (opcional)'),
                  ),
                  const SectionTitle('Tamanho e teor'),
                  TextFormField(
                    controller: _volume,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Tamanho (ml)',
                      suffixText: 'ml',
                    ),
                    validator: (v) {
                      final ml = parseInteger(v ?? '');
                      return (ml == null || ml <= 0)
                          ? 'Informe o tamanho em ml'
                          : null;
                    },
                  ),
                  if (_category.canBeAlcoholic) ...[
                    const SizedBox(height: AppSpace.md),
                    TextFormField(
                      controller: _abv,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Teor alcoólico (opcional)',
                        suffixText: '% vol.',
                        helperText:
                            'Em branco = desconhecido, não conta como zero.',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        final abv = parseDecimal(v);
                        return (abv == null || abv < 0 || abv > 100)
                            ? 'O teor vai de 0 a 100%'
                            : null;
                      },
                    ),
                  ],
                  const SizedBox(height: AppSpace.md),
                  TextFormField(
                    controller: _ingredients,
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 1,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Ingredientes (opcional)',
                      helperText: 'Separe por vírgula. Só o que você sabe.',
                      helperMaxLines: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          BottomActionBar(
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(editing ? 'Salvar alterações' : 'Salvar e usar'),
            ),
          ),
        ],
      ),
    );
  }
}
