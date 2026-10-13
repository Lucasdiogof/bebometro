import 'package:flutter/material.dart';

import '../../core/data/local_store.dart';
import '../../core/di/injector.dart';
import '../../core/sync/sync_conflicts.dart';
import '../../core/sync/sync_cubit.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../outings/data/outing_repository.dart';

/// "Alterações para resolver": changes that could not be sent as they are.
/// Each one keeps both versions until the person chooses; nothing is merged
/// or dropped silently (a tab is never summed with another, payments are
/// shown on both sides).
class ConflictsPage extends StatefulWidget {
  const ConflictsPage({super.key});

  @override
  State<ConflictsPage> createState() => _ConflictsPageState();
}

class _ConflictsPageState extends State<ConflictsPage> {
  final _conflicts = getIt<SyncConflicts>();
  bool _busy = false;

  Future<void> _run(Future<void> Function() action, String done) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
      getIt<SyncCubit>().schedule(immediate: true);
      if (mounted) showToast(context, done);
    } catch (_) {
      if (mounted) showToast(context, 'Não foi possível aplicar. Nada foi perdido.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Ends [endId] now and puts the outing that stays running back in the
  /// queue. Their drinks never move between them.
  Future<void> _endOne(SyncConflict c, String endId) async {
    final outings = getIt<OutingRepository>();
    final store = getIt<LocalStore>();
    await outings.finish(endId, DateTime.now());
    final keep = endId == c.id ? c.otherId : c.id;
    if (keep != null) {
      final row = store.get(LocalStore.outings, keep);
      if (row != null) await store.put(LocalStore.outings, row);
    }
    await _conflicts.remove(c);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alterações para resolver')),
      body: StreamBuilder<void>(
        stream: _conflicts.changes,
        builder: (context, _) {
          final items = _conflicts.all;
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpace.xl),
                child: Text('Nada para resolver. Tudo certo.',
                    style: AppText.body, textAlign: TextAlign.center),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(
                AppSpace.gutter, AppSpace.sm, AppSpace.gutter, AppSpace.xxl),
            children: [
              const Text(
                'Estas alterações foram feitas em mais de um aparelho ao mesmo '
                'tempo. Escolha qual versão vale. A outra é descartada só '
                'quando você escolher.',
                style: AppText.caption,
              ),
              const SizedBox(height: AppSpace.md),
              for (final c in items)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpace.md),
                  child: c.kind == ConflictKind.activeOuting
                      ? _activeCard(c)
                      : _rowCard(c),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _activeCard(SyncConflict c) {
    final store = getIt<LocalStore>();
    final local = store.get(LocalStore.outings, c.id) ?? c.local;
    final other =
        c.otherId == null ? null : store.get(LocalStore.outings, c.otherId!);
    return SurfaceCard(
      highlight: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Dois rolês em andamento', style: AppText.title),
          const SizedBox(height: AppSpace.xs),
          const Text(
            'Um foi começado neste aparelho e outro em outro aparelho, sem '
            'internet. Os dois foram guardados com as suas bebidas. Escolha '
            'qual encerrar agora.',
            style: AppText.caption,
          ),
          const SizedBox(height: AppSpace.md),
          _outingLine('Deste aparelho', local),
          if (other != null) _outingLine('Do outro aparelho', other),
          const SizedBox(height: AppSpace.sm),
          Wrap(spacing: AppSpace.sm, runSpacing: AppSpace.sm, children: [
            OutlinedButton(
              onPressed: _busy
                  ? null
                  : () => _run(() => _endOne(c, c.id), 'Rolê encerrado'),
              child: const Text('Encerrar o deste aparelho'),
            ),
            if (other != null)
              OutlinedButton(
                onPressed: _busy
                    ? null
                    : () => _run(() => _endOne(c, c.otherId!), 'Rolê encerrado'),
                child: const Text('Encerrar o do outro aparelho'),
              ),
          ]),
        ],
      ),
    );
  }

  Widget _outingLine(String label, Map<String, dynamic> o) {
    final started = DateTime.tryParse(o['started_at'] as String? ?? '');
    final drinks = getIt<LocalStore>()
        .all(LocalStore.drinkEntries)
        .where((e) => e['outing_id'] == o['id'] && e['deleted_at'] == null)
        .length;
    final name = (o['nickname'] as String?) ??
        (o['place_name'] as String?) ??
        (o['address'] as String?) ??
        'Rolê';
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.xs),
      child: Text(
        '$label: $name'
        '${started != null ? ' · desde ${formatDateTime(started.toLocal())}' : ''}'
        ' · $drinks ${drinks == 1 ? 'bebida' : 'bebidas'}',
        style: AppText.body,
      ),
    );
  }

  Widget _rowCard(SyncConflict c) {
    final remote = c.remote;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_title(c), style: AppText.title),
          const SizedBox(height: AppSpace.sm),
          _version('Neste aparelho', c.collection, c.local),
          const SizedBox(height: AppSpace.sm),
          if (remote == null)
            const Text(
              'Não deu para ler a versão da nuvem agora. Você pode manter a '
              'deste aparelho ou tentar mais tarde.',
              style: AppText.caption,
            )
          else
            _version(c.remoteDeleted ? 'Na nuvem (excluído)' : 'Na nuvem',
                c.collection, remote),
          const SizedBox(height: AppSpace.md),
          Wrap(spacing: AppSpace.sm, runSpacing: AppSpace.sm, children: [
            FilledButton.tonal(
              onPressed: _busy
                  ? null
                  : () => _run(() => _conflicts.keepLocal(c),
                      c.remoteDeleted ? 'Restaurado com a sua versão' : 'Mantida a versão deste aparelho'),
              child: Text(c.remoteDeleted
                  ? 'Restaurar com a versão deste aparelho'
                  : 'Manter a deste aparelho'),
            ),
            if (remote != null)
              OutlinedButton(
                onPressed: _busy
                    ? null
                    : () => _run(() => _conflicts.useRemote(c),
                        c.remoteDeleted ? 'Exclusão aceita' : 'Usada a versão da nuvem'),
                child: Text(c.remoteDeleted
                    ? 'Aceitar a exclusão'
                    : 'Usar a da nuvem'),
              ),
          ]),
        ],
      ),
    );
  }

  String _title(SyncConflict c) => switch (c.collection) {
        LocalStore.drinkEntries => 'Bebida editada em dois aparelhos',
        LocalStore.outingTabs => 'Comanda alterada em dois aparelhos',
        LocalStore.outings => 'Rolê alterado em dois aparelhos',
        LocalStore.places => 'Local alterado em dois aparelhos',
        LocalStore.customDrinks => 'Bebida pessoal alterada em dois aparelhos',
        _ => 'Item alterado em dois aparelhos',
      };

  Widget _version(String label, String collection, Map<String, dynamic> j) {
    final updated = DateTime.tryParse(j['updated_at'] as String? ?? '');
    final lines = <String>[
      ..._describe(collection, j),
      if (updated != null) 'Editado em ${formatDateTime(updated.toLocal())}',
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpace.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.overline),
          for (final l in lines) Text(l, style: AppText.body),
        ],
      ),
    );
  }

  /// A few readable facts of each version (never ids or column names).
  List<String> _describe(String collection, Map<String, dynamic> j) {
    String money(Object? c) => c is num ? formatCents(c.toInt()) : 'sem preço';
    switch (collection) {
      case LocalStore.drinkEntries:
        return [
          '${j['name'] ?? 'Bebida'} · ${j['personal_ml'] ?? '?'} ml',
          'Pago: ${money(j['paid_cents'])}',
        ];
      case LocalStore.outingTabs:
        final data = j['data'] is Map ? j['data'] as Map : const {};
        final payments = (data['payments'] as List?) ?? const [];
        final paid = payments.fold<int>(
            0, (s, p) => s + ((p is Map ? p['cents'] : 0) as num? ?? 0).toInt());
        final people = (data['participants'] as List?)?.length ?? 0;
        return [
          '$people participante(s) · ${(data['extras'] as List?)?.length ?? 0} item(ns) extra(s)',
          '${payments.length} pagamento(s) registrados: ${formatCents(paid)}',
        ];
      case LocalStore.outings:
        final started = DateTime.tryParse(j['started_at'] as String? ?? '');
        final ended = DateTime.tryParse(j['ended_at'] as String? ?? '');
        return [
          (j['nickname'] ?? j['place_name'] ?? j['address'] ?? 'Rolê').toString(),
          if (started != null) 'Início: ${formatDateTime(started.toLocal())}',
          ended != null ? 'Fim: ${formatDateTime(ended.toLocal())}' : 'Em andamento',
        ];
      default:
        return [
          (j['nickname'] ?? j['name'] ?? j['provider_name'] ?? j['address'] ?? 'Item')
              .toString(),
        ];
    }
  }
}
