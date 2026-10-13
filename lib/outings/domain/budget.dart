import '../../core/utils/formatters.dart';
import 'outing_summary.dart';

/// Where the informed spending stands against the optional budget.
///
/// The informed total only covers records that have a price. When some are
/// missing, the real spending can only be higher, so the difference is shown
/// as partial and never as a definitive "you still have R$ X".
class BudgetStatus {
  const BudgetStatus({
    required this.budgetCents,
    required this.informedCents,
    required this.unpricedCount,
  });

  factory BudgetStatus.of(int budgetCents, OutingSummary s) => BudgetStatus(
        budgetCents: budgetCents,
        informedCents: s.informedCents,
        unpricedCount: s.unpricedCount,
      );

  final int budgetCents;
  final int informedCents;
  final int unpricedCount;

  bool get incomplete => unpricedCount > 0;

  /// Budget minus informed spending (negative = already above the budget).
  int get differenceCents => budgetCents - informedCents;

  bool get over => informedCents > budgetCents;

  /// 0..infinity; 1.0 = the whole budget.
  double get ratio => budgetCents == 0 ? 0 : informedCents / budgetCents;

  /// The progress bar value, capped at 1.
  double get barValue => ratio.clamp(0.0, 1.0).toDouble();

  /// One line for the user, honest about missing prices.
  String get headline {
    final diff = differenceCents.abs();
    if (over) {
      return incomplete
          ? 'Os gastos informados já passaram ${formatCents(diff)} do orçamento '
              'e ainda faltam preços.'
          : 'Passou ${formatCents(diff)} do orçamento.';
    }
    if (incomplete) {
      return 'Dos gastos informados, sobram ${formatCents(diff)} do orçamento '
          '(parcial: faltam preços de $unpricedCount '
          '${unpricedCount == 1 ? 'bebida' : 'bebidas'}).';
    }
    return 'Sobram ${formatCents(diff)} do orçamento.';
  }

  /// Percent thresholds already reached (80 and 100).
  List<int> get reachedThresholds => [
        for (final t in const [80, 100])
          if (informedCents * 100 >= budgetCents * t) t,
      ];
}
