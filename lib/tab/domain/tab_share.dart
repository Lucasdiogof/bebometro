import '../../core/utils/formatters.dart';
import '../../outings/domain/outing.dart';
import 'tab_calc.dart';
import 'tab_models.dart';

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
      ..writeln('Comanda · ${_title(outing)}')
      ..writeln();

    if (result.groups.isEmpty) {
      b.writeln('Sem itens na comanda.');
    } else {
      b.writeln('Itens');
      for (final g in result.groups) {
        final l = g.first;
        if (g.count > 1 && g.isPriced) {
          b.writeln('• ${l.title} · ${g.count} × ${formatCents(g.unitCents!)}'
              ' = ${formatCents(g.sumCents!)}');
        } else if (l.quantity > 1 && l.totalCents != null) {
          b.writeln('• ${l.title} · ${l.quantity}× = '
              '${formatCents(l.totalCents!)}');
        } else if (g.count > 1) {
          b.writeln('• ${l.title} · ${g.count} × sem preço');
        } else if (l.totalCents != null) {
          b.writeln('• ${l.title} · ${formatCents(l.totalCents!)}');
        } else {
          b.writeln('• ${l.title} · sem preço');
        }
      }
    }

    b.writeln();
    b.writeln(result.isPartial
        ? 'Subtotal conhecido: ${formatCents(result.subtotal)}'
        : 'Subtotal: ${formatCents(result.subtotal)}');
    if (result.discount > 0) {
      b.writeln('Desconto: -${formatCents(result.discount)}');
    }
    if (doc.serviceOn) {
      b.writeln('Serviço (${_pct(doc.serviceBp)} sobre '
          '${formatCents(result.serviceBase)}): ${formatCents(result.service)}');
    }
    b.writeln(result.isPartial
        ? 'Total conhecido: ${formatCents(result.total)}'
        : 'Total: ${formatCents(result.total)}');
    if (result.isPartial) {
      b.writeln('Conta parcial: ${result.pendingCount} '
          '${result.pendingCount == 1 ? 'item sem preço' : 'itens sem preço'}.');
    }

    if (doc.participants.isNotEmpty) {
      b
        ..writeln()
        ..writeln('Divisão (${doc.mode.label.toLowerCase()})');
      for (final p in doc.participants) {
        var line = '• ${p.name}: ${formatCents(result.shareOf(p.id))}';
        if (includePayments) {
          line += ' · pagou ${formatCents(result.paidBy(p.id))}';
          final bal = result.balanceOf(p.id);
          if (bal > 0) {
            line += ' · falta ${formatCents(bal)}';
          } else if (bal < 0) {
            line += ' · a mais ${formatCents(-bal)}';
          }
        }
        b.writeln(line);
      }
      if (result.unassigned != 0) {
        b.writeln(result.unassigned > 0
            ? 'Ainda sem dividir: ${formatCents(result.unassigned)}'
            : 'Acima do total: ${formatCents(-result.unassigned)}');
      }
      if (result.isPartial || result.unassigned != 0) {
        b.writeln('Divisão parcial: os valores podem mudar.');
      }
    }
    return b.toString().trimRight();
  }

  static String _pct(int bp) => formatBp(bp);
}

/// Basis points as a percentage: 1000 -> "10%", 1250 -> "12,5%".
String formatBp(int bp) {
  final v = bp / 100;
  final text = v == v.roundToDouble()
      ? v.toStringAsFixed(0)
      : v.toStringAsFixed(2).replaceAll('.', ',').replaceFirst(RegExp(r'0$'), '');
  return '$text%';
}

/// Percentage typed by the user ("10", "12,5") to basis points; null if invalid.
int? parseBp(String input) {
  final d = parseDecimal(input);
  if (d == null || d < 0 || d > 100) return null;
  return (d * 100).round();
}
