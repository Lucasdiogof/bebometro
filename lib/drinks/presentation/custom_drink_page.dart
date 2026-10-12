import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../data/drink_repository.dart';
import '../domain/drink_category.dart';

/// Creates a reusable personal drink. Pops with the new [CatalogItem].
class CustomDrinkPage extends StatefulWidget {
  const CustomDrinkPage({super.key, this.initialName = ''});

  /// Pre-fills the name, e.g. with what the user was searching for.
  final String initialName;

  @override
  State<CustomDrinkPage> createState() => _CustomDrinkPageState();
}

class _CustomDrinkPageState extends State<CustomDrinkPage> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.initialName);
  final _brand = TextEditingController();
  final _style = TextEditingController();
  final _volume = TextEditingController();
  final _abv = TextEditingController();
  DrinkCategory _category = DrinkCategory.beer;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _brand.dispose();
    _style.dispose();
    _volume.dispose();
    _abv.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
    setState(() => _saving = true);
    final item = await getIt<DrinkRepository>().saveCustomDrink(
      name: _name.text,
      category: _category,
      brand: _brand.text,
      style: _style.text,
      volumeMl: parseInteger(_volume.text)!,
      abvPercent: parseDecimal(_abv.text),
    );
    if (mounted) Navigator.of(context).pop(item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar bebida')),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              const Text(
                'Fica salva para você usar de novo nos próximos rolês.',
                style: TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Nome da bebida'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Dê um nome para a bebida'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _brand,
                textCapitalization: TextCapitalization.words,
                decoration:
                    const InputDecoration(labelText: 'Marca (opcional)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _style,
                textCapitalization: TextCapitalization.sentences,
                decoration:
                    const InputDecoration(labelText: 'Estilo (opcional)'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _volume,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Volume (ml)',
                  suffixText: 'ml',
                ),
                validator: (v) {
                  final ml = parseInteger(v ?? '');
                  return (ml == null || ml <= 0) ? 'Informe o volume em ml' : null;
                },
              ),
              if (_category.canBeAlcoholic) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _abv,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Teor alcoólico (opcional)',
                    suffixText: '% vol.',
                    helperText: 'Em branco = desconhecido, não conta como zero.',
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
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: const Text('Salvar e usar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
