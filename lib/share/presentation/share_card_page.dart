import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/common.dart';
import '../../drinks/data/drink_repository.dart';
import '../../drinks/domain/drink_entry.dart';
import '../../outings/data/outing_repository.dart';
import '../../outings/domain/outing.dart';
import '../../outings/domain/outing_summary.dart';
import '../../table/data/table_prefs_cubit.dart';
import '../../table/domain/table_scenario.dart';
import '../../table/presentation/table_scene.dart';
import '../data/share_service.dart';
import '../../l10n/l10n.dart';

/// A shareable summary card of an outing. The person chooses what appears;
/// the address and the personal account are never included, and nothing is
/// published automatically.
class ShareCardPage extends StatefulWidget {
  const ShareCardPage({super.key, required this.outingId});

  final String outingId;

  @override
  State<ShareCardPage> createState() => _ShareCardPageState();
}

class _ShareCardPageState extends State<ShareCardPage> {
  final _boundaryKey = GlobalKey();
  bool _showPlace = false;
  bool _showTable = true;
  bool _showDrinks = true;
  bool _showSpending = false;
  bool _busy = false;

  late final Outing? _outing = getIt<OutingRepository>().byId(widget.outingId);
  late final List<DrinkEntry> _entries =
      getIt<DrinkRepository>().entriesFor(widget.outingId);

  /// Plain-text version, also the fallback when image sharing is unavailable.
  String _summaryText() {
    final o = _outing!;
    final s = OutingSummary.of(_entries);
    final lines = <String>[
      'Bebômetro · ${formatWeekdayDate(o.startedAt)}',
      if (_showPlace) o.displayName,
      if (_showDrinks)
        for (final g in s.groups.take(8)) '${g.count}× ${g.name}',
      if (_showDrinks && s.groups.length > 8)
        tr.shareCardOthers('${s.groups.length - 8}'),
      if (_showSpending)
        s.unpricedCount > 0
            ? tr.shareCardSpendTextPartial(formatCents(s.informedCents))
            : tr.shareCardSpendText(formatCents(s.informedCents)),
    ];
    return lines.join('\n');
  }

  Future<void> _share() async {
    if (_busy) return;
    setState(() => _busy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final bytes = await ShareService.capturePng(_boundaryKey);
      var ok = false;
      if (bytes != null) {
        ok = await ShareService.shareFile(
          bytes: bytes,
          name: 'bebometro-rolê.png',
          mimeType: 'image/png',
          text: _summaryText(),
        );
      }
      if (!ok) {
        await Clipboard.setData(ClipboardData(text: _summaryText()));
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(tr.shareCardFailed),
          ));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _summaryText()));
    if (mounted) showToast(context, tr.tabTextCopied);
  }

  @override
  Widget build(BuildContext context) {
    final outing = _outing;
    if (outing == null) {
      return Scaffold(appBar: AppBar(), body: const SizedBox.shrink());
    }
    final summary = OutingSummary.of(_entries);
    final scenario = context
        .read<TablePrefsCubit>()
        .state
        .scenarioFor(outing.id, outing.type);
    return Scaffold(
      appBar: AppBar(title: Text(tr.shareCardTitle)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                  AppSpace.gutter, 0, AppSpace.gutter, AppSpace.xl),
              children: [
                Text(tr.shareCardIntro, style: AppText.caption),
                const SizedBox(height: AppSpace.md),
                Center(
                  child: FittedBox(
                    child: RepaintBoundary(
                      key: _boundaryKey,
                      child: _Card(
                        outing: outing,
                        entries: _entries,
                        summary: summary,
                        scenario: scenario,
                        showPlace: _showPlace,
                        showTable: _showTable,
                        showDrinks: _showDrinks,
                        showSpending: _showSpending,
                      ),
                    ),
                  ),
                ),
                SectionTitle(tr.shareCardWhat),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(tr.shareCardPlaceName),
                  subtitle: Text(tr.shareCardPlaceNameHint),
                  value: _showPlace,
                  activeThumbColor: AppColors.amber,
                  onChanged: (v) => setState(() => _showPlace = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(tr.tableViewTable),
                  value: _showTable,
                  activeThumbColor: AppColors.amber,
                  onChanged: (v) => setState(() => _showTable = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(tr.statsDrinksLogged),
                  value: _showDrinks,
                  activeThumbColor: AppColors.amber,
                  onChanged: (v) => setState(() => _showDrinks = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(tr.placeStatSpent),
                  subtitle: summary.unpricedCount > 0
                      ? Text(tr.shareCardSpendHint)
                      : null,
                  value: _showSpending,
                  activeThumbColor: AppColors.amber,
                  onChanged: (v) => setState(() => _showSpending = v),
                ),
              ],
            ),
          ),
          BottomActionBar(
            child: Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _copy,
                  icon: const Icon(Icons.copy_rounded),
                  label: Text(tr.tabCopyText),
                ),
              ),
              const SizedBox(width: AppSpace.sm),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _busy ? null : _share,
                  icon: const Icon(Icons.ios_share_rounded),
                  label: Text(tr.tabShareButton),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

/// The card itself (fixed 360×450, rendered at 3× when shared).
class _Card extends StatelessWidget {
  const _Card({
    required this.outing,
    required this.entries,
    required this.summary,
    required this.scenario,
    required this.showPlace,
    required this.showTable,
    required this.showDrinks,
    required this.showSpending,
  });

  final Outing outing;
  final List<DrinkEntry> entries;
  final OutingSummary summary;
  final TableScenario scenario;
  final bool showPlace;
  final bool showTable;
  final bool showDrinks;
  final bool showSpending;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      height: 450,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1F1813), Color(0xFF0E0B09)],
        ),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const BrandCap(size: 34),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                formatWeekdayDate(outing.startedAt),
                style: const TextStyle(
                    color: AppColors.textMuted, fontWeight: FontWeight.w600),
              ),
            ),
          ]),
          const SizedBox(height: 10),
          Text(
            showPlace ? outing.displayName : tr.shareCardMyOuting,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: AppColors.text, fontSize: 26, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          if (showTable)
            SizedBox(
              height: 150,
              child: TableScene(
                entries: entries,
                scenario: scenario,
                animate: false,
                retrospective: true,
                compact: true,
              ),
            ),
          if (showDrinks) ...[
            const SizedBox(height: 12),
            for (final g in summary.groups.take(5))
              Text(
                '${g.count}× ${g.name}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.text, fontSize: 15),
              ),
            if (summary.groups.length > 5)
              Text(tr.shareCardOthers('${summary.groups.length - 5}'),
                  style: const TextStyle(color: AppColors.textMuted)),
          ],
          const Spacer(),
          if (showSpending)
            Text(
              summary.unpricedCount > 0
                  ? tr.shareCardSpendCardPartial(
                      formatCents(summary.informedCents))
                  : tr.shareCardSpendCard(formatCents(summary.informedCents)),
              style: const TextStyle(
                  color: AppColors.amber, fontWeight: FontWeight.w800),
            ),
          const SizedBox(height: 6),
          const BrandWordmark(height: 22),
        ],
      ),
    );
  }
}
