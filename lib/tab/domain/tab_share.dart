import 'package:intl/intl.dart';

import '../../core/utils/formatters.dart';
import '../../outings/domain/outing.dart';
import 'tab_calc.dart';
import 'tab_models.dart';
import '../../l10n/l10n.dart';

/// Plain-text summary of the split, for the share sheet or the clipboard.
/// It never carries the address, photos, personal notes or any drinking
/// report. Payments only go in when the user chose to include them.
class TabShareText {
  const TabShareText._();

  static String _title(Outing outing) {
    final nick = outing.nickname?.trim();
    final name = (nick != null && nick.isNotEmpty) ? nick : outing.type.label;
    return '$name · ${formatDate(outing.startedAt)}';
  }

  static String build({
    required Outing outing,
    required TabDoc doc,
    required TabResult result,
    bool includePayments = false,
  }) {
    final b = StringBuffer()
      ..writeln(tr.tabShareHeader(_title(outing)))
      ..writeln();

    if (result.groups.isEmpty) {
      b.writeln(tr.tabShareNoItems);
    } else {
      b.writeln(tr.tabShareItems);
      for (final g in result.groups) {
        final l = g.first;
        if (g.count > 1 && g.isPriced) {
          b.writeln(
            tr.tabShareLineGroup(
              l.title,
              '${g.count}',
              formatCents(g.unitCents!),
              formatCents(g.sumCents!),
            ),
          );
        } else if (l.quantity > 1 && l.totalCents != null) {
          b.writeln(
            tr.tabShareLineQty(
              l.title,
              '${l.quantity}',
              formatCents(l.totalCents!),
            ),
          );
        } else if (g.count > 1) {
          b.writeln(tr.tabShareLineGroupNoPrice(l.title, '${g.count}'));
        } else if (l.totalCents != null) {
          b.writeln(tr.tabShareLine(l.title, formatCents(l.totalCents!)));
        } else {
          b.writeln(tr.tabShareLineNoPrice(l.title));
        }
      }
    }

    b.writeln();
    b.writeln(
      result.isPartial
          ? tr.tabShareSubtotalKnown(formatCents(result.subtotal))
          : tr.tabShareSubtotal(formatCents(result.subtotal)),
    );
    if (result.discount > 0) {
      b.writeln(tr.tabShareDiscount(formatCents(result.discount)));
    }
    if (doc.serviceOn) {
      b.writeln(
        tr.tabShareService(
          _pct(doc.serviceBp),
          formatCents(result.serviceBase),
          formatCents(result.service),
        ),
      );
    }
    b.writeln(
      result.isPartial
          ? tr.tabShareTotalKnown(formatCents(result.total))
          : tr.tabShareTotal(formatCents(result.total)),
    );
    if (result.isPartial) {
      b.writeln(tr.tabSharePartial(result.pendingCount));
    }

    if (doc.participants.isNotEmpty) {
      b
        ..writeln()
        ..writeln(tr.tabShareSplitHeader(doc.mode.label.toLowerCase()));
      for (final p in doc.participants) {
        var line = tr.tabShareSplitLine(
          p.displayName,
          formatCents(result.shareOf(p.id)),
        );
        if (includePayments) {
          line += tr.tabSharePaid(formatCents(result.paidBy(p.id)));
          final bal = result.balanceOf(p.id);
          if (bal > 0 && result.venueSettled) {
            line += tr.tabShareCovered;
          } else if (bal > 0) {
            line += tr.tabShareMissing(formatCents(bal));
          } else if (bal < 0) {
            line += tr.tabShareOver(formatCents(-bal));
          }
        }
        b.writeln(line);
      }
      if (result.unassigned != 0) {
        b.writeln(
          result.unassigned > 0
              ? tr.tabShareUnassigned(formatCents(result.unassigned))
              : tr.tabShareOverTotal(formatCents(-result.unassigned)),
        );
      }
      if (result.isPartial || result.unassigned != 0) {
        b.writeln(tr.tabShareSplitPartial);
      }
    }
    return b.toString().trimRight();
  }

  static String _pct(int bp) => formatBp(bp);
}

/// Basis points as a percentage in the language on screen:
/// 1000 -> "10%", 1250 -> "12,5%" (pt, es) or "12.5%" (en).
String formatBp(int bp) =>
    '${NumberFormat('#,##0.##', trLocaleTag).format(bp / 100)}%';

/// Percentage typed by the user ("10", "12,5") to basis points; null if invalid.
int? parseBp(String input) {
  final d = parseDecimal(input);
  if (d == null || d < 0 || d > 100) return null;
  return (d * 100).round();
}
