import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../data/drink_repository.dart';
import '../domain/catalog_item.dart';
import '../domain/drink_category.dart';
import '../../l10n/l10n.dart';

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
  late bool _alcoholic;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    _name = TextEditingController(text: e?.name ?? widget.initialName);
    _alcoholic = e?.category.canBeAlcoholic ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  /// A name and "with / without alcohol" are all that is asked. A drink being
  /// corrected keeps whatever older data it has (brand, style, size, ABV).
  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final e = widget.editing;
      final kept = e?.category;
      final category = _alcoholic
          ? (kept != null && kept.canBeAlcoholic
                ? kept
                : DrinkCategory.cocktail)
          : DrinkCategory.nonAlcoholic;
      final item = await getIt<DrinkRepository>().saveCustomDrink(
        itemId: e?.id,
        name: _name.text,
        category: category,
        brand: e?.brand,
        style: e?.style,
        volumeMl: e == null || e.presentations.isEmpty
            ? null
            : e.presentations.first.volumeMl,
        abvPercent: e?.abvPercent,
        ingredients: e?.ingredients,
      );
      if (mounted) Navigator.of(context).pop(item);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      showToast(context, tr.customSaveFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.editing != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? tr.customEditTitle : tr.catalogCreate),
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
                  AppSpace.gutter,
                  0,
                  AppSpace.gutter,
                  AppSpace.xl,
                ),
                children: [
                  Text(
                    editing ? tr.customEditNote : tr.customNewNote,
                    style: AppText.caption,
                  ),
                  SectionTitle(tr.customIdentification),
                  TextFormField(
                    controller: _name,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(labelText: tr.customName),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? tr.customNameRequired
                        : null,
                  ),
                  SectionTitle(tr.customType),
                  Wrap(
                    spacing: AppSpace.sm,
                    runSpacing: AppSpace.sm,
                    children: [
                      ChoiceChip(
                        label: Text(tr.orderKindAlcoholic),
                        selected: _alcoholic,
                        showCheckmark: false,
                        onSelected: (_) => setState(() => _alcoholic = true),
                      ),
                      ChoiceChip(
                        label: Text(tr.orderKindSoft),
                        selected: !_alcoholic,
                        showCheckmark: false,
                        onSelected: (_) => setState(() => _alcoholic = false),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          BottomActionBar(
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(editing ? tr.entrySaveChanges : tr.customSaveUse),
            ),
          ),
        ],
      ),
    );
  }
}
