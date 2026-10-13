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
import '../../l10n/l10n.dart';

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
      if (mounted) showToast(context, tr.conflictApplyFailed);
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
      appBar: AppBar(title: Text(tr.conflictTitle)),
      body: StreamBuilder<void>(
        stream: _conflicts.changes,
        builder: (context, _) {
          final items = _conflicts.all;
          if (items.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpace.xl),
                child: Text(tr.conflictNone,
                    style: AppText.body, textAlign: TextAlign.center),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(
                AppSpace.gutter, AppSpace.sm, AppSpace.gutter, AppSpace.xxl),
            children: [
              Text(tr.conflictIntro, style: AppText.caption),
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
          Text(tr.legacyTwoActiveTitle, style: AppText.title),
          const SizedBox(height: AppSpace.xs),
          Text(tr.conflictTwoActiveBody, style: AppText.caption),
          const SizedBox(height: AppSpace.md),
          _outingLine(tr.conflictFromHere, local),
          if (other != null) _outingLine(tr.conflictFromOther, other),
          const SizedBox(height: AppSpace.sm),
          Wrap(spacing: AppSpace.sm, runSpacing: AppSpace.sm, children: [
            OutlinedButton(
              onPressed: _busy
                  ? null
                  : () => _run(() => _endOne(c, c.id), tr.conflictOutingEnded),
              child: Text(tr.conflictEndHere),
            ),
            if (other != null)
              OutlinedButton(
                onPressed: _busy
                    ? null
                    : () => _run(() => _endOne(c, c.otherId!), tr.conflictOutingEnded),
                child: Text(tr.conflictEndOther),
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
        tr.outingFallbackName;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.xs),
      child: Text(
        [
          tr.conflictOutingLine(label, name),
          if (started != null)
            tr.conflictSince(formatDateTime(started.toLocal())),
          tr.drinkCount(drinks),
        ].join(' · '),
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
          _version(tr.conflictHere, c.collection, c.local),
          const SizedBox(height: AppSpace.sm),
          if (remote == null)
            Text(tr.conflictRemoteUnreadable, style: AppText.caption)
          else
            _version(c.remoteDeleted ? tr.conflictCloudDeleted : tr.conflictCloud,
                c.collection, remote),
          const SizedBox(height: AppSpace.md),
          Wrap(spacing: AppSpace.sm, runSpacing: AppSpace.sm, children: [
            FilledButton.tonal(
              onPressed: _busy
                  ? null
                  : () => _run(() => _conflicts.keepLocal(c),
                      c.remoteDeleted ? tr.conflictRestored : tr.conflictKeptLocal),
              child: Text(c.remoteDeleted
                  ? tr.conflictRestore
                  : tr.conflictKeepLocal),
            ),
            if (remote != null)
              OutlinedButton(
                onPressed: _busy
                    ? null
                    : () => _run(() => _conflicts.useRemote(c),
                        c.remoteDeleted ? tr.conflictDeletionAccepted : tr.conflictUsedRemote),
                child: Text(c.remoteDeleted
                    ? tr.conflictAcceptDeletion
                    : tr.conflictUseRemote),
              ),
          ]),
        ],
      ),
    );
  }

  String _title(SyncConflict c) => switch (c.collection) {
        LocalStore.drinkEntries => tr.conflictDrink,
        LocalStore.outingTabs => tr.conflictTab,
        LocalStore.outings => tr.conflictOuting,
        LocalStore.places => tr.conflictPlace,
        LocalStore.customDrinks => tr.conflictCustomDrink,
        _ => tr.conflictItem,
      };

  Widget _version(String label, String collection, Map<String, dynamic> j) {
    final updated = DateTime.tryParse(j['updated_at'] as String? ?? '');
    final lines = <String>[
      ..._describe(collection, j),
      if (updated != null) tr.conflictEditedAt(formatDateTime(updated.toLocal())),
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
    String money(Object? c) => c is num ? formatCents(c.toInt()) : tr.priceUnknown;
    switch (collection) {
      case LocalStore.drinkEntries:
        return [
          '${j['name'] ?? tr.drinkFallbackName} · '
              '${j['personal_ml'] is num ? formatMl((j['personal_ml'] as num).toInt()) : '?'}',
          tr.conflictPaid(money(j['paid_cents'])),
        ];
      case LocalStore.outingTabs:
        final data = j['data'] is Map ? j['data'] as Map : const {};
        final payments = (data['payments'] as List?) ?? const [];
        final paid = payments.fold<int>(
            0, (s, p) => s + ((p is Map ? p['cents'] : 0) as num? ?? 0).toInt());
        final people = (data['participants'] as List?)?.length ?? 0;
        return [
          tr.conflictTabPeople(people, (data['extras'] as List?)?.length ?? 0),
          tr.conflictTabPayments(payments.length, formatCents(paid)),
        ];
      case LocalStore.outings:
        final started = DateTime.tryParse(j['started_at'] as String? ?? '');
        final ended = DateTime.tryParse(j['ended_at'] as String? ?? '');
        return [
          (j['nickname'] ?? j['place_name'] ?? j['address'] ?? tr.outingFallbackName).toString(),
          if (started != null) tr.conflictStart(formatDateTime(started.toLocal())),
          ended != null ? tr.conflictEnd(formatDateTime(ended.toLocal())) : tr.outingInProgress,
        ];
      default:
        return [
          (j['nickname'] ?? j['name'] ?? j['provider_name'] ?? j['address'] ?? tr.itemFallbackName)
              .toString(),
        ];
    }
  }
}
