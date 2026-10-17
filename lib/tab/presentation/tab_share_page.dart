import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../outings/domain/outing.dart';
import '../../share/data/share_service.dart';
import '../domain/tab_calc.dart';
import '../domain/tab_models.dart';
import '../domain/tab_share.dart';
import '../../l10n/l10n.dart';

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
    if (mounted) showToast(context, tr.tabTextCopied);
  }

  Future<void> _share() async {
    final ok = await ShareService.shareText(
      _text,
      subject: tr.tabShareSubject,
      origin: ShareService.originOf(context),
    );
    if (!ok && mounted) {
      showToast(context, tr.tabShareFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr.tabShareSplitTooltip)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.gutter,
          0,
          AppSpace.gutter,
          AppSpace.xxl,
        ),
        children: [
          Text(tr.tabSharePreview, style: AppText.caption),
          const SizedBox(height: AppSpace.md),
          SurfaceCard(child: SelectableText(_text, style: AppText.body)),
          if (widget.doc.participants.isNotEmpty)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(tr.tabShareIncludePayments),
              subtitle: Text(tr.tabShareOffDefault),
              value: _payments,
              onChanged: (v) => setState(() => _payments = v),
            ),
          const SizedBox(height: AppSpace.sm),
          Text(tr.tabShareExcludes, style: AppText.caption),
          const SizedBox(height: AppSpace.lg),
          FilledButton.icon(
            onPressed: _share,
            icon: const Icon(Icons.ios_share_rounded),
            label: Text(tr.tabShareButton),
          ),
          const SizedBox(height: AppSpace.sm),
          OutlinedButton.icon(
            onPressed: _copy,
            icon: const Icon(Icons.copy_rounded),
            label: Text(tr.tabCopyText),
          ),
        ],
      ),
    );
  }
}
