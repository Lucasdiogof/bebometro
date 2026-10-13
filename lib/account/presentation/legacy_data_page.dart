import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/data/local_store.dart';
import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../scan/data/photo_files.dart';
import '../../share/data/share_service.dart';
import '../data/legacy_data.dart';
import 'auth_widgets.dart';
import '../../l10n/l10n.dart';

/// The records kept from before accounts became mandatory: what there is,
/// and the explicit choices. Reachable without an account (to export), and
/// from "Minha conta" when signed in (to import).
class LegacyDataPage extends StatefulWidget {
  const LegacyDataPage({super.key});

  @override
  State<LegacyDataPage> createState() => _LegacyDataPageState();
}

class _LegacyDataPageState extends State<LegacyDataPage> {
  final _legacy = getIt<LegacyData>();
  LegacyInfo? _info;
  bool _busy = false;
  String? _message;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final info = await _legacy.info();
    if (mounted) setState(() => _info = info);
  }

  void _say(String text, {bool error = false}) =>
      setState(() {
        _message = text;
        _error = error;
      });

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      final text = await _legacy.exportJson();
      final ok = await ShareService.shareFile(
        bytes: Uint8List.fromList(utf8.encode(text)),
        name: 'bebometro-registros-antigos.json',
        mimeType: 'application/json',
      );
      if (!ok) {
        await Clipboard.setData(ClipboardData(text: text));
        _say(tr.shareUnavailableCopied);
      }
    } catch (_) {
      _say(tr.fileGenerationFailed, error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import({DateTime? endActiveAt}) async {
    setState(() => _busy = true);
    try {
      final n = await _legacy.importInto(
        getIt<LocalStore>(),
        AccountScope.userId!,
        getIt<PhotoFiles>(),
        importActiveAsEndedAt: endActiveAt,
      );
      await _load();
      _say(tr.legacyImported(n));
    } on LegacyImportBlocked {
      if (!mounted) return;
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(tr.legacyTwoActiveTitle),
          content: Text(tr.legacyTwoActiveBody),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(tr.commonCancel)),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(tr.legacyImportAsEnded)),
          ],
        ),
      );
      if (ok == true) {
        await _import(endActiveAt: DateTime.now());
        return;
      }
    } catch (_) {
      _say(tr.legacyImportFailed,
          error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _keep() async {
    await _legacy.keepSeparate();
    await _load();
    _say(tr.legacyKept,
        error: false);
  }

  @override
  Widget build(BuildContext context) {
    final info = _info;
    final signedIn = AccountScope.isOpen;
    return Scaffold(
      appBar: AppBar(title: Text(tr.legacyTitle)),
      body: info == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                  AppSpace.gutter, 0, AppSpace.gutter, AppSpace.xxl),
              children: [
                if (_message != null) FormMessage(_message!, error: _error),
                if (!info.hasData)
                  Text(tr.legacyNone,
                      style: AppText.body)
                else ...[
                  SurfaceCard(
                    highlight: true,
                    child: Row(children: [
                      Expanded(
                          child: StatTile(
                              label: tr.legacyOutings, value: '${info.outings}')),
                      Expanded(
                          child: StatTile(
                              label: tr.legacyDrinks, value: '${info.entries}')),
                      Expanded(
                          child: StatTile(
                              label: tr.legacyNeverSent,
                              value: '${info.pendingUploads}')),
                    ]),
                  ),
                  const SizedBox(height: AppSpace.md),
                  Text(
                    switch (info.status) {
                      LegacyStatus.adopted =>
                        tr.legacyStatusAdopted,
                      LegacyStatus.imported =>
                        tr.legacyStatusImported,
                      LegacyStatus.kept =>
                        tr.legacyStatusKept,
                      _ =>
                        tr.legacyStatusPending,
                    },
                    style: AppText.body,
                  ),
                  const SizedBox(height: AppSpace.sm),
                  Text(tr.legacyImportExplain, style: AppText.caption),
                  const SizedBox(height: AppSpace.lg),
                  if (signedIn &&
                      info.status != LegacyStatus.imported &&
                      info.status != LegacyStatus.adopted)
                    BusyButton(
                      label: tr.legacyImport,
                      busy: _busy,
                      onPressed: () => _import(),
                    ),
                  if (signedIn && info.status == LegacyStatus.pending)
                    TextButton(
                      onPressed: _busy ? null : _keep,
                      child: Text(tr.legacyKeep),
                    ),
                  const SizedBox(height: AppSpace.sm),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _export,
                    icon: const Icon(Icons.download_outlined),
                    label: Text(tr.legacyExport),
                  ),
                ],
              ],
            ),
    );
  }
}

/// Small notice on the sign-in screen when old records exist.
class LegacyNoticeCard extends StatefulWidget {
  const LegacyNoticeCard({super.key});

  @override
  State<LegacyNoticeCard> createState() => _LegacyNoticeCardState();
}

class _LegacyNoticeCardState extends State<LegacyNoticeCard> {
  LegacyInfo? _info;

  @override
  void initState() {
    super.initState();
    getIt<LegacyData>().info().then((i) {
      if (mounted) setState(() => _info = i);
    });
  }

  @override
  Widget build(BuildContext context) {
    final info = _info;
    if (info == null || !info.needsDecision) return const SizedBox.shrink();
    return SurfaceCard(
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const LegacyDataPage())),
      child: Row(children: [
        Icon(Icons.inventory_2_outlined, color: AppColors.amber),
        SizedBox(width: AppSpace.md),
        Expanded(
          child: Text(tr.legacyNotice, style: AppText.caption),
        ),
      ]),
    );
  }
}
