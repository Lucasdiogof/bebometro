import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injector.dart';
import '../../core/sync/sync_cubit.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import 'settings_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SettingsCubit>(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatefulWidget {
  const _SettingsView();

  @override
  State<_SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<_SettingsView> {
  bool _running = false;

  Future<void> _syncNow() async {
    final sync = context.read<SyncCubit>();
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _running = true);
    await sync.syncNow();
    if (!mounted) return;
    setState(() => _running = false);
    final s = sync.state;
    final text = switch (s.status) {
      SyncStatus.synced => 'Tudo sincronizado.',
      SyncStatus.pending => 'Ainda há ${s.pending} alteração(ões) para enviar.',
      SyncStatus.syncing => 'Sincronizando…',
      SyncStatus.failed ||
      SyncStatus.localOnly =>
        s.message ?? 'Não foi possível sincronizar agora.',
    };
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: SafeArea(
        child: BlocBuilder<SyncCubit, SyncState>(
          builder: (context, sync) {
            final onlyHere = sync.status == SyncStatus.localOnly ||
                sync.status == SyncStatus.failed ||
                sync.status == SyncStatus.pending;
            final busy = _running || sync.status == SyncStatus.syncing;
            return ListView(
              padding: const EdgeInsets.fromLTRB(
                  AppSpace.gutter, 0, AppSpace.gutter, AppSpace.xxl),
              children: [
                const SectionTitle('ARMAZENAMENTO'),
                BlocBuilder<SettingsCubit, SettingsState>(
                  builder: (context, s) => SurfaceCard(
                    child: Row(children: [
                      Expanded(
                        child: StatTile(
                          label: 'Rolês neste aparelho',
                          value: '${s.outings}',
                          icon: Icons.nightlife_rounded,
                        ),
                      ),
                      Expanded(
                        child: StatTile(
                          label: 'Registros de bebida',
                          value: '${s.drinks}',
                          icon: Icons.local_bar_rounded,
                        ),
                      ),
                    ]),
                  ),
                ),
                const SectionTitle('SINCRONIZAÇÃO'),
                SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StatTile(
                        label: 'Estado',
                        value: sync.label,
                        icon: Icons.cloud_sync_rounded,
                      ),
                      const SizedBox(height: AppSpace.md),
                      Text(
                        sync.lastSyncAt == null
                            ? 'Última sincronização: ainda não houve.'
                            : 'Última sincronização: '
                                '${formatDateTime(sync.lastSyncAt!)}',
                        style: AppText.caption,
                      ),
                      if (sync.pending > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpace.xs),
                          child: Text(
                            '${sync.pending} alteração(ões) aguardando envio.',
                            style: AppText.caption,
                          ),
                        ),
                      const SizedBox(height: AppSpace.lg),
                      FilledButton.icon(
                        onPressed: busy ? null : _syncNow,
                        icon: busy
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.sync_rounded),
                        label: Text(
                            busy ? 'Sincronizando…' : 'Sincronizar agora'),
                      ),
                    ],
                  ),
                ),
                if (onlyHere) ...[
                  const SizedBox(height: AppSpace.md),
                  SurfaceCard(
                    highlight: true,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            color: AppColors.amber),
                        const SizedBox(width: AppSpace.md),
                        Expanded(
                          child: Text(
                            '${sync.message ?? 'Alguns dados ainda não chegaram à nuvem.'}\n\n'
                            'Enquanto isso, se você desinstalar o app ou '
                            'limpar os dados do navegador, o que está só '
                            'neste aparelho será perdido.',
                            style: AppText.body,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
