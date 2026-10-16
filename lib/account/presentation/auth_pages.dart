import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_tokens.dart';
import '../application/auth_controller.dart';
import 'auth_widgets.dart';
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
      ],
    );
  }
}

// ------------------------------------------------------------------ sign up

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

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
      _passwordError = validateNewPassword(_password.text);
      _confirmError =
          _confirm.text != _password.text ? tr.authPasswordsDiffer : null;
      _error = null;
    });
    if ([_nameError, _emailError, _passwordError, _confirmError]
        .any((e) => e != null)) {
      return;
    }
    setState(() => _busy = true);
    final auth = context.read<AuthController>();
    try {
      await auth.signUp(_name.text, _email.text, _password.text);
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
      title: tr.authCreateAccount,
      action: BusyButton(
          label: tr.authCreateAccount, busy: _busy, onPressed: _submit),
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
        const SizedBox(height: AppSpace.md),
        Text(tr.authSignUpNote, style: AppText.caption),
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
  String? _emailError;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _openCodePage({required bool sent}) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ResetCodePage(email: _email.text.trim(), sent: sent)));
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
      if (mounted) _openCodePage(sent: true);
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
      action:
          BusyButton(label: tr.authSendLink, busy: _busy, onPressed: _submit),
      children: [
        if (_error != null) FormMessage(_error!),
        EmailField(
          controller: _email,
          error: _emailError,
          autofocus: widget.initialEmail.isEmpty,
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: AppSpace.md),
        TextButton(
          onPressed: () {
            final err = validateEmail(_email.text);
            setState(() => _emailError = err);
            if (err == null) _openCodePage(sent: false);
          },
          child: Text(tr.authHaveCode),
        ),
      ],
    );
  }
}

/// Second step of the recovery: e-mail + the 6-digit code that came by
/// e-mail. Works on any device (no link, no deep link, no PKCE). A valid code
/// opens a session and the access gate shows the new-password screen.
class ResetCodePage extends StatefulWidget {
  const ResetCodePage({super.key, required this.email, this.sent = false});

  final String email;

  /// A code was just requested for [email] (starts the resend wait).
  final bool sent;

  @override
  State<ResetCodePage> createState() => _ResetCodePageState();
}

class _ResetCodePageState extends State<ResetCodePage> {
  late final _email = TextEditingController(text: widget.email);
  final _code = TextEditingController();
  Timer? _ticker;
  bool _busy = false;
  bool _resending = false;
  String? _emailError, _codeError, _error, _info;

  @override
  void initState() {
    super.initState();
    if (widget.sent) _info = tr.authRecoverSent;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _email.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final emailErr = validateEmail(_email.text);
    final code = _code.text.trim();
    setState(() {
      _emailError = emailErr;
      _codeError = code.length == 6 ? null : tr.authCodeIncomplete;
      _error = null;
      _info = null;
    });
    if (emailErr != null || code.length != 6) return;
    setState(() => _busy = true);
    try {
      await context.read<AuthController>().verifyRecoveryCode(_email.text, code);
      // The gate takes over (new-password screen).
    } on AuthFailure catch (e) {
      if (!mounted) return;
      setState(() {
        if (e.field == 'code') {
          _codeError = e.message;
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

  Future<void> _resend() async {
    final emailErr = validateEmail(_email.text);
    setState(() {
      _emailError = emailErr;
      _error = null;
      _info = null;
    });
    if (emailErr != null) return;
    setState(() => _resending = true);
    try {
      await context.read<AuthController>().sendPasswordReset(_email.text);
      if (mounted) setState(() => _info = tr.authRecoverSent);
    } on AuthFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wait = context.read<AuthController>().recoveryWaitSeconds;
    return AuthScaffold(
      showBack: true,
      title: tr.authCodeTitle,
      subtitle: tr.authCodeBody(
          widget.email.isEmpty ? tr.authYourAccount : widget.email),
      action: BusyButton(
          label: tr.authCodeVerify, busy: _busy, onPressed: _verify),
      children: [
        if (_info != null) FormMessage(_info!, error: false),
        if (_error != null) FormMessage(_error!),
        EmailField(controller: _email, error: _emailError),
        const SizedBox(height: AppSpace.md),
        TextField(
          controller: _code,
          autofocus: widget.email.isNotEmpty,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          autocorrect: false,
          maxLength: 6,
          autofillHints: const [AutofillHints.oneTimeCode],
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onSubmitted: (_) => _verify(),
          style: const TextStyle(letterSpacing: 6, fontSize: 22),
          decoration: InputDecoration(
            labelText: tr.authCodeLabel,
            prefixIcon: const Icon(Icons.pin_outlined),
            errorText: _codeError,
            counterText: '',
          ),
        ),
        const SizedBox(height: AppSpace.md),
        TextButton(
          onPressed: (wait > 0 || _resending) ? null : _resend,
          child: Text(wait > 0 ? tr.authResendIn(wait) : tr.authResend),
        ),
      ],
    );
  }
}

/// New password after the recovery code. Nothing else of the app opens
/// before it; leaving signs out.
class NewPasswordPage extends StatefulWidget {
  const NewPasswordPage({super.key});

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
      title: tr.authNewPasswordTitle,
      subtitle: tr.authNewPasswordFor(s.email ?? tr.authYourAccount),
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
        const SizedBox(height: AppSpace.lg),
        TextButton(
          onPressed: () => context.read<AuthController>().cancelRecovery(),
          child: Text(tr.authCancelAndLeave),
        ),
      ],
    );
  }
}
