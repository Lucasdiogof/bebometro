import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../outings/domain/outing.dart';
import '../../share/data/share_service.dart';
import '../domain/tab_calc.dart';
import '../domain/tab_models.dart';
import '../domain/tab_share.dart';

/// Preview of the split as text. Sharing only happens after a tap on
/// "Compartilhar"; nothing is ever sent to contacts by the app. The text has
/// no address, photos, personal notes or drinking report.
class TabSharePage extends StatefulWidget {
  const TabSharePage({
    super.key,
    required this.outing,
    required this.doc,
    required this.result,
  });

  final Outing outing;
  final TabDoc doc;
  final TabResult result;

  @override
  State<TabSharePage> createState() => _TabSharePageState();
}

class _TabSharePageState extends State<TabSharePage> {
  bool _payments = false;

  String get _text => TabShareText.build(
        outing: widget.outing,
        doc: widget.doc,
        result: widget.result,
        includePayments: _payments,
      );

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _text));
    if (mounted) showToast(context, 'Texto copiado');
  }

  Future<void> _share() async {
    final ok = await ShareService.shareText(_text, subject: 'Divisão da conta');
    if (!ok && mounted) {
      showToast(context, 'Não foi possível abrir o compartilhamento. Copie o texto.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compartilhar divisão')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpace.gutter, 0, AppSpace.gutter, AppSpace.xxl),
        children: [
          const Text(
            'Prévia do texto. Nada é enviado até você tocar em Compartilhar.',
            style: AppText.caption,
          ),
          const SizedBox(height: AppSpace.md),
          SurfaceCard(child: SelectableText(_text, style: AppText.body)),
          if (widget.doc.participants.isNotEmpty)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Incluir pagamentos e saldos'),
              subtitle: const Text('Desligado por padrão.'),
              value: _payments,
              onChanged: (v) => setState(() => _payments = v),
            ),
          const SizedBox(height: AppSpace.sm),
          const Text(
            'Não inclui endereço, fotos, anotações pessoais nem relato de '
            'embriaguez.',
            style: AppText.caption,
          ),
          const SizedBox(height: AppSpace.lg),
          FilledButton.icon(
            onPressed: _share,
            icon: const Icon(Icons.ios_share_rounded),
            label: const Text('Compartilhar'),
          ),
          const SizedBox(height: AppSpace.sm),
          OutlinedButton.icon(
            onPressed: _copy,
            icon: const Icon(Icons.copy_rounded),
            label: const Text('Copiar texto'),
          ),
        ],
      ),
    );
  }
}
