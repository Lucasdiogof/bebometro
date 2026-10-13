import 'package:flutter/material.dart';

import '../domain/recipe.dart';

/// Picks the unit of an ingredient amount. The recipe's original wording
/// ([RecipeUnit.other]) only shows while it is the current value.
class UnitDropdown extends StatelessWidget {
  const UnitDropdown({super.key, required this.value, required this.onChanged});

  final RecipeUnit value;
  final ValueChanged<RecipeUnit> onChanged;

  @override
  Widget build(BuildContext context) {
    final units = [
      ...RecipeUnit.editable,
      if (value == RecipeUnit.other) RecipeUnit.other,
    ];
    return DropdownButtonFormField<RecipeUnit>(
      key: ValueKey(value),
      initialValue: value,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Unidade'),
      items: [
        for (final u in units)
          DropdownMenuItem(
            value: u,
            child: Text(u.label, overflow: TextOverflow.ellipsis),
          ),
      ],
      onChanged: (u) {
        if (u != null) onChanged(u);
      },
    );
  }
}
