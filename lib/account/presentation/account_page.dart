import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/data/device_store.dart';
import '../../core/data/local_store.dart';
import '../../core/di/injector.dart';
import '../../core/sync/sync_cubit.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../scan/data/photo_files.dart';
import '../application/auth_controller.dart';
import '../data/account_service.dart';
import 'auth_widgets.dart';
import 'conflicts_page.dart';
import '../../l10n/l10n.dart';

/// "Minha conta": profile, password, what is saved where, sign out and
/// account deletion.
class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool _syncing = false;
  Future<void> _editName(String? current) async {
    final controller = TextEditingController(text: current ?? '');
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr.accountYourName),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          autofillHints: const [AutofillHints.name],
          decoration: InputDecoration(labelText: tr.accountName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: Text(tr.commonSave),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.trim().isEmpty || !mounted) return;
    try {
      await context.read<AuthController>().updateName(name);
      if (mounted) showToast(context, tr.accountNameUpdated);
    } on AuthFailure catch (e) {
      if (mounted) showToast(context, e.message);
    }
  }

  Future<void> _syncNow() async {
    setState(() => _syncing = true);
    await context.read<SyncCubit>().syncNow();
    if (mounted) setState(() => _syncing = false);
  }

  Future<void> _signOut() async {
    final sync = context.read<SyncCubit>().state;
    final auth = context.read<AuthController>();
    final waiting = sync.pending > 0 || sync.conflicts > 0;
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr.accountSignOutTitle),
        content: Text(
          waiting
              ? [
                  tr.accountSignOutPending(sync.pending),
                  if (sync.conflicts > 0)
                    tr.accountSignOutConflicts(sync.conflicts),
                ].join(' ')
              : tr.accountSignOutClean,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(tr.commonCancel),
          ),
          if (waiting)
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'sync'),
              child: Text(tr.accountSyncFirst),
            ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, 'out'),
            child: Text(tr.accountSignOut),
          ),
        ],
      ),
    );
    if (choice == 'sync') {
      await _syncNow();
      if (mounted) {
        final s = context.read<SyncCubit>().state;
        showToast(
          context,
          s.allSaved ? tr.accountAllSentNow : tr.accountStillPending,
        );
      }
      return;
    }
    if (choice == 'out') await auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final a = context.watch<AuthController>().state;
    return Scaffold(
      appBar: AppBar(title: Text(tr.settingsAccount)),
      body: BlocBuilder<SyncCubit, SyncState>(
        builder: (context, sync) {
          // While signing out this screen is still animating away after the
          // account's data scope was closed: nothing to count then.
          final rowsWaiting = AccountScope.isOpen
              ? getIt<LocalStore>().pendingCount
              : 0;
          final filesWaiting = (sync.pending - rowsWaiting).clamp(0, 1 << 30);
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpace.gutter,
              0,
              AppSpace.gutter,
              AppSpace.xxl,
            ),
            children: [
              SurfaceCard(
                highlight: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            a.displayName ?? tr.accountNoName,
                            style: AppText.headline,
                          ),
                        ),
                        IconButton(
                          tooltip: tr.accountEditName,
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _editName(a.displayName),
                        ),
                      ],
                    ),
                    Text(a.email ?? '', style: AppText.body),
                    const SizedBox(height: AppSpace.sm),
                    if (a.emailConfirmed)
                      InfoPill(
                        tr.accountEmailConfirmed,
                        icon: Icons.verified_outlined,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpace.sm),
              SurfaceCard(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
                ),
                child: Row(
                  children: [
                    Icon(Icons.password_rounded, color: AppColors.amber),
                    SizedBox(width: AppSpace.md),
                    Expanded(
                      child: Text(
                        tr.accountChangePassword,
                        style: AppText.subtitle,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
              SectionTitle(tr.accountYourData),
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatTile(
                      label: tr.accountCloud,
                      value: sync.restoring
                          ? tr.accountRestoring
                          : sync.allSaved
                          ? tr.accountAllConfirmed
                          : sync.label,
                      icon: Icons.cloud_done_outlined,
                    ),
                    const SizedBox(height: AppSpace.md),
                    Text(
                      sync.lastSyncAt == null
                          ? tr.accountLastSyncNever
                          : tr.accountLastSync(
                              formatDateTime(sync.lastSyncAt!),
                            ),
                      style: AppText.caption,
                    ),
                    const SizedBox(height: AppSpace.xs),
                    Text(
                      rowsWaiting == 0 && filesWaiting == 0
                          ? tr.accountNothingWaiting
                          : [
                              tr.accountOnlyHereRecords(rowsWaiting),
                              if (filesWaiting > 0)
                                tr.accountOnlyHerePhotos(filesWaiting),
                            ].join(' '),
                      style: AppText.caption,
                    ),
                    if (!sync.historyRestored)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpace.xs),
                        child: Text(
                          tr.accountHistoryNotDone,
                          style: AppText.caption,
                        ),
                      ),
                    if (sync.message != null && !sync.allSaved)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpace.xs),
                        child: Text(sync.message!, style: AppText.caption),
                      ),
                    const SizedBox(height: AppSpace.md),
                    BusyButton(
                      label: tr.settingsSyncNow,
                      busy: _syncing || sync.status == SyncStatus.syncing,
                      onPressed: _syncNow,
                    ),
                  ],
                ),
              ),
              if (sync.conflicts > 0) ...[
                const SizedBox(height: AppSpace.sm),
                SurfaceCard(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ConflictsPage()),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.call_split_rounded,
                        color: AppColors.amber,
                      ),
                      const SizedBox(width: AppSpace.md),
                      Expanded(
                        child: Text(
                          tr.accountConflicts(sync.conflicts),
                          style: AppText.subtitle,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                ),
              ],
              SectionTitle(tr.accountSession),
              OutlinedButton.icon(
                onPressed: _signOut,
                icon: const Icon(Icons.logout_rounded),
                label: Text(tr.accountSignOut),
              ),
              const SizedBox(height: AppSpace.sm),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const DeleteAccountPage()),
                ),
                child: Text(tr.accountDelete),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _code = TextEditingController();
  bool _busy = false;
  bool _needsCode = false;
  bool _codeAutoSent = false;
  String? _passwordError, _confirmError, _error, _info;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    setState(() => _busy = true);
    try {
      await context.read<AuthController>().reauthenticate();
      if (!mounted) return;
      setState(() {
        _needsCode = true;
        _info = tr.accountCodeSent;
        _error = null;
      });
    } on AuthFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submit() async {
    setState(() {
      _passwordError = validateNewPassword(_password.text);
      _confirmError = _confirm.text != _password.text
          ? tr.authPasswordsDiffer
          : null;
      _error = null;
    });
    if (_passwordError != null || _confirmError != null) return;
    setState(() => _busy = true);
    try {
      await context.read<AuthController>().changePassword(
        _password.text,
        nonce: _needsCode && _code.text.trim().isNotEmpty
            ? _code.text.trim()
            : null,
      );
      if (mounted) {
        showToast(context, tr.accountPasswordChanged);
        Navigator.of(context).pop();
      }
    } on AuthFailure catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.field == 'code') {
          // The project requires a code for password changes.
          _needsCode = true;
          _error = e.message;
          if (!_codeAutoSent) {
            // Nothing was sent yet: send the code now instead of asking the
            // person to find the resend button first.
            _codeAutoSent = true;
            Future.microtask(_sendCode);
          }
        } else if (e.field == 'password') {
          _passwordError = e.message;
        } else {
          _error = e.message;
        }
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBack: true,
      title: tr.accountChangePassword,
      action: BusyButton(
        label: tr.accountSaveNewPassword,
        busy: _busy,
        onPressed: _submit,
      ),
      children: [
        if (_error != null) FormMessage(_error!),
        if (_info != null) FormMessage(_info!, error: false),
        PasswordField(
          controller: _password,
          label: tr.authNewPassword,
          newPassword: true,
          error: _passwordError,
          helper: tr.authPasswordHelper,
        ),
        const SizedBox(height: AppSpace.md),
        PasswordField(
          controller: _confirm,
          label: tr.authConfirmNewPassword,
          newPassword: true,
          done: !_needsCode,
          error: _confirmError,
        ),
        if (_needsCode) ...[
          const SizedBox(height: AppSpace.md),
          TextField(
            controller: _code,
            keyboardType: TextInputType.number,
            autofillHints: const [AutofillHints.oneTimeCode],
            decoration: InputDecoration(
              labelText: tr.accountCodeField,
              prefixIcon: const Icon(Icons.pin_outlined),
            ),
          ),
          TextButton(
            onPressed: _busy ? null : _sendCode,
            child: Text(tr.accountResendCode),
          ),
        ],
      ],
    );
  }
}

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final _password = TextEditingController();
  bool _understood = false;
  bool _busy = false;
  String? _error;
  String? _passwordError;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _delete() async {
    if (!_understood) {
      setState(() => _error = tr.deleteTickFirst);
      return;
    }
    if (_password.text.isEmpty) {
      setState(() => _passwordError = tr.deleteConfirmPassword);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _passwordError = null;
    });
    final auth = context.read<AuthController>();
    final userId = auth.state.userId;
    try {
      // Fresh sign-in of the same person right before the deletion.
      await auth.verifyPassword(_password.text);
      final service = AccountService(getIt<DeviceStore>(), getIt<PhotoFiles>());
      final outcome = await service.deleteOnServer();
      if (!mounted) return;
      switch (outcome) {
        case DeleteOutcome.done:
          // Only now: sign out (the gate leaves the account), end the
          // lock-screen surface with the scope, then clean this device.
          await auth.forgetAccount();
          await AccountScope.close();
          if (userId != null) await service.wipeLocal(userId);
          return;
        case DeleteOutcome.needsReauth:
          setState(() => _passwordError = tr.deleteConfirmPasswordAgain);
        case DeleteOutcome.partial:
          setState(() => _error = tr.deletePartial);
        case DeleteOutcome.unavailable:
          setState(() => _error = tr.deleteUnavailable);
        case DeleteOutcome.offline:
          setState(() => _error = tr.deleteOffline);
      }
    } on AuthFailure catch (e) {
      if (mounted) {
        setState(() {
          if (e.field == 'password') {
            _passwordError = e.message;
          } else {
            _error = e.message;
          }
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBack: true,
      title: tr.accountDelete,
      subtitle: tr.deleteBody,
      action: FilledButton(
        style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
        onPressed: _busy ? null : _delete,
        child: _busy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(tr.accountDelete),
      ),
      children: [
        if (_error != null) FormMessage(_error!),
        Text(tr.deleteExportFirst, style: AppText.caption),
        const SizedBox(height: AppSpace.md),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: _understood,
          activeColor: AppColors.danger,
          onChanged: (v) => setState(() => _understood = v ?? false),
          title: Text(tr.deleteUnderstand),
        ),
        PasswordField(
          controller: _password,
          label: tr.deleteYourPassword,
          error: _passwordError,
          done: true,
        ),
      ],
    );
  }
}
