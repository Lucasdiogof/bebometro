import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/data/local_store.dart';
import '../../core/di/injector.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../drinks/data/drink_repository.dart';
import '../../outings/data/outing_repository.dart';
import '../../share/data/share_service.dart';
import '../domain/export_builder.dart';

/// Export of the person's own records (JSON with every detail, CSV for
/// spreadsheets). Nothing leaves the device unless they share or copy it, and
/// no token, credential or session identifier is ever included.
class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  bool _busy = false;

  String _json() {
    final store = getIt<LocalStore>();
    List<Map<String, dynamic>> live(String c) => [
          for (final j in store.all(c))
            if (j['deleted_at'] == null) j,
        ];
    return ExportBuilder.json(
      exportedAt: DateTime.now(),
      places: store.all(LocalStore.places),
      outings: store.all(LocalStore.outings),
      drinkEntries: live(LocalStore.drinkEntries),
      customDrinks: live(LocalStore.customDrinks),
      outingDrinks: live(LocalStore.outingDrinks),
      outingPhotos: live(LocalStore.outingPhotos),
    );
  }

  String _outingsCsv() {
    final drinks = getIt<DrinkRepository>();
    return ExportBuilder.outingsCsv(
      getIt<OutingRepository>().all(),
      drinks.entriesFor,
    );
  }

  String _drinksCsv() =>
      ExportBuilder.drinksCsv(getIt<DrinkRepository>().allEntries());

  Future<void> _export({
    required String name,
    required String mime,
    required String Function() build,
  }) async {
    if (_busy) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final text = build();
      final bytes = Uint8List.fromList(utf8.encode(text));
      final ok = await ShareService.shareFile(
        bytes: bytes,
        name: name,
        mimeType: mime,
      );
      if (!ok) {
        await Clipboard.setData(ClipboardData(text: text));
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(
            content: Text('Compartilhar não está disponível aqui. O conteúdo '
                'foi copiado: cole em um arquivo para guardar.'),
          ));
      }
    } catch (_) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
            const SnackBar(content: Text('Não foi possível gerar o arquivo.')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _copy(String Function() build) async {
    await Clipboard.setData(ClipboardData(text: build()));
    if (mounted) showToast(context, 'Copiado');
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String fileName,
    required String mime,
    required String Function() build,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.md),
      child: SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon),
              const SizedBox(width: AppSpace.md),
              Expanded(child: Text(title, style: AppText.subtitle)),
            ]),
            const SizedBox(height: AppSpace.xs),
            Text(subtitle, style: AppText.caption),
            const SizedBox(height: AppSpace.md),
            Row(children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _busy
                      ? null
                      : () => _export(name: fileName, mime: mime, build: build),
                  icon: const Icon(Icons.ios_share_rounded),
                  label: const Text('Exportar'),
                ),
              ),
              const SizedBox(width: AppSpace.sm),
              OutlinedButton(
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52)),
                onPressed: () => _copy(build),
                child: const Text('Copiar'),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exportar meus dados')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpace.gutter, 0, AppSpace.gutter, AppSpace.xxl),
        children: [
          const Text(
            'Seus registros, do jeito que estão no aparelho. Nada é enviado '
            'a ninguém: você escolhe onde guardar. Nenhum dado de acesso ou '
            'sessão entra nos arquivos.',
            style: AppText.caption,
          ),
          const SizedBox(height: AppSpace.lg),
          _tile(
            icon: Icons.data_object_rounded,
            title: 'Tudo em JSON',
            subtitle: 'Locais, rolês, bebidas, composições e suas bebidas '
                'próprias, com todos os detalhes.',
            fileName: 'bebometro-dados.json',
            mime: 'application/json',
            build: _json,
          ),
          _tile(
            icon: Icons.table_chart_outlined,
            title: 'Rolês em CSV',
            subtitle: 'Um resumo por rolê (separador ";", acentos em UTF-8).',
            fileName: 'bebometro-roles.csv',
            mime: 'text/csv',
            build: _outingsCsv,
          ),
          _tile(
            icon: Icons.local_bar_outlined,
            title: 'Bebidas em CSV',
            subtitle: 'Uma linha por registro. Campo vazio = desconhecido, '
                'nunca zero.',
            fileName: 'bebometro-bebidas.csv',
            mime: 'text/csv',
            build: _drinksCsv,
          ),
        ],
      ),
    );
  }
}
