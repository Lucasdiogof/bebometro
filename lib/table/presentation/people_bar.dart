import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../l10n/l10n.dart';
import '../../tab/domain/tab_models.dart';
import '../domain/table_orders.dart';
import 'person_avatar.dart';

/// "Mesa | Você | nomes | +": which part of the outing the screen shows. The
/// first chip is the whole table; picking a person filters orders, volumes and
/// the cost to that person. People who left stay (dimmed) at the end.
class PeopleBar extends StatelessWidget {
  const PeopleBar({
    super.key,
    required this.doc,
    required this.filter,
    required this.onChanged,
    required this.onAdd,
    required this.onManage,
  });

  final TabDoc doc;
  final PersonFilter filter;
  final ValueChanged<PersonFilter> onChanged;
  final VoidCallback onAdd;

  /// Long press on a person: rename, left/back, remove.
  final ValueChanged<Participant> onManage;

  @override
  Widget build(BuildContext context) {
    final present = [for (final p in doc.participants) if (!p.left) p];
    final left = [for (final p in doc.participants) if (p.left) p];
    final ordered = [...present, ...left];
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpace.sm),
            child: ChoiceChip(
              key: const ValueKey('filter-table'),
              avatar: const Icon(Icons.groups_rounded, size: 18),
              label: Text(tr.peopleTable),
              selected: filter.isTable,
              showCheckmark: false,
              onSelected: (_) => onChanged(const PersonFilter.table()),
            ),
          ),
          for (var i = 0; i < ordered.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: AppSpace.sm),
              child: GestureDetector(
                onLongPress: () => onManage(ordered[i]),
                child: Opacity(
                  opacity: ordered[i].left ? 0.55 : 1,
                  child: ChoiceChip(
                    key: ValueKey('filter-${ordered[i].id}'),
                    avatar: PersonAvatar(
                      person: ordered[i],
                      size: 22,
                      index: doc.participants.indexOf(ordered[i]),
                    ),
                    label: Text(
                      ordered[i].left
                          ? '${ordered[i].displayName} · ${tr.peopleLeftTag}'
                          : ordered[i].displayName,
                    ),
                    selected: filter.personId == ordered[i].id,
                    showCheckmark: false,
                    onSelected: (_) =>
                        onChanged(PersonFilter.person(ordered[i].id)),
                  ),
                ),
              ),
            ),
          ActionChip(
            key: const ValueKey('add-person'),
            avatar: const Icon(Icons.person_add_alt_1_rounded, size: 18, color: AppColors.amber),
            label: Text(tr.peopleAdd),
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }
}
