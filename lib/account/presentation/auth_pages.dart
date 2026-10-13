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
import '../../l10n/l10n.dart';

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
      _passwordError = _password.text.isEmpty ? tr.authEnterPassword : null;
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
      title: widget.reauth ? tr.authSignInAgainTitle : tr.authSignIn,
      subtitle: widget.reauth
          ? tr.authSignInAgainBody
          : tr.authSignInBody,
      action: BusyButton(label: tr.authSignIn, busy: _busy, onPressed: _submit),
      children: [
        if (auth.notice != null) FormMessage(auth.notice!),
        if (auth.cloudUnavailable)
          FormMessage(tr.authCloudDown),
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
            child: Text(tr.authForgot),
          ),
        ),
        const SizedBox(height: AppSpace.md),
        OutlinedButton(
          onPressed: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const SignUpPage())),
          child: Text(tr.authCreateAccount),
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
      _nameError = _name.text.trim().isEmpty ? tr.authNameMissing : null;
      _emailError = validateEmail(_email.text);
      if (!widget.convert) {
        _passwordError = validateNewPassword(_password.text);
        _confirmError = _confirm.text != _password.text
            ? tr.authPasswordsDiffer
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
      title: widget.convert ? tr.authCreateWithRecords : tr.authCreateAccount,
      subtitle: widget.convert
          ? tr.authConvertBody
          : null,
      action: BusyButton(
          label: widget.convert ? tr.authSendConfirmation : tr.authCreateAccount,
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
            labelText: tr.accountName,
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
            helper: tr.authPasswordHelper,
          ),
          const SizedBox(height: AppSpace.md),
          PasswordField(
            controller: _confirm,
            label: tr.authConfirmPassword,
            newPassword: true,
            done: true,
            error: _confirmError,
            onSubmitted: (_) => _submit(),
          ),
        ],
        const SizedBox(height: AppSpace.md),
        Text(tr.authSignUpNote, style: AppText.caption),
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
          _message = tr.authResent;
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
      title: tr.authCheckInboxTitle,
      subtitle: tr.authCheckInboxBody(s.pendingEmail ?? tr.authYourEmail),
      action: OutlinedButton(
        onPressed: _busy || wait > 0 ? null : _resend,
        child: Text(wait > 0 ? tr.authResendIn(wait) : tr.authResend),
      ),
      children: [
        if (s.notice != null) FormMessage(s.notice!),
        if (_message != null) FormMessage(_message!, error: _messageIsError),
        SurfaceCard(
          child: Row(children: [
            Icon(Icons.mark_email_unread_outlined, color: AppColors.amber),
            SizedBox(width: AppSpace.md),
            Expanded(
              child: Text(tr.authNotArrived, style: AppText.body),
            ),
          ]),
        ),
        const SizedBox(height: AppSpace.lg),
        if (s.converting)
          TextButton(
            onPressed: () => context.read<AuthController>().cancelConversion(),
            child: Text(tr.authUseOtherEmailBack),
          )
        else ...[
          FilledButton.tonal(
            onPressed: () => context.read<AuthController>().forgetPendingEmail(),
            child: Text(tr.authAlreadyConfirmed),
          ),
          TextButton(
            onPressed: () => context.read<AuthController>().forgetPendingEmail(),
            child: Text(tr.authUseOtherEmail),
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
      title: tr.authRecoverTitle,
      subtitle: tr.authRecoverBody,
      action: BusyButton(
          label: _sent ? tr.authSendAgain : tr.authSendLink,
          busy: _busy,
          onPressed: _submit),
      children: [
        if (_sent)
          FormMessage(tr.authRecoverSent, error: false),
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
          _confirm.text != _password.text ? tr.authPasswordsDiffer : null;
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
      title: widget.recovery ? tr.authNewPasswordTitle : tr.authChoosePassword,
      subtitle: widget.recovery
          ? tr.authNewPasswordFor(s.email ?? tr.authYourAccount)
          : tr.authChoosePasswordBody,
      action: BusyButton(label: tr.authSavePassword, busy: _busy, onPressed: _submit),
      children: [
        if (_error != null) FormMessage(_error!),
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
          done: true,
          error: _confirmError,
          onSubmitted: (_) => _submit(),
        ),
        if (widget.recovery) ...[
          const SizedBox(height: AppSpace.lg),
          TextButton(
            onPressed: () => context.read<AuthController>().cancelRecovery(),
            child: Text(tr.authCancelAndLeave),
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
      title: tr.legacyAnonTitle,
      subtitle: tr.legacyAnonBody,
      action: FilledButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const SignUpPage(convert: true))),
        child: Text(tr.legacyAnonCreate),
      ),
      children: [
        if (s.notice != null) FormMessage(s.notice!),
        SurfaceCard(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const SignInPage())),
          child: Row(children: [
            Icon(Icons.login_rounded, color: AppColors.amber),
            SizedBox(width: AppSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tr.legacyAnonHaveAccount, style: AppText.subtitle),
                  Text(tr.legacyAnonHaveAccountHint, style: AppText.caption),
                ],
              ),
            ),
          ]),
        ),
        const SizedBox(height: AppSpace.sm),
        SurfaceCard(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const LegacyDataPage())),
          child: Row(children: [
            Icon(Icons.inventory_2_outlined, color: AppColors.amber),
            SizedBox(width: AppSpace.md),
            Expanded(
              child: Text(tr.legacyAnonView,
                  style: AppText.subtitle),
            ),
          ]),
        ),
      ],
    );
  }
}
