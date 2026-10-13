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
import '../../l10n/l10n.dart';

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
        : (widget.copyFrom != null
            ? tr.recipeEditorNameCopy(widget.copyFrom!.name)
            : '');
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
    if (_name.text.trim().isEmpty) return tr.recipeEditorNeedName;
    if (_rows.isEmpty) return tr.recipeEditorNeedIngredient;
    // An unreadable or ambiguous number ("1.500") is reported, never guessed.
    for (final r in _rows) {
      final name = r.name.text.trim();
      final texts = [
        if (r.unit != RecipeUnit.toTaste && r.unit != RecipeUnit.other)
          r.amount.text,
        if (r.alcoholic) r.abv.text,
      ];
      for (final t in texts) {
        final problem = numberInputError(t);
        if (problem != null) {
          return tr.recipeEditorNumberProblem(name, problem);
        }
      }
    }
    for (final c in _components) {
      if (c.name.isEmpty) return tr.recipeEditorIngredientName;
      final abv = c.abvPercent;
      if (abv != null && (abv < 0 || abv > 100)) {
        return tr.recipeEditorAbvRange(c.name);
      }
      final qty = c.amount;
      if (qty != null && qty < 0) return tr.recipeEditorAmountInvalid(c.name);
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
      showToast(context, tr.customSaveFailed);
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
      appBar: AppBar(
          title: Text(editing
              ? tr.recipeEditorEditTitle
              : tr.recipeEditorNewTitle)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(
                  AppSpace.gutter, 0, AppSpace.gutter, AppSpace.xl),
              children: [
                Text(tr.recipeEditorIntro, style: AppText.caption),
                SectionTitle(tr.recipeEditorNameSection),
                TextField(
                  controller: _name,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: tr.entryRecipeName,
                    errorText: _showErrors && _name.text.trim().isEmpty
                        ? tr.recipeEditorNameRequired
                        : null,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                SectionTitle(tr.recipeEditorIngredients),
                if (_rows.isEmpty)
                  Text(tr.recipeEditorNoneYet, style: AppText.caption),
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
                  label: Text(tr.entryAddIngredient),
                ),
                if (estimate != null) ...[
                  SectionTitle(tr.recipeEditorAlcoholSection),
                  SurfaceCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StatTile(
                          label: tr.recipeEditorDeclaredAlcohol,
                          value: estimate.isComplete
                              ? formatGrams(estimate.grams)
                              : tr.entryAtLeast(formatGrams(estimate.grams)),
                          icon: Icons.science_outlined,
                        ),
                        if (!estimate.isComplete) ...[
                          const SizedBox(height: AppSpace.sm),
                          InfoPill(
                            tr.entryMissingParts(estimate.missing.join(', ')),
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
              child: Text(
                  editing ? tr.entrySaveChanges : tr.recipeEditorSaveRecipe),
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
                decoration: InputDecoration(labelText: tr.entryIngredientField),
                onChanged: (_) => onChanged(),
              ),
            ),
            Column(children: [
              IconButton(
                tooltip: tr.recipeEditorMoveUp,
                visualDensity: VisualDensity.compact,
                onPressed: index == 0 ? null : () => onMove(-1),
                icon: const Icon(Icons.keyboard_arrow_up_rounded),
              ),
              IconButton(
                tooltip: tr.recipeEditorMoveDown,
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
                      labelText: tr.entryAmount,
                      suffixText: row.unit.shortLabel,
                      errorText: numberInputError(row.amount.text),
                      errorMaxLines: 3,
                      helperText: row.amountText == null
                          ? tr.entryAmountUnknown
                          : tr.recipeEditorOriginal(row.amountText!),
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
              child: Text(tr.recipeEditorOriginal(row.amountText!),
                  style: AppText.caption),
            ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(tr.entryHasAlcohol),
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
              decoration: InputDecoration(
                labelText: tr.entryComponentAbv,
                suffixText: '% vol.',
                errorText: numberInputError(row.abv.text),
                errorMaxLines: 3,
                helperText: tr.customAbvHelper,
              ),
              onChanged: (_) => onChanged(),
            ),
            const SizedBox(height: AppSpace.sm),
            DropdownButtonFormField<String?>(
              initialValue: row.role,
              decoration: InputDecoration(
                labelText: tr.recipeEditorRole,
              ),
              items: [
                DropdownMenuItem<String?>(
                    value: null, child: Text(tr.recipeEditorNoRole)),
                for (final role in ingredientRoles)
                  DropdownMenuItem<String?>(
                      value: role, child: Text(ingredientRoleLabel(role))),
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
              label: Text(tr.recipeEditorRemove,
                  style: const TextStyle(color: AppColors.danger)),
            ),
          ),
        ],
      ),
    );
  }
}
