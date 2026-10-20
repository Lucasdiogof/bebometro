import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../tab/domain/tab_models.dart';

/// Initial + color of a person. Names can repeat, so the color follows the
/// position in the tab, which makes two "João" tell apart without using the
/// name as an identity.
class PersonAvatar extends StatelessWidget {
  const PersonAvatar({
    super.key,
    required this.person,
    this.size = 32,
    this.index,
  });

  final Participant person;
  final double size;

  /// Position of the person in the tab (for the color). Null = from the id.
  final int? index;

  static const _palette = [
    Color(0xFFF2A81D),
    Color(0xFF6EC1E4),
    Color(0xFF9BD17A),
    Color(0xFFE48A8A),
    Color(0xFFB9A2E8),
    Color(0xFFE8C77D),
  ];

  static Color colorFor(Participant p, [int? index]) {
    if (p.isMe) return AppColors.amber;
    final i = index ?? (p.id.hashCode & 0x7fffffff);
    return _palette[i % _palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final color = colorFor(person, index);
    return Semantics(
      label: person.displayName,
      excludeSemantics: true,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Text(
          person.initial,
          style: TextStyle(
            color: const Color(0xFF241800),
            fontSize: size * 0.45,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
