import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';
import '../utils/formatters.dart';

/// Money input in Brazilian reais, with the app's single parser: the
/// accepted format is shown as help, and an invalid or ambiguous text
/// ("1.500") is flagged in the field instead of being guessed.
class MoneyField extends StatefulWidget {
  const MoneyField({
    super.key,
    required this.label,
    required this.onChanged,
    this.controller,
    this.enabled = true,
    this.helper,
    this.autofocus = false,
    this.errorText,
  });

  final String label;

  /// Cents, or null when empty/invalid.
  final ValueChanged<int?> onChanged;
  final TextEditingController? controller;
  final bool enabled;

  /// Extra help; the format hint is always shown when there is no error.
  final String? helper;
  final bool autofocus;

  /// Error from the caller (for example "required"); the format error of
  /// the text itself takes precedence.
  final String? errorText;

  @override
  State<MoneyField> createState() => _MoneyFieldState();
}

class _MoneyFieldState extends State<MoneyField> {
  String? _error;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: widget.label,
        prefixText: r'R$ ',
        helperText: widget.helper ?? tr.moneyFieldHelper,
        helperMaxLines: 3,
        errorText: _error ?? widget.errorText,
        errorMaxLines: 3,
      ),
      onChanged: (v) {
        setState(() => _error = numberInputError(v));
        widget.onChanged(v.trim().isEmpty ? null : parseCents(v));
      },
    );
  }
}
