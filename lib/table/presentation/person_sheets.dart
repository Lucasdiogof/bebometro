import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../l10n/l10n.dart';
import '../../tab/domain/tab_models.dart';
import '../../tab/presentation/tab_cubit.dart';
import 'person_avatar.dart';

/// Asks for a name (new person or rename). Null when cancelled.
Future<String?> askPersonName(
  BuildContext context, {
  String initial = '',
  required String title,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => _NameDialog(initial: initial, title: title),
  );
}

class _NameDialog extends StatefulWidget {
  const _NameDialog({required this.initial, required this.title});

  final String initial;
  final String title;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final _c = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _ok() {
    final t = _c.text.trim();
    if (t.isNotEmpty) Navigator.pop(context, t);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        key: const ValueKey('person-name'),
        controller: _c,
        autofocus: true,
        maxLength: 24,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(labelText: tr.startWhoName, counterText: ''),
        onSubmitted: (_) => _ok(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(tr.commonCancel)),
        FilledButton(
          key: const ValueKey('person-name-ok'),
          onPressed: _ok,
          child: Text(tr.startWhoAdd),
        ),
      ],
    );
  }
}

/// Adds someone to the table. Nobody is redistributed: past orders stay as
/// they were, and the new person only enters what is ordered from now on.
Future<void> addPersonFlow(BuildContext context, TabCubit cubit) async {
  final name = await askPersonName(context, title: tr.peopleAddTitle);
  if (name != null) await cubit.addParticipant(name);
}

/// Rename, mark as left (or back) and, only when nothing refers to the person,
/// remove. A person with orders, shares or payments is never deleted: they
/// can only leave, so no record is erased or silently redistributed.
Future<void> managePersonFlow(
  BuildContext context,
  TabCubit cubit,
  Participant person,
) async {
  final canRemove = cubit.canRemove(person.id);
  final action = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: PersonAvatar(person: person),
            title: Text(person.displayName, style: AppText.title),
          ),
          ListTile(
            key: const ValueKey('person-rename'),
            leading: const Icon(Icons.edit_outlined),
            title: Text(tr.peopleRename),
            onTap: () => Navigator.pop(ctx, 'rename'),
          ),
          if (!person.isMe)
            ListTile(
              key: const ValueKey('person-left'),
              leading: Icon(person.left ? Icons.login_rounded : Icons.logout_rounded),
              title: Text(person.left ? tr.peopleBack : tr.peopleMarkLeft),
              subtitle: Text(person.left ? tr.peopleBackHint : tr.peopleMarkLeftHint),
              onTap: () => Navigator.pop(ctx, 'left'),
            ),
          if (!person.isMe)
            ListTile(
              key: const ValueKey('person-remove'),
              enabled: canRemove,
              leading: Icon(Icons.person_remove_outlined, color: canRemove ? AppColors.danger : null),
              title: Text(tr.peopleRemove),
              subtitle: Text(canRemove ? tr.peopleRemoveHint : tr.peopleRemoveBlocked),
              onTap: canRemove ? () => Navigator.pop(ctx, 'remove') : null,
            ),
        ],
      ),
    ),
  );
  if (!context.mounted || action == null) return;
  switch (action) {
    case 'rename':
      final name = await askPersonName(
        context,
        initial: person.name,
        title: tr.peopleRename,
      );
      if (name != null) await cubit.renameParticipant(person.id, name);
    case 'left':
      await cubit.setLeft(person.id, !person.left);
    case 'remove':
      await cubit.removeParticipant(person.id);
  }
}
