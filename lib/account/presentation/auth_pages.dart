import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../application/auth_controller.dart';
import 'auth_widgets.dart';
import 'legacy_data_page.dart';

// ------------------------------------------------------------------ sign in

/// Entry point without an account. Also used when the server asked to sign
/// in again ([reauth]): the e-mail comes filled and the data of that account
/// is still on the device.
class SignInPage extends StatefulWidget {
  const SignInPage({super.key, this.reauth = false});

  final bool reauth;

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  late final _email =
      TextEditingController(text: context.read<AuthController>().state.email ?? '');
  final _password = TextEditingController();
  bool _busy = false;
  String? _emailError;
  String? _passwordError;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final emailErr = validateEmail(_email.text);
    setState(() {
      _emailError = emailErr;
      _passwordError = _password.text.isEmpty ? 'Informe sua senha.' : null;
      _error = null;
    });
    if (emailErr != null || _password.text.isEmpty) return;
    setState(() => _busy = true);
    try {
      await context.read<AuthController>().signIn(_email.text, _password.text);
      TextInput.finishAutofillContext();
    } on AuthFailure catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.field == 'password') {
          _passwordError = e.message;
        } else if (e.field == 'email') {
          _emailError = e.message;
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
    final auth = context.watch<AuthController>().state;
    return AuthScaffold(
      title: widget.reauth ? 'Entre novamente' : 'Entrar',
      subtitle: widget.reauth
          ? 'Sua sessão terminou no servidor. Seus registros continuam neste '
              'aparelho e voltam quando você entrar na mesma conta.'
          : 'Seus rolês ficam salvos na sua conta e voltam em qualquer aparelho.',
      action: BusyButton(label: 'Entrar', busy: _busy, onPressed: _submit),
      children: [
        if (auth.notice != null) FormMessage(auth.notice!),
        if (auth.cloudUnavailable)
          const FormMessage(
              'Não foi possível falar com o servidor agora. Confira a internet '
              'e tente de novo em instantes.'),
        if (_error != null) FormMessage(_error!),
        EmailField(controller: _email, error: _emailError),
        const SizedBox(height: AppSpace.md),
        PasswordField(
          controller: _password,
          error: _passwordError,
          done: true,
          onSubmitted: (_) => _submit(),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ForgotPasswordPage(initialEmail: _email.text))),
            child: const Text('Esqueci minha senha'),
          ),
        ),
        const SizedBox(height: AppSpace.md),
        OutlinedButton(
          onPressed: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const SignUpPage())),
          child: const Text('Criar conta'),
        ),
        const SizedBox(height: AppSpace.lg),
        const LegacyNoticeCard(),
      ],
    );
  }
}

// ------------------------------------------------------------------ sign up

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key, this.convert = false});

  /// Converting the old anonymous session (keeps its records): no password
  /// here, it is asked after the e-mail is confirmed (Supabase rule).
  final bool convert;

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;
  String? _nameError, _emailError, _passwordError, _confirmError, _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _nameError = _name.text.trim().isEmpty ? 'Como podemos te chamar?' : null;
      _emailError = validateEmail(_email.text);
      if (!widget.convert) {
        _passwordError = validateNewPassword(_password.text);
        _confirmError = _confirm.text != _password.text
            ? 'As senhas não são iguais.'
            : null;
      }
      _error = null;
    });
    if ([_nameError, _emailError, _passwordError, _confirmError]
        .any((e) => e != null)) {
      return;
    }
    setState(() => _busy = true);
    final auth = context.read<AuthController>();
    try {
      if (widget.convert) {
        await auth.convertAnonymous(_name.text, _email.text);
      } else {
        await auth.signUp(_name.text, _email.text, _password.text);
      }
      TextInput.finishAutofillContext();
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    } on AuthFailure catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.field == 'email') {
          _emailError = e.message;
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
      title: widget.convert ? 'Criar conta com seus registros' : 'Criar conta',
      subtitle: widget.convert
          ? 'Seus registros deste aparelho continuam com você. Depois de '
              'confirmar o e-mail, você escolhe a senha.'
          : null,
      action: BusyButton(
          label: widget.convert ? 'Enviar confirmação' : 'Criar conta',
          busy: _busy,
          onPressed: _submit),
      children: [
        if (_error != null) FormMessage(_error!),
        TextField(
          controller: _name,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.name],
          decoration: InputDecoration(
            labelText: 'Nome',
            prefixIcon: const Icon(Icons.person_outline_rounded),
            errorText: _nameError,
          ),
        ),
        const SizedBox(height: AppSpace.md),
        EmailField(controller: _email, error: _emailError),
        if (!widget.convert) ...[
          const SizedBox(height: AppSpace.md),
          PasswordField(
            controller: _password,
            newPassword: true,
            error: _passwordError,
            helper: 'Pelo menos 8 caracteres, com letras e números.',
          ),
          const SizedBox(height: AppSpace.md),
          PasswordField(
            controller: _confirm,
            label: 'Confirmar senha',
            newPassword: true,
            done: true,
            error: _confirmError,
            onSubmitted: (_) => _submit(),
          ),
        ],
        const SizedBox(height: AppSpace.md),
        const Text(
          'Vamos enviar um link para confirmar o e-mail. Seu nome e e-mail só '
          'servem para a sua conta.',
          style: AppText.caption,
        ),
      ],
    );
  }
}

// -------------------------------------------------------------- check e-mail

class CheckEmailPage extends StatefulWidget {
  const CheckEmailPage({super.key});

  @override
  State<CheckEmailPage> createState() => _CheckEmailPageState();
}

class _CheckEmailPageState extends State<CheckEmailPage> {
  Timer? _tick;
  bool _busy = false;
  String? _message;
  bool _messageIsError = false;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  Future<void> _resend() async {
    setState(() => _busy = true);
    try {
      await context.read<AuthController>().resendConfirmation();
      if (mounted) {
        setState(() {
          _message = 'Enviamos outro e-mail. Confira também o spam.';
          _messageIsError = false;
        });
      }
    } on AuthFailure catch (e) {
      if (mounted) {
        setState(() {
          _message = e.message;
          _messageIsError = true;
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final s = auth.state;
    final wait = auth.resendWaitSeconds;
    return AuthScaffold(
      title: 'Confira seu e-mail',
      subtitle: 'Enviamos um link para ${s.pendingEmail ?? 'o seu e-mail'}. '
          'Abra o link neste aparelho para concluir.',
      action: OutlinedButton(
        onPressed: _busy || wait > 0 ? null : _resend,
        child: Text(wait > 0 ? 'Reenviar em $wait s' : 'Reenviar e-mail'),
      ),
      children: [
        if (s.notice != null) FormMessage(s.notice!),
        if (_message != null) FormMessage(_message!, error: _messageIsError),
        const SurfaceCard(
          child: Row(children: [
            Icon(Icons.mark_email_unread_outlined, color: AppColors.amber),
            SizedBox(width: AppSpace.md),
            Expanded(
              child: Text(
                'Não chegou? Confira o spam e se o endereço está certo. O link '
                'vale por tempo limitado.',
                style: AppText.body,
              ),
            ),
          ]),
        ),
        const SizedBox(height: AppSpace.lg),
        if (s.converting)
          TextButton(
            onPressed: () => context.read<AuthController>().cancelConversion(),
            child: const Text('Voltar e usar outro e-mail'),
          )
        else ...[
          FilledButton.tonal(
            onPressed: () => context.read<AuthController>().forgetPendingEmail(),
            child: const Text('Já confirmei: entrar'),
          ),
          TextButton(
            onPressed: () => context.read<AuthController>().forgetPendingEmail(),
            child: const Text('Usar outro e-mail'),
          ),
        ],
      ],
    );
  }
}

// ------------------------------------------------------------ forgot/reset

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late final _email = TextEditingController(text: widget.initialEmail);
  bool _busy = false;
  bool _sent = false;
  String? _emailError;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final err = validateEmail(_email.text);
    setState(() {
      _emailError = err;
      _error = null;
    });
    if (err != null) return;
    setState(() => _busy = true);
    try {
      await context.read<AuthController>().sendPasswordReset(_email.text);
      if (mounted) setState(() => _sent = true);
    } on AuthFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBack: true,
      title: 'Recuperar senha',
      subtitle: 'Enviamos um link para criar uma nova senha. Abra-o neste '
          'aparelho.',
      action: BusyButton(
          label: _sent ? 'Enviar de novo' : 'Enviar link',
          busy: _busy,
          onPressed: _submit),
      children: [
        if (_sent)
          const FormMessage(
            'Se houver uma conta com esse e-mail, o link chega em instantes. '
            'Confira também o spam.',
            error: false,
          ),
        if (_error != null) FormMessage(_error!),
        EmailField(
          controller: _email,
          error: _emailError,
          autofocus: widget.initialEmail.isEmpty,
          onSubmitted: (_) => _submit(),
        ),
      ],
    );
  }
}

/// New password: after a reset link ([recovery]) or the first password of a
/// converted anonymous account. Nothing else of the app opens before it.
class NewPasswordPage extends StatefulWidget {
  const NewPasswordPage({super.key, required this.recovery});

  final bool recovery;

  @override
  State<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends State<NewPasswordPage> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;
  String? _passwordError, _confirmError, _error;

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
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
      await context.read<AuthController>().setPassword(_password.text);
      TextInput.finishAutofillContext();
    } on AuthFailure catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.field == 'password') {
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
    final s = context.watch<AuthController>().state;
    return AuthScaffold(
      title: widget.recovery ? 'Nova senha' : 'Escolha sua senha',
      subtitle: widget.recovery
          ? 'Crie uma nova senha para ${s.email ?? 'sua conta'}.'
          : 'E-mail confirmado. Agora escolha a senha para entrar em outros '
              'aparelhos.',
      action: BusyButton(label: 'Salvar senha', busy: _busy, onPressed: _submit),
      children: [
        if (_error != null) FormMessage(_error!),
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
          done: true,
          error: _confirmError,
          onSubmitted: (_) => _submit(),
        ),
        if (widget.recovery) ...[
          const SizedBox(height: AppSpace.lg),
          TextButton(
            onPressed: () => context.read<AuthController>().cancelRecovery(),
            child: const Text('Cancelar e sair'),
          ),
        ],
      ],
    );
  }
}

// ------------------------------------------------------- old anonymous user

/// The device still has the anonymous session of an older version. The
/// product stays closed until the person creates the account (keeping the
/// same records) or signs in to another one (records kept apart, importable).
class LegacyAnonymousPage extends StatelessWidget {
  const LegacyAnonymousPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AuthController>().state;
    return AuthScaffold(
      title: 'Agora o Bebômetro usa conta',
      subtitle: 'Se você já usava o app neste aparelho, seus registros foram '
          'guardados. Crie sua conta para continuar com eles e recuperá-los em '
          'outro aparelho.',
      action: FilledButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const SignUpPage(convert: true))),
        child: const Text('Criar conta com meus registros'),
      ),
      children: [
        if (s.notice != null) FormMessage(s.notice!),
        SurfaceCard(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const SignInPage())),
          child: const Row(children: [
            Icon(Icons.login_rounded, color: AppColors.amber),
            SizedBox(width: AppSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Já tenho conta', style: AppText.subtitle),
                  Text(
                    'Os registros antigos ficam separados neste aparelho; você '
                    'decide depois se importa para a conta.',
                    style: AppText.caption,
                  ),
                ],
              ),
            ),
          ]),
        ),
        const SizedBox(height: AppSpace.sm),
        SurfaceCard(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const LegacyDataPage())),
          child: const Row(children: [
            Icon(Icons.inventory_2_outlined, color: AppColors.amber),
            SizedBox(width: AppSpace.md),
            Expanded(
              child: Text('Ver ou exportar os registros antigos',
                  style: AppText.subtitle),
            ),
          ]),
        ),
      ],
    );
  }
}
