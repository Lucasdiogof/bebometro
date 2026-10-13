import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../account/application/auth_controller.dart';
import '../../account/presentation/account_page.dart';
import '../../core/data/app_prefs.dart';
import '../../core/di/injector.dart';
import '../../core/sync/sync_cubit.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../drinks/presentation/my_drinks_page.dart';
import '../../export/presentation/export_page.dart';
import '../../places/presentation/places_page.dart';
import '../../table/data/table_prefs_cubit.dart';
import '../../tracking/presentation/tracking_settings_section.dart';
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
      SyncStatus.synced => s.conflicts > 0
          ? 'Enviado, mas há ${s.conflicts} alteração(ões) para resolver em Minha conta.'
          : 'Tudo sincronizado.',
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
                const SectionTitle('Minha conta'),
                SurfaceCard(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AccountPage()),
                  ),
                  child: Row(children: [
                    const Icon(Icons.account_circle_outlined,
                        color: AppColors.amber),
                    const SizedBox(width: AppSpace.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.watch<AuthController>().state.displayName ??
                                'Minha conta',
                            style: AppText.subtitle,
                          ),
                          Text(
                            context.watch<AuthController>().state.email ?? '',
                            style: AppText.caption,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.textMuted),
                  ]),
                ),
                const SectionTitle('Rolê na tela bloqueada'),
                const TrackingSettingsSection(),
                const SectionTitle('Mesa do rolê'),
                BlocBuilder<TablePrefsCubit, TablePrefs>(
                  builder: (context, prefs) {
                    final cubit = context.read<TablePrefsCubit>();
                    return SurfaceCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpace.sm, vertical: AppSpace.xs),
                      child: Column(children: [
                        SwitchListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: AppSpace.sm),
                          title: const Text('Mostrar mesa como padrão'),
                          subtitle: const Text(
                              'Na tela do rolê, a mesa ilustrada abre antes da lista.'),
                          value: prefs.view == TableView.table,
                          activeThumbColor: AppColors.amber,
                          onChanged: (v) => cubit
                              .setView(v ? TableView.table : TableView.list),
                        ),
                        SwitchListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: AppSpace.sm),
                          title: const Text('Animações da mesa'),
                          subtitle: const Text(
                              'Os recipientes esvaziam como ilustração. Desligado, a mesa fica estática.'),
                          value: prefs.animations,
                          activeThumbColor: AppColors.amber,
                          onChanged: cubit.setAnimations,
                        ),
                      ]),
                    );
                  },
                ),
                const SectionTitle('Orçamento'),
                const _BudgetAlertsTile(),
                const SectionTitle('Minhas bebidas'),
                SurfaceCard(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MyDrinksPage()),
                  ),
                  child: const Row(children: [
                    Icon(Icons.bookmark_border_rounded, color: AppColors.amber),
                    SizedBox(width: AppSpace.md),
                    Expanded(
                      child: Text('Minhas bebidas e receitas',
                          style: AppText.subtitle),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        color: AppColors.textMuted),
                  ]),
                ),
                const SizedBox(height: AppSpace.sm),
                SurfaceCard(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PlacesPage()),
                  ),
                  child: const Row(children: [
                    Icon(Icons.place_outlined, color: AppColors.amber),
                    SizedBox(width: AppSpace.md),
                    Expanded(
                      child: Text('Locais salvos', style: AppText.subtitle),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        color: AppColors.textMuted),
                  ]),
                ),
                const SizedBox(height: AppSpace.sm),
                SurfaceCard(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ExportPage()),
                  ),
                  child: const Row(children: [
                    Icon(Icons.download_outlined, color: AppColors.amber),
                    SizedBox(width: AppSpace.md),
                    Expanded(
                      child: Text('Exportar meus dados', style: AppText.subtitle),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        color: AppColors.textMuted),
                  ]),
                ),
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


/// Turns the budget warnings (80% and 100% of the informed spending) on or off.
class _BudgetAlertsTile extends StatefulWidget {
  const _BudgetAlertsTile();

  @override
  State<_BudgetAlertsTile> createState() => _BudgetAlertsTileState();
}

class _BudgetAlertsTileState extends State<_BudgetAlertsTile> {
  final _prefs = getIt<AppPrefs>();

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.sm, vertical: AppSpace.xs),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpace.sm),
        title: const Text('Avisos de orçamento'),
        subtitle: const Text(
            'Um aviso ao chegar a 80% e a 100% do orçamento do rolê, uma vez '
            'por patamar.'),
        value: _prefs.budgetAlerts,
        activeThumbColor: AppColors.amber,
        onChanged: (v) async {
          await _prefs.setBudgetAlerts(v);
          if (mounted) setState(() {});
        },
      ),
    );
  }
}
