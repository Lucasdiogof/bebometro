import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../l10n/l10n.dart';
import '../../tab/domain/tab_calc.dart';
import '../../tab/domain/tab_models.dart';
import '../../tab/domain/tab_share.dart' show formatBp;

/// "Conta": the whole table's bill, what was paid to the venue and what is
/// still due. It never says who should pay whom, and one person paying the bar
/// settles the bar without making the drinks theirs.
class BillView extends StatelessWidget {
  const BillView({
    super.key,
    required this.doc,
    required this.result,
    required this.onSettings,
    required this.onSplit,
    required this.onShare,
    this.legacyBanner,
  });

  final TabDoc doc;
  final TabResult result;
  final VoidCallback onSettings;
  final VoidCallback onSplit;
  final VoidCallback onShare;

  /// Shown above the bill for an old outing whose tab was already used.
  final Widget? legacyBanner;

  @override
  Widget build(BuildContext context) {
    final r = result;
    final me = doc.me;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ?legacyBanner,
        SurfaceCard(
          key: const ValueKey('bill-card'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Row(
                r.isPartial ? tr.billSubtotalKnown : tr.billSubtotal,
                formatCents(r.subtotal),
                keyName: 'bill-subtotal',
              ),
              if (r.discount > 0)
                _Row(tr.billDiscount, '−${formatCents(r.discount)}'),
              if (doc.serviceOn)
                _Row(
                  tr.billService(
                    formatBp(doc.serviceBp),
                    formatCents(r.serviceBase),
                  ),
                  '+${formatCents(r.service)}',
                  keyName: 'bill-service',
                ),
              const Divider(height: AppSpace.xl),
              _Row(
                r.isPartial ? tr.billTotalKnown : tr.billTotal,
                formatCents(r.total),
                bold: true,
                keyName: 'bill-total',
              ),
              if (me != null && doc.participants.length > 1)
                _Row(
                  tr.billYourShare,
                  formatCents(r.shareOf(me.id)),
                  keyName: 'bill-me',
                ),
              if (r.isPartial)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpace.sm),
                  child: InfoPill(
                    tr.billPartial(r.pendingCount),
                    icon: Icons.help_outline_rounded,
                    warning: true,
                  ),
                ),
              if (r.unassigned != 0)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpace.sm),
                  child: InfoPill(
                    r.unassigned > 0
                        ? tr.billUnassigned(formatCents(r.unassigned))
                        : tr.billOverAssigned(formatCents(-r.unassigned)),
                    icon: Icons.call_split_rounded,
                    warning: true,
                  ),
                ),
              const Divider(height: AppSpace.xl),
              _Row(
                tr.billPaidToVenue,
                formatCents(r.paidTotal),
                keyName: 'bill-paid',
              ),
              if (r.venueSettled)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpace.sm),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.verified_outlined,
                        color: AppColors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpace.sm),
                      Expanded(
                        child: Text(
                          tr.billSettled,
                          key: const ValueKey('bill-settled'),
                          style: AppText.subtitle,
                        ),
                      ),
                    ],
                  ),
                )
              else if (!r.isPartial)
                _Row(
                  tr.billDue,
                  formatCents(r.venueDueCents),
                  keyName: 'bill-due',
                ),
              if (r.overpaidCents > 0)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpace.xs),
                  child: Text(
                    tr.billOverpaid(formatCents(r.overpaidCents)),
                    style: AppText.caption,
                  ),
                ),
              const SizedBox(height: AppSpace.xs),
              Text(tr.billNoTransfers, style: AppText.caption),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.md),
        OutlinedButton.icon(
          key: const ValueKey('bill-settings'),
          onPressed: onSettings,
          icon: const Icon(Icons.tune_rounded),
          label: Text(tr.billSettings),
        ),
        const SizedBox(height: AppSpace.sm),
        OutlinedButton.icon(
          key: const ValueKey('bill-split'),
          onPressed: onSplit,
          icon: const Icon(Icons.call_split_rounded),
          label: Text(tr.billSplitAndPay),
        ),
        const SizedBox(height: AppSpace.sm),
        OutlinedButton.icon(
          key: const ValueKey('bill-share'),
          onPressed: doc.isEmpty ? null : onShare,
          icon: const Icon(Icons.ios_share_rounded),
          label: Text(tr.tabShareSplitTooltip),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.bold = false, this.keyName});

  final String label;
  final String value;
  final bool bold;
  final String? keyName;

  @override
  Widget build(BuildContext context) {
    final style = bold ? AppText.title : AppText.subtitle;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: bold ? AppText.subtitle : AppText.caption,
            ),
          ),
          const SizedBox(width: AppSpace.sm),
          // Wraps (right-aligned) when the system font is large, never overflows.
          Flexible(
            flex: 2,
            child: Text(
              value,
              key: keyName == null ? null : ValueKey(keyName),
              textAlign: TextAlign.end,
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}
