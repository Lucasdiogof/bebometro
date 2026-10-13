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
        _say('Compartilhar não está disponível aqui. O conteúdo foi copiado: '
            'cole em um arquivo para guardar.');
      }
    } catch (_) {
      _say('Não foi possível gerar o arquivo.', error: true);
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
      _say('Importação concluída: $n registros copiados para a sua conta. A '
          'cópia antiga continua guardada neste aparelho.');
    } on LegacyImportBlocked {
      if (!mounted) return;
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Dois rolês em andamento'),
          content: const Text(
              'Sua conta já tem um rolê em andamento e os registros antigos '
              'também. Para importar, o rolê antigo entra como encerrado agora. '
              'As bebidas dele continuam nele, sem se misturar.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar')),
            FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Importar como encerrado')),
          ],
        ),
      );
      if (ok == true) {
        await _import(endActiveAt: DateTime.now());
        return;
      }
    } catch (_) {
      _say('A importação não terminou. Nada foi apagado; tente de novo.',
          error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _keep() async {
    await _legacy.keepSeparate();
    await _load();
    _say('Os registros antigos continuam separados neste aparelho. Você pode '
        'importar quando quiser, por "Minha conta".',
        error: false);
  }

  @override
  Widget build(BuildContext context) {
    final info = _info;
    final signedIn = AccountScope.isOpen;
    return Scaffold(
      appBar: AppBar(title: const Text('Registros antigos')),
      body: info == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                  AppSpace.gutter, 0, AppSpace.gutter, AppSpace.xxl),
              children: [
                if (_message != null) FormMessage(_message!, error: _error),
                if (!info.hasData)
                  const Text('Não há registros antigos neste aparelho.',
                      style: AppText.body)
                else ...[
                  SurfaceCard(
                    highlight: true,
                    child: Row(children: [
                      Expanded(
                          child: StatTile(
                              label: 'Rolês', value: '${info.outings}')),
                      Expanded(
                          child: StatTile(
                              label: 'Bebidas', value: '${info.entries}')),
                      Expanded(
                          child: StatTile(
                              label: 'Nunca enviados',
                              value: '${info.pendingUploads}')),
                    ]),
                  ),
                  const SizedBox(height: AppSpace.md),
                  Text(
                    switch (info.status) {
                      LegacyStatus.adopted =>
                        'Estes registros já são da sua conta (criada a partir '
                            'deles).',
                      LegacyStatus.imported =>
                        'Estes registros já foram importados para uma conta. A '
                            'cópia antiga fica guardada aqui por segurança.',
                      LegacyStatus.kept =>
                        'Você escolheu manter estes registros separados.',
                      _ =>
                        'Registros feitos antes de o Bebômetro usar contas. '
                            'Eles não foram apagados.',
                    },
                    style: AppText.body,
                  ),
                  const SizedBox(height: AppSpace.sm),
                  const Text(
                    'Importar copia os registros para a conta atual com novos '
                    'identificadores (as fotos são reenviadas). Uma conta '
                    'anônima antiga não pode ser recuperada sem a sessão dela: '
                    'o que importa é o que está neste aparelho.',
                    style: AppText.caption,
                  ),
                  const SizedBox(height: AppSpace.lg),
                  if (signedIn &&
                      info.status != LegacyStatus.imported &&
                      info.status != LegacyStatus.adopted)
                    BusyButton(
                      label: 'Importar para minha conta',
                      busy: _busy,
                      onPressed: () => _import(),
                    ),
                  if (signedIn && info.status == LegacyStatus.pending)
                    TextButton(
                      onPressed: _busy ? null : _keep,
                      child: const Text('Manter separados por enquanto'),
                    ),
                  const SizedBox(height: AppSpace.sm),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _export,
                    icon: const Icon(Icons.download_outlined),
                    label: const Text('Exportar registros antigos (JSON)'),
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
      child: const Row(children: [
        Icon(Icons.inventory_2_outlined, color: AppColors.amber),
        SizedBox(width: AppSpace.md),
        Expanded(
          child: Text(
            'Há registros antigos neste aparelho. Eles estão guardados: depois '
            'de entrar, você pode importá-los. Toque para ver ou exportar.',
            style: AppText.caption,
          ),
        ),
      ]),
    );
  }
}
