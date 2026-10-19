import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../l10n/l10n.dart';
import '../../tab/domain/tab_calc.dart';
import '../../tab/domain/tab_models.dart';
import 'person_avatar.dart';

/// "Por pessoa": for each person, what they drank (volumes, never mixed with
/// money) and what they owe (drinks, food, discount, service) against what
/// they paid the venue. A person can pay for others without drinking more.
class PeopleView extends StatelessWidget {
  const PeopleView({
    super.key,
    required this.doc,
    required this.result,
    required this.consumption,
    required this.onSeeOrders,
    required this.onManage,
  });

  final TabDoc doc;
  final TabResult result;
  final Map<String, PersonConsumption> consumption;
  final ValueChanged<Participant> onSeeOrders;
  final ValueChanged<Participant> onManage;

  @override
  Widget build(BuildContext context) {
    final breakdown = TabCalculator.breakdown(doc, result);
    final unassigned = consumption[TabCalculator.unassignedKey];
    return Column(
      children: [
        for (var i = 0; i < doc.participants.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpace.sm),
            child: _PersonCard(
              person: doc.participants[i],
              index: i,
              breakdown: breakdown[doc.participants[i].id]!,
              consumption: consumption[doc.participants[i].id],
              itemMode: doc.mode == SplitMode.item,
              settled: result.venueSettled,
              onSeeOrders: () => onSeeOrders(doc.participants[i]),
              onManage: () => onManage(doc.participants[i]),
            ),
          ),
        if (unassigned != null)
          SurfaceCard(
            key: const ValueKey('unassigned-card'),
            child: Row(
              children: [
                const Icon(Icons.help_outline_rounded, color: AppColors.amber),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Text(
                    tr.peopleUnassigned(unassigned.count),
                    style: AppText.caption,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PersonCard extends StatelessWidget {
  const _PersonCard({
    required this.person,
    required this.index,
    required this.breakdown,
    required this.consumption,
    required this.itemMode,
    required this.settled,
    required this.onSeeOrders,
    required this.onManage,
  });

  final Participant person;
  final int index;
  final PersonBreakdown breakdown;
  final PersonConsumption? consumption;
  final bool itemMode;
  final bool settled;
  final VoidCallback onSeeOrders;
  final VoidCallback onManage;

  String get _drank {
    final c = consumption;
    if (c == null || c.count == 0) return tr.peopleDrankNothing;
    final ml = c.knownMl == 0 && c.unknownCount > 0
        ? tr.volumeUnknown
        : (c.unknownCount == 0
              ? formatMl(c.knownMl)
              : tr.volumeKnownPlusUnknown(formatMl(c.knownMl), c.unknownCount));
    return tr.peopleDrankLine(c.count, ml);
  }

  @override
  Widget build(BuildContext context) {
    final b = breakdown;
    final diff = b.balanceCents;
    final status = b.shareCents == 0 && b.paidCents == 0
        ? null
        : diff > 0
        ? tr.peopleStillOwes(formatCents(diff))
        : diff < 0
        ? tr.peoplePaidMore(formatCents(-diff))
        : tr.peopleEven;
    return SurfaceCard(
      key: ValueKey('person-card-${person.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PersonAvatar(person: person, size: 36, index: index),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Text(
                  person.left
                      ? '${person.displayName} · ${tr.peopleLeftTag}'
                      : person.displayName,
                  style: AppText.title,
                ),
              ),
              IconButton(
                tooltip: tr.entryOptions,
                onPressed: onManage,
                icon: const Icon(Icons.more_vert_rounded, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.sm),
          Text(_drank, key: ValueKey('drank-${person.id}'), style: AppText.caption),
          const Divider(height: AppSpace.xl),
          if (itemMode) ...[
            _Line(tr.peopleDrinksCost, b.drinksCents),
            _Line(tr.peopleFoodCost, b.foodCents),
            if (b.discountCents > 0) _Line(tr.peopleDiscount, -b.discountCents),
            if (b.serviceCents != 0) _Line(tr.peopleService, b.serviceCents),
          ],
          _Line(
            tr.peopleShare,
            b.shareCents,
            bold: true,
            keyName: 'share-${person.id}',
          ),
          _Line(tr.peoplePaidToVenue, b.paidCents, keyName: 'paid-${person.id}'),
          if (status != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpace.xs),
              child: Text(
                status,
                key: ValueKey('status-${person.id}'),
                style: TextStyle(
                  color: diff > 0 ? AppColors.amber : AppColors.text,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: onSeeOrders,
              child: Text(tr.peopleSeeOrders(person.displayName)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.label, this.cents, {this.bold = false, this.keyName});

  final String label;
  final int cents;
  final bool bold;
  final String? keyName;

  @override
  Widget build(BuildContext context) {
    final style = bold ? AppText.subtitle : AppText.caption;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(
            cents < 0 ? '−${formatCents(-cents)}' : formatCents(cents),
            key: keyName == null ? null : ValueKey(keyName),
            style: style,
          ),
        ],
      ),
    );
  }
}
