import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../data/drink_repository.dart';
import '../domain/catalog_item.dart';
import '../domain/recipe.dart';
import 'unit_dropdown.dart';

/// Full editor for a personal recipe: name and every component (ingredient,
/// alcohol flag, amount, ABV, role). Pops the saved [CatalogItem].
///
/// Pass [editing] to change a saved recipe, or [copyFrom] to start a new
/// recipe from another one (e.g. a reference recipe). With neither, it starts
/// empty. Records already made keep their own snapshot.
class RecipeEditorPage extends StatefulWidget {
  const RecipeEditorPage({super.key, this.editing, this.copyFrom});

  final CatalogItem? editing;
  final CatalogItem? copyFrom;

  @override
  State<RecipeEditorPage> createState() => _RecipeEditorPageState();
}

class _RowModel {
  _RowModel({
    String name = '',
    double? amount,
    double? abv,
    this.unit = RecipeUnit.ml,
    this.alcoholic = false,
    this.role,
    this.amountText,
    this.optional = false,
    this.productId,
    this.productName,
  })  : name = TextEditingController(text: name),
        amount = TextEditingController(
          text: amount == null ? '' : decimalToInput(amount),
        ),
        abv = TextEditingController(
          text: abv == null ? '' : decimalToInput(abv),
        );

  factory _RowModel.from(EntryComponent c) => _RowModel(
        name: c.name,
        amount: c.amount,
        unit: c.unit,
        abv: c.abvPercent,
        alcoholic: c.alcoholic,
        role: c.role,
        amountText: c.amountText,
        optional: c.optional,
        productId: c.productId,
        productName: c.productName,
      );

  final TextEditingController name;
  final TextEditingController amount;
  final TextEditingController abv;
  bool alcoholic;
  String? role;
  RecipeUnit unit;

  /// How the original recipe wrote an amount that is not in ml; kept as text
  /// while no ml value is typed.
  final String? amountText;
  final bool optional;
  final String? productId;
  final String? productName;

  EntryComponent toComponent() {
    // "a gosto" and the recipe's own wording have no number; nothing is ever
    // converted between units.
    final hasNumber = unit != RecipeUnit.toTaste && unit != RecipeUnit.other;
    final qty = hasNumber ? parseDecimal(amount.text) : null;
    return EntryComponent(
      name: name.text.trim(),
      alcoholic: alcoholic,
      role: alcoholic ? role : null,
      amount: qty,
      unit: unit,
      amountText: qty == null ? amountText : null,
      abvPercent: alcoholic ? parseDecimal(abv.text) : null,
      productId: alcoholic ? productId : null,
      productName: alcoholic ? productName : null,
      optional: optional,
    );
  }

  void dispose() {
    name.dispose();
    amount.dispose();
    abv.dispose();
  }
}

class _RecipeEditorPageState extends State<RecipeEditorPage> {
  late final TextEditingController _name;
  final _rows = <_RowModel>[];
  bool _saving = false;
  bool _showErrors = false;

  @override
  void initState() {
    super.initState();
    final source = widget.editing ?? widget.copyFrom;
    final defaultName = widget.editing != null
        ? widget.editing!.name
        : (widget.copyFrom != null ? '${widget.copyFrom!.name} (minha versão)' : '');
    _name = TextEditingController(text: defaultName);
    for (final c in source?.recipe?.components ?? const <EntryComponent>[]) {
      _rows.add(_RowModel.from(c));
    }
  }

  @override
  void dispose() {
    _name.dispose();
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  List<EntryComponent> get _components =>
      [for (final r in _rows) r.toComponent()];

  String? _problem() {
    if (_name.text.trim().isEmpty) return 'Dê um nome para a receita.';
    if (_rows.isEmpty) return 'Adicione pelo menos um ingrediente.';
    for (final c in _components) {
      if (c.name.isEmpty) return 'Todo ingrediente precisa de um nome.';
      final abv = c.abvPercent;
      if (abv != null && (abv < 0 || abv > 100)) {
        return 'O teor de "${c.name}" vai de 0 a 100%.';
      }
      final qty = c.amount;
      if (qty != null && qty < 0) return 'A quantidade de "${c.name}" é inválida.';
    }
    return null;
  }

  Future<void> _save() async {
    if (_saving) return;
    final problem = _problem();
    if (problem != null) {
      setState(() => _showErrors = true);
      showToast(context, problem);
      return;
    }
    setState(() => _saving = true);
    try {
      final item = await getIt<DrinkRepository>().saveCustomRecipe(
        itemId: widget.editing?.id,
        name: _name.text,
        components: _components,
      );
      if (mounted) Navigator.of(context).pop(item);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      showToast(context, 'Não foi possível salvar. Seus dados continuam aqui.');
    }
  }

  void _move(int from, int to) {
    if (to < 0 || to >= _rows.length) return;
    setState(() {
      final row = _rows.removeAt(from);
      _rows.insert(to, row);
    });
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.editing != null;
    final estimate = _rows.any((r) => r.alcoholic)
        ? estimateComponents(_components)
        : null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Editar receita' : 'Nova receita')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(
                  AppSpace.gutter, 0, AppSpace.gutter, AppSpace.xl),
              children: [
                const Text(
                  'Registre só o que você sabe. Quantidade ou teor em branco '
                  'ficam como desconhecidos e o álcool total aparece como '
                  'incompleto.',
                  style: AppText.caption,
                ),
                const SectionTitle('Nome'),
                TextField(
                  controller: _name,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: 'Nome da receita',
                    errorText: _showErrors && _name.text.trim().isEmpty
                        ? 'Dê um nome para a receita'
                        : null,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SectionTitle('Ingredientes'),
                if (_rows.isEmpty)
                  const Text('Nenhum ingrediente ainda.', style: AppText.caption),
                for (var i = 0; i < _rows.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpace.md),
                    child: _RowCard(
                      key: ObjectKey(_rows[i]),
                      row: _rows[i],
                      index: i,
                      count: _rows.length,
                      onChanged: () => setState(() {}),
                      onRemove: () => setState(() {
                        _rows.removeAt(i).dispose();
                      }),
                      onMove: (delta) => _move(i, i + delta),
                    ),
                  ),
                OutlinedButton.icon(
                  onPressed: () => setState(() => _rows.add(_RowModel())),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Adicionar ingrediente'),
                ),
                if (estimate != null) ...[
                  const SectionTitle('Álcool da composição'),
                  SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StatTile(
                          label: 'Álcool puro declarado',
                          value: (estimate.isComplete ? '' : 'pelo menos ') +
                              formatGrams(estimate.grams),
                          icon: Icons.science_outlined,
                        ),
                        if (!estimate.isComplete) ...[
                          const SizedBox(height: AppSpace.sm),
                          InfoPill(
                            'Faltam teor ou quantidade de: '
                            '${estimate.missing.join(', ')}',
                            icon: Icons.help_outline_rounded,
                            warning: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          BottomActionBar(
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(editing ? 'Salvar alterações' : 'Salvar receita'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RowCard extends StatelessWidget {
  const _RowCard({
    super.key,
    required this.row,
    required this.index,
    required this.count,
    required this.onChanged,
    required this.onRemove,
    required this.onMove,
  });

  final _RowModel row;
  final int index;
  final int count;
  final VoidCallback onChanged;
  final VoidCallback onRemove;
  final ValueChanged<int> onMove;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: TextField(
                controller: row.name,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Ingrediente'),
                onChanged: (_) => onChanged(),
              ),
            ),
            Column(children: [
              IconButton(
                tooltip: 'Mover para cima',
                visualDensity: VisualDensity.compact,
                onPressed: index == 0 ? null : () => onMove(-1),
                icon: const Icon(Icons.keyboard_arrow_up_rounded),
              ),
              IconButton(
                tooltip: 'Mover para baixo',
                visualDensity: VisualDensity.compact,
                onPressed: index == count - 1 ? null : () => onMove(1),
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
              ),
            ]),
          ]),
          const SizedBox(height: AppSpace.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (row.unit != RecipeUnit.toTaste &&
                  row.unit != RecipeUnit.other)
                Expanded(
                  child: TextField(
                    controller: row.amount,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Quantidade',
                      suffixText: row.unit.shortLabel,
                      helperText: row.amountText == null
                          ? 'Em branco = desconhecida.'
                          : 'Na receita original: ${row.amountText}',
                      helperMaxLines: 2,
                    ),
                    onChanged: (_) => onChanged(),
                  ),
                ),
              if (row.unit != RecipeUnit.toTaste &&
                  row.unit != RecipeUnit.other)
                const SizedBox(width: AppSpace.sm),
              Expanded(
                child: UnitDropdown(
                  value: row.unit,
                  onChanged: (u) {
                    row.unit = u;
                    onChanged();
                  },
                ),
              ),
            ],
          ),
          if (row.unit == RecipeUnit.other && row.amountText != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpace.xs),
              child: Text('Na receita original: ${row.amountText}',
                  style: AppText.caption),
            ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Tem álcool'),
            value: row.alcoholic,
            activeThumbColor: AppColors.amber,
            onChanged: (v) {
              row.alcoholic = v;
              onChanged();
            },
          ),
          if (row.alcoholic) ...[
            TextField(
              controller: row.abv,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Teor alcoólico (% vol.)',
                suffixText: '% vol.',
                helperText: 'Em branco = desconhecido, não conta como zero.',
              ),
              onChanged: (_) => onChanged(),
            ),
            const SizedBox(height: AppSpace.sm),
            DropdownButtonFormField<String?>(
              initialValue: row.role,
              decoration: const InputDecoration(
                labelText: 'Tipo (para escolher a marca ao registrar)',
              ),
              items: [
                const DropdownMenuItem<String?>(
                    value: null, child: Text('Sem tipo')),
                for (final e in ingredientRoleLabels.entries)
                  DropdownMenuItem<String?>(value: e.key, child: Text(e.value)),
              ],
              onChanged: (v) {
                row.role = v;
                onChanged();
              },
            ),
          ],
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline_rounded,
                  size: 18, color: AppColors.danger),
              label: const Text('Remover',
                  style: TextStyle(color: AppColors.danger)),
            ),
          ),
        ],
      ),
    );
  }
}
