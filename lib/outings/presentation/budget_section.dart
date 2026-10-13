import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../domain/budget.dart';
import '../domain/outing_summary.dart';

/// Optional drinks budget of an outing: informed spending against the budget,
/// honest about records that have no price.
class BudgetSection extends StatelessWidget {
  const BudgetSection({
    super.key,
    required this.budgetCents,
    required this.summary,
    required this.onChange,
    this.editable = true,
  });

  final int? budgetCents;
  final OutingSummary summary;
  final bool editable;

  /// Called with the new budget (null removes it).
  final ValueChanged<int?> onChange;

  Future<void> _edit(BuildContext context) async {
    final controller = TextEditingController(
      text: budgetCents == null ? '' : centsToInput(budgetCents!),
    );
    String? error;
    final result = await showDialog<_BudgetResult>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Orçamento para bebidas'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Valor',
                  prefixText: r'R$ ',
                  errorText: error,
                ),
              ),
              const SizedBox(height: AppSpace.sm),
              const Text(
                'Opcional. Compara só com os gastos que você informou.',
                style: AppText.caption,
              ),
            ],
          ),
          actions: [
            if (budgetCents != null)
              TextButton(
                onPressed: () => Navigator.pop(ctx, const _BudgetResult(null)),
                child: const Text('Remover',
                    style: TextStyle(color: AppColors.danger)),
              ),
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            TextButton(
              onPressed: () {
                final cents = parseCents(controller.text);
                if (cents == null || cents <= 0) {
                  setState(() => error = 'Informe um valor maior que zero');
                  return;
                }
                Navigator.pop(ctx, _BudgetResult(cents));
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (result != null) onChange(result.cents);
  }

  @override
  Widget build(BuildContext context) {
    final budget = budgetCents;
    if (budget == null) {
      if (!editable) return const SizedBox.shrink();
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () => _edit(context),
          icon: const Icon(Icons.savings_outlined, size: 18),
          label: const Text('Definir orçamento'),
        ),
      );
    }
    final status = BudgetStatus.of(budget, summary);
    final color = status.over ? AppColors.danger : AppColors.amber;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(
            child: Text(
              'Orçamento ${formatCents(budget)} · gasto informado '
              '${formatCents(status.informedCents)}',
              style: AppText.subtitle,
            ),
          ),
          if (editable)
            IconButton(
              tooltip: 'Editar orçamento',
              onPressed: () => _edit(context),
              icon: const Icon(Icons.edit_outlined, size: 18),
            ),
        ]),
        const SizedBox(height: AppSpace.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: status.barValue,
            minHeight: 8,
            color: color,
            backgroundColor: AppColors.surfaceHigh,
          ),
        ),
        const SizedBox(height: AppSpace.sm),
        Text(status.headline, style: AppText.caption),
      ],
    );
  }
}

class _BudgetResult {
  const _BudgetResult(this.cents);

  final int? cents;
}
