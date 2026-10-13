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
import '../data/legacy_data.dart';
import 'auth_widgets.dart';
import 'conflicts_page.dart';
import 'legacy_data_page.dart';

/// "Minha conta": profile, password, what is saved where, sign out and
/// account deletion.
class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool _syncing = false;
  LegacyInfo? _legacy;

  @override
  void initState() {
    super.initState();
    getIt<LegacyData>().info().then((i) {
      if (mounted) setState(() => _legacy = i);
    });
  }

  Future<void> _editName(String? current) async {
    final controller = TextEditingController(text: current ?? '');
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Seu nome'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          autofillHints: const [AutofillHints.name],
          decoration: const InputDecoration(labelText: 'Nome'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: const Text('Salvar')),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.trim().isEmpty || !mounted) return;
    try {
      await context.read<AuthController>().updateName(name);
      if (mounted) showToast(context, 'Nome atualizado');
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
        title: const Text('Sair da conta?'),
        content: Text(waiting
            ? 'Há ${sync.pending} alteração(ões) ainda não enviadas'
                '${sync.conflicts > 0 ? ' e ${sync.conflicts} para resolver' : ''}. '
                'Elas continuam guardadas neste aparelho, presas a esta conta, e '
                'só reaparecem quando você entrar nela de novo.'
            : 'Seus dados estão na nuvem e voltam quando você entrar de novo. '
                'Neste aparelho eles ficam guardados só para esta conta.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          if (waiting)
            TextButton(
                onPressed: () => Navigator.pop(ctx, 'sync'),
                child: const Text('Sincronizar antes')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, 'out'),
              child: const Text('Sair')),
        ],
      ),
    );
    if (choice == 'sync') {
      await _syncNow();
      if (mounted) {
        final s = context.read<SyncCubit>().state;
        showToast(
            context,
            s.allSaved
                ? 'Tudo enviado. Agora você pode sair.'
                : 'Ainda há pendências: elas ficam guardadas neste aparelho.');
      }
      return;
    }
    if (choice == 'out') await auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final a = context.watch<AuthController>().state;
    return Scaffold(
      appBar: AppBar(title: const Text('Minha conta')),
      body: BlocBuilder<SyncCubit, SyncState>(
        builder: (context, sync) {
          final rowsWaiting = getIt<LocalStore>().pendingCount;
          final filesWaiting = (sync.pending - rowsWaiting).clamp(0, 1 << 30);
          return ListView(
            padding: const EdgeInsets.fromLTRB(
                AppSpace.gutter, 0, AppSpace.gutter, AppSpace.xxl),
            children: [
              SurfaceCard(
                highlight: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text(a.displayName ?? 'Sem nome',
                            style: AppText.headline),
                      ),
                      IconButton(
                        tooltip: 'Editar nome',
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _editName(a.displayName),
                      ),
                    ]),
                    Text(a.email ?? '', style: AppText.body),
                    const SizedBox(height: AppSpace.sm),
                    InfoPill(
                      a.emailConfirmed ? 'E-mail confirmado' : 'E-mail não confirmado',
                      icon: a.emailConfirmed
                          ? Icons.verified_outlined
                          : Icons.mark_email_unread_outlined,
                      warning: !a.emailConfirmed,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpace.sm),
              SurfaceCard(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const ChangePasswordPage())),
                child: const Row(children: [
                  Icon(Icons.password_rounded, color: AppColors.amber),
                  SizedBox(width: AppSpace.md),
                  Expanded(child: Text('Alterar senha', style: AppText.subtitle)),
                  Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                ]),
              ),
              const SectionTitle('Seus dados'),
              SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StatTile(
                      label: 'Nuvem',
                      value: sync.restoring
                          ? 'Recuperando…'
                          : sync.allSaved
                              ? 'Tudo confirmado na nuvem'
                              : sync.label,
                      icon: Icons.cloud_done_outlined,
                    ),
                    const SizedBox(height: AppSpace.md),
                    Text(
                      sync.lastSyncAt == null
                          ? 'Última sincronização concluída: ainda não houve.'
                          : 'Última sincronização concluída: '
                              '${formatDateTime(sync.lastSyncAt!)}',
                      style: AppText.caption,
                    ),
                    const SizedBox(height: AppSpace.xs),
                    Text(
                      rowsWaiting == 0 && filesWaiting == 0
                          ? 'Nada aguardando envio.'
                          : 'Salvo só neste aparelho por enquanto: '
                              '$rowsWaiting registro(s)'
                              '${filesWaiting > 0 ? ' e $filesWaiting foto(s)' : ''}.',
                      style: AppText.caption,
                    ),
                    if (!sync.historyRestored)
                      const Padding(
                        padding: EdgeInsets.only(top: AppSpace.xs),
                        child: Text(
                          'O histórico da nuvem ainda não terminou de chegar '
                          'neste aparelho.',
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
                      label: 'Sincronizar agora',
                      busy: _syncing || sync.status == SyncStatus.syncing,
                      onPressed: _syncNow,
                    ),
                  ],
                ),
              ),
              if (sync.conflicts > 0) ...[
                const SizedBox(height: AppSpace.sm),
                SurfaceCard(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const ConflictsPage())),
                  child: Row(children: [
                    const Icon(Icons.call_split_rounded, color: AppColors.amber),
                    const SizedBox(width: AppSpace.md),
                    Expanded(
                      child: Text(
                        '${sync.conflicts} alteração(ões) para resolver',
                        style: AppText.subtitle,
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.textMuted),
                  ]),
                ),
              ],
              if (_legacy?.hasData == true) ...[
                const SizedBox(height: AppSpace.sm),
                SurfaceCard(
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const LegacyDataPage())),
                  child: Row(children: [
                    const Icon(Icons.inventory_2_outlined,
                        color: AppColors.amber),
                    const SizedBox(width: AppSpace.md),
                    Expanded(
                      child: Text(
                        _legacy!.needsDecision || _legacy!.status == LegacyStatus.kept
                            ? 'Registros antigos deste aparelho: importar ou exportar'
                            : 'Registros antigos deste aparelho',
                        style: AppText.subtitle,
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.textMuted),
                  ]),
                ),
              ],
              const SectionTitle('Sessão'),
              OutlinedButton.icon(
                onPressed: _signOut,
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sair'),
              ),
              const SizedBox(height: AppSpace.sm),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const DeleteAccountPage())),
                child: const Text('Excluir conta'),
              ),
            ],
          );
        },
      ),
    );
  }
}

// --------------------------------------------------------- change password

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
      setState(() {
        _needsCode = true;
        _info = 'Enviamos um código para o seu e-mail.';
        _error = null;
      });
    } on AuthFailure catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _submit() async {
    setState(() {
      _passwordError = validateNewPassword(_password.text);
      _confirmError =
          _confirm.text != _password.text ? 'As senhas não são iguais.' : null;
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
        showToast(context, 'Senha alterada');
        Navigator.of(context).pop();
      }
    } on AuthFailure catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.message.contains('código')) {
          // The project requires a code for password changes.
          _needsCode = true;
          _error = e.message;
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
      title: 'Alterar senha',
      action: BusyButton(label: 'Salvar nova senha', busy: _busy, onPressed: _submit),
      children: [
        if (_error != null) FormMessage(_error!),
        if (_info != null) FormMessage(_info!, error: false),
        PasswordField(
          controller: _password,
          label: 'Nova senha',
          newPassword: true,
          error: _passwordError,
          helper: 'Pelo menos 8 caracteres, com letras e números.',
        ),
        const SizedBox(height: AppSpace.md),
        PasswordField(
          controller: _confirm,
          label: 'Confirmar nova senha',
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
            decoration: const InputDecoration(
              labelText: 'Código recebido por e-mail',
              prefixIcon: Icon(Icons.pin_outlined),
            ),
          ),
          TextButton(
            onPressed: _busy ? null : _sendCode,
            child: const Text('Enviar código de novo'),
          ),
        ],
      ],
    );
  }
}

// ------------------------------------------------------------ delete account

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
      setState(() => _error = 'Marque a confirmação para continuar.');
      return;
    }
    if (_password.text.isEmpty) {
      setState(() => _passwordError = 'Confirme sua senha.');
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
          setState(() => _passwordError = 'Confirme sua senha de novo.');
        case DeleteOutcome.partial:
          setState(() => _error =
              'A exclusão começou mas não terminou. Nada local foi apagado. '
              'Toque em "Excluir conta" de novo para continuar.');
        case DeleteOutcome.unavailable:
          setState(() => _error =
              'A exclusão ainda não está disponível no servidor. Nada foi '
              'apagado. Tente mais tarde.');
        case DeleteOutcome.offline:
          setState(() => _error = 'Sem conexão. Nada foi apagado.');
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
      title: 'Excluir conta',
      subtitle: 'Isso apaga de vez a sua conta, todos os rolês, bebidas, locais, '
          'comandas e fotos guardados na nuvem, e os dados desta conta neste '
          'aparelho. Não dá para desfazer.',
      action: FilledButton(
        style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
        onPressed: _busy ? null : _delete,
        child: _busy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2))
            : const Text('Excluir conta'),
      ),
      children: [
        if (_error != null) FormMessage(_error!),
        const Text(
          'Se quiser guardar uma cópia, exporte seus dados antes (Configurações '
          '> Exportar meus dados).',
          style: AppText.caption,
        ),
        const SizedBox(height: AppSpace.md),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: _understood,
          activeColor: AppColors.danger,
          onChanged: (v) => setState(() => _understood = v ?? false),
          title: const Text('Entendo que a exclusão é permanente.'),
        ),
        PasswordField(
          controller: _password,
          label: 'Sua senha',
          error: _passwordError,
          done: true,
        ),
      ],
    );
  }
}
