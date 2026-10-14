import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/common.dart';
import '../../l10n/l10n.dart';

/// Layout of every auth screen: brand on top, a short title, the form, and
/// the main action pinned at the bottom (it stays visible with the keyboard
/// open).
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
    this.action,
    this.showBack = false,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Widget? action;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showBack ? AppBar() : null,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: AutofillGroup(
                child: ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(
                      AppSpace.gutter, AppSpace.xl, AppSpace.gutter, AppSpace.xl),
                  children: [
                    if (!showBack) ...[
                      const Center(child: BrandCap(size: 72)),
                      const SizedBox(height: AppSpace.md),
                      const Center(child: BrandWordmark(height: 28)),
                      const SizedBox(height: AppSpace.xl),
                    ],
                    Text(title, style: AppText.headline),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpace.sm),
                      Text(subtitle!, style: AppText.body),
                    ],
                    const SizedBox(height: AppSpace.lg),
                    ...children,
                  ],
                ),
              ),
            ),
            if (action != null) BottomActionBar(child: action!),
          ],
        ),
      ),
    );
  }
}

class EmailField extends StatelessWidget {
  const EmailField({
    super.key,
    required this.controller,
    this.error,
    this.autofocus = false,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String? error;
  final bool autofocus;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        autofocus: autofocus,
        keyboardType: TextInputType.emailAddress,
        autocorrect: false,
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.email, AutofillHints.username],
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          labelText: tr.authEmail,
          prefixIcon: const Icon(Icons.mail_outline_rounded),
          errorText: error,
        ),
      );
}

class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    this.label,
    this.error,
    this.helper,
    this.newPassword = false,
    this.done = false,
    this.onSubmitted,
  });

  final TextEditingController controller;
  /// Defaults to "Senha" in the language on screen.
  final String? label;
  final String? error;
  final String? helper;

  /// Hints password managers to suggest/save a new password.
  final bool newPassword;
  final bool done;
  final ValueChanged<String>? onSubmitted;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) => TextField(
        controller: widget.controller,
        obscureText: !_visible,
        autocorrect: false,
        enableSuggestions: false,
        textInputAction:
            widget.done ? TextInputAction.done : TextInputAction.next,
        autofillHints: [
          widget.newPassword ? AutofillHints.newPassword : AutofillHints.password,
        ],
        onSubmitted: widget.onSubmitted,
        decoration: InputDecoration(
          labelText: widget.label ?? tr.authPassword,
          prefixIcon: const Icon(Icons.lock_outline_rounded),
          helperText: widget.helper,
          helperMaxLines: 2,
          errorText: widget.error,
          errorMaxLines: 3,
          suffixIcon: IconButton(
            tooltip: _visible ? tr.authHidePassword : tr.authShowPassword,
            icon: Icon(_visible
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined),
            onPressed: () => setState(() => _visible = !_visible),
          ),
        ),
      );
}

/// Message box for errors and confirmations inside a form.
class FormMessage extends StatelessWidget {
  const FormMessage(this.text, {super.key, this.error = true});

  final String text;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final color = error ? AppColors.danger : AppColors.success;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpace.md),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(error ? Icons.error_outline_rounded : Icons.check_circle_outline,
                color: color, size: 20),
            const SizedBox(width: AppSpace.sm),
            Expanded(child: Text(text, style: AppText.body)),
          ],
        ),
      ),
    );
  }
}

/// Primary button with a spinner while [busy].
class BusyButton extends StatelessWidget {
  const BusyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.busy = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) => FilledButton(
        onPressed: busy ? null : onPressed,
        child: busy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2))
            : Text(label),
      );
}

/// Basic client-side checks; the server has the last word.
String? validateEmail(String v) {
  final t = v.trim();
  if (t.isEmpty) return tr.authEnterEmail;
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)) {
    return tr.authCheckEmail;
  }
  return null;
}

String? validateNewPassword(String v) {
  // Same rule as the fan-hub app: length only (8 characters).
  if (v.length < 8) return tr.authPasswordMin;
  return null;
}
