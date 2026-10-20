import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/data/local_store.dart';
import '../../core/di/injector.dart';
import '../../core/sync/sync_cubit.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../drinks/data/drink_repository.dart';
import '../../outing_drinks/data/outing_drink_repository.dart';
import '../../outing_drinks/domain/outing_drink.dart';
import '../../scan/data/photo_uploader.dart';
import '../../outings/data/outing_repository.dart';
import '../../share/data/share_service.dart';
import '../domain/export_builder.dart';
import '../domain/export_package.dart';
import '../../l10n/l10n.dart';

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
  bool _cancel = false;
  (int, int)? _progress;

  String _json() {
    final store = getIt<LocalStore>();
    List<Map<String, dynamic>> live(String c) => [
      for (final j in store.all(c))
        if (j['deleted_at'] == null) j,
    ];
    return ExportBuilder.json(
      exportedAt: DateTime.now(),
      places: live(LocalStore.places),
      outings: live(LocalStore.outings),
      drinkEntries: live(LocalStore.drinkEntries),
      customDrinks: live(LocalStore.customDrinks),
      outingDrinks: live(LocalStore.outingDrinks),
      outingPhotos: live(LocalStore.outingPhotos),
      outingTabs: live(LocalStore.outingTabs),
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
        origin: mounted ? ShareService.originOf(context) : null,
      );
      if (!ok) {
        // Copied only if the person asks; cancelling the sheet is not a
        // failure (see ShareService).
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(tr.exportShareUnavailable),
              duration: const Duration(seconds: 8),
              persist: false,
              action: SnackBarAction(
                label: tr.tabCopyText,
                onPressed: () => _copy(() => text),
              ),
            ),
          );
      }
    } catch (_) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(tr.exportFailed)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Optional full package: the plain files plus the photos, with a manifest
  /// of SHA-256 hashes. Whatever is left out is shown before sharing and
  /// listed in manifest.json.
  Future<void> _exportFull() async {
    if (_busy) return;
    final messenger = ScaffoldMessenger.of(context);
    final sync = context.read<SyncCubit>().state;
    final unsynced = !sync.allSaved || !sync.historyRestored;
    setState(() {
      _busy = true;
      _cancel = false;
      _progress = (0, 0);
    });
    try {
      final repo = getIt<OutingDrinkRepository>();
      final photos = [
        for (final j in getIt<LocalStore>().all(LocalStore.outingPhotos))
          if (j['deleted_at'] == null) OutingPhoto.fromJson(j),
      ];
      SupabaseClient? client;
      try {
        final c = Supabase.instance.client;
        if (c.auth.currentSession != null) client = c;
      } catch (_) {
        client = null; // cloud not started: only local files
      }
      final cloud = client;
      final package = await ExportPackageBuilder.build(
        exportedAt: DateTime.now(),
        textFiles: {
          'data/bebometro-dados.json': _json(),
          'data/bebometro-roles.csv': _outingsCsv(),
          'data/bebometro-bebidas.csv': _drinksCsv(),
        },
        photos: [
          for (final p in photos)
            ExportPhotoRef(
              id: p.id,
              outingId: p.outingId,
              storagePath: p.storagePath,
            ),
        ],
        readLocal: (p) => repo.files.read(p.id),
        // Cloud-only photo (another device, reinstall): the person's own
        // object in the private bucket, read with their own session.
        download: cloud == null
            ? null
            : (p) => cloud.storage
                  .from(PhotoUploader.bucket)
                  .download(p.storagePath!),
        isCancelled: () => _cancel,
        onProgress: (done, total) {
          if (mounted) setState(() => _progress = (done, total));
        },
        note: unsynced ? 'not_fully_synced' : null,
      );
      if (!mounted) return;
      if (!package.verified) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(tr.exportFullIntegrityFailed)));
        return;
      }
      if (package.omitted.isNotEmpty) {
        final go = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(tr.exportFullOmittedTitle),
            content: Text(tr.exportFullOmittedBody(package.omitted.length)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(tr.exportFullCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(tr.exportFullShareAnyway),
              ),
            ],
          ),
        );
        if (go != true) {
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(tr.exportFullCancelled)));
          return;
        }
      }
      if (!mounted) return;
      final ok = await ShareService.shareFile(
        bytes: package.zip,
        name: 'bebometro-pacote.zip',
        mimeType: 'application/zip',
        origin: ShareService.originOf(context),
      );
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              ok
                  ? tr.exportFullDone(package.photosIncluded)
                  : tr.exportShareUnavailable,
            ),
          ),
        );
    } on ExportCancelled {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(tr.exportFullCancelled)));
    } catch (_) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(tr.exportFailed)));
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _progress = null;
        });
      }
    }
  }

  Widget _fullTile() {
    final sync = context.watch<SyncCubit>().state;
    final unsynced = !sync.allSaved || !sync.historyRestored;
    final progress = _progress;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.folder_zip_outlined),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Text(tr.exportFullTitle, style: AppText.subtitle),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.xs),
          Text(tr.exportFullBody, style: AppText.caption),
          const SizedBox(height: AppSpace.xs),
          Text(tr.exportFullNote, style: AppText.caption),
          if (unsynced) ...[
            const SizedBox(height: AppSpace.sm),
            InfoPill(
              tr.exportFullUnsynced,
              icon: Icons.sync_problem_rounded,
              warning: true,
            ),
          ],
          const SizedBox(height: AppSpace.md),
          if (progress != null) ...[
            LinearProgressIndicator(
              value: progress.$2 == 0 ? null : progress.$1 / progress.$2,
            ),
            const SizedBox(height: AppSpace.xs),
            Row(
              children: [
                Expanded(
                  child: Text(
                    tr.exportFullBuilding(progress.$1, progress.$2),
                    style: AppText.caption,
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _cancel = true),
                  child: Text(tr.exportFullCancel),
                ),
              ],
            ),
          ] else
            FilledButton.icon(
              style: FilledButton.styleFrom(minimumSize: const Size(0, 52)),
              onPressed: _busy ? null : _exportFull,
              icon: const Icon(Icons.ios_share_rounded),
              label: Text(tr.exportFullButton),
            ),
        ],
      ),
    );
  }

  Future<void> _copy(String Function() build) async {
    await Clipboard.setData(ClipboardData(text: build()));
    if (mounted) showToast(context, tr.exportCopied);
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
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: AppSpace.md),
                Expanded(child: Text(title, style: AppText.subtitle)),
              ],
            ),
            const SizedBox(height: AppSpace.xs),
            Text(subtitle, style: AppText.caption),
            const SizedBox(height: AppSpace.md),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _busy
                        ? null
                        : () =>
                              _export(name: fileName, mime: mime, build: build),
                    icon: const Icon(Icons.ios_share_rounded),
                    label: Text(tr.exportButton),
                  ),
                ),
                const SizedBox(width: AppSpace.sm),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 52),
                  ),
                  onPressed: () => _copy(build),
                  child: Text(tr.exportCopy),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr.exportTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpace.gutter,
          0,
          AppSpace.gutter,
          AppSpace.xxl,
        ),
        children: [
          Text(tr.exportIntro, style: AppText.caption),
          const SizedBox(height: AppSpace.lg),
          _tile(
            icon: Icons.data_object_rounded,
            title: tr.exportJsonTitle,
            subtitle: tr.exportJsonBody,
            fileName: 'bebometro-dados.json',
            mime: 'application/json',
            build: _json,
          ),
          _tile(
            icon: Icons.table_chart_outlined,
            title: tr.exportOutingsCsvTitle,
            subtitle: tr.exportOutingsCsvBody,
            fileName: 'bebometro-roles.csv',
            mime: 'text/csv',
            build: _outingsCsv,
          ),
          _tile(
            icon: Icons.local_bar_outlined,
            title: tr.exportDrinksCsvTitle,
            subtitle: tr.exportDrinksCsvBody,
            fileName: 'bebometro-bebidas.csv',
            mime: 'text/csv',
            build: _drinksCsv,
          ),
          const SizedBox(height: AppSpace.sm),
          _fullTile(),
        ],
      ),
    );
  }
}
