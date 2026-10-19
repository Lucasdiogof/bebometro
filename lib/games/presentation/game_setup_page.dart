import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../outings/data/outing_repository.dart';
import '../../tab/data/tab_repository.dart';
import '../data/game_repository.dart';
import '../domain/game_models.dart';
import 'game_play_page.dart';
import '../../l10n/l10n.dart';

/// Participants (nicknames only; the running outing's people can be picked),
/// mode, then start. There is no score.
class GameSetupPage extends StatefulWidget {
  const GameSetupPage({super.key, required this.game});

  final GameType game;

  @override
  State<GameSetupPage> createState() => _GameSetupPageState();
}

class _GameSetupPageState extends State<GameSetupPage> {
  final _name = TextEditingController();
  late final List<String> _players = List.of(
    getIt<GameRepository>().lastPlayers,
  );
  GameMode _mode = GameMode.light;
  bool _adultsConfirmed = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _add() {
    final value = _name.text.trim();
    if (value.isEmpty) return;
    if (_players.any((p) => p.toLowerCase() == value.toLowerCase())) {
      setState(() => _error = tr.gameAlreadyPlayer);
      return;
    }
    if (_players.length >= 20) {
      setState(() => _error = tr.gameMaxPlayers);
      return;
    }
    setState(() {
      _players.add(value);
      _name.clear();
      _error = null;
    });
  }

  /// Names of the people on the running outing's table (who is still there).
  List<String> get _outingPeople {
    final outing = getIt<OutingRepository>().active;
    if (outing == null) return const [];
    final tab = getIt<TabRepository>().load(outing.id);
    return [
      for (final p in tab.participants)
        if (!p.left) p.displayName,
    ];
  }

  Future<void> _importFromOuting() async {
    final names = _outingPeople;
    final picked = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final chosen = {
          for (final n in names)
            if (_players.any((p) => p.toLowerCase() == n.toLowerCase())) n,
        };
        return StatefulBuilder(
          builder: (ctx, setSheet) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpace.gutter,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(tr.gameImportTitle, style: AppText.title),
                  ),
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final n in names)
                        CheckboxListTile(
                          value: chosen.contains(n),
                          title: Text(n),
                          onChanged: (v) => setSheet(() {
                            if (v == true) {
                              chosen.add(n);
                            } else {
                              chosen.remove(n);
                            }
                          }),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpace.gutter),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(ctx, chosen),
                      child: Text(tr.gameImportUse),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (picked == null) return;
    setState(() {
      for (final n in picked) {
        if (_players.length < 20 &&
            !_players.any((p) => p.toLowerCase() == n.toLowerCase())) {
          _players.add(n);
        }
      }
      _error = null;
    });
  }

  bool get _canStart =>
      _players.length >= widget.game.minPlayers &&
      (_mode == GameMode.light || _adultsConfirmed);

  Future<void> _start() async {
    if (!_canStart) return;
    await getIt<GameRepository>().saveLastPlayers(_players);
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => GamePlayPage.start(
          game: widget.game,
          mode: _mode,
          players: List.of(_players),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final g = widget.game;
    return Scaffold(
      appBar: AppBar(title: Text(g.title)),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(
                AppSpace.gutter,
                0,
                AppSpace.gutter,
                AppSpace.xl,
              ),
              children: [
                Text(g.description, style: AppText.caption),
                SectionTitle(tr.gameWhoPlays),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _name,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _add(),
                        decoration: InputDecoration(
                          labelText: tr.pickerManualNickname,
                          errorText: _error,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpace.sm),
                    IconButton.filled(
                      tooltip: tr.gameAddPlayerTooltip,
                      onPressed: _add,
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
                if (_outingPeople.isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: _importFromOuting,
                      icon: const Icon(Icons.group_add_outlined),
                      label: Text(tr.gameImportFromOuting),
                    ),
                  ),
                const SizedBox(height: AppSpace.sm),
                if (_players.isEmpty)
                  Text(tr.gameNeedPlayers(g.minPlayers), style: AppText.caption)
                else
                  Wrap(
                    spacing: AppSpace.sm,
                    runSpacing: AppSpace.sm,
                    children: [
                      for (final p in _players)
                        InputChip(
                          label: Text(p),
                          onDeleted: () => setState(() => _players.remove(p)),
                          deleteButtonTooltipMessage: tr.gameRemovePlayer(p),
                        ),
                    ],
                  ),
                SectionTitle(tr.gameMode),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<GameMode>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: GameMode.light,
                        label: Text(GameMode.light.label),
                      ),
                      ButtonSegment(
                        value: GameMode.adult,
                        label: Text(GameMode.adult.label),
                      ),
                    ],
                    selected: {_mode},
                    onSelectionChanged: (s) => setState(() {
                      _mode = s.first;
                      if (_mode == GameMode.light) _adultsConfirmed = false;
                    }),
                  ),
                ),
                const SizedBox(height: AppSpace.sm),
                Text(
                  _mode == GameMode.light ? tr.gameLightNote : tr.gameAdultNote,
                  style: AppText.caption,
                ),
                if (_mode == GameMode.adult)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: AppColors.amber,
                    value: _adultsConfirmed,
                    onChanged: (v) =>
                        setState(() => _adultsConfirmed = v ?? false),
                    title: Text(tr.gameAdultConfirm),
                  ),
                const SizedBox(height: AppSpace.md),
                Text(tr.gameNoDrinkNote, style: AppText.caption),
              ],
            ),
          ),
          BottomActionBar(
            child: FilledButton.icon(
              onPressed: _canStart ? _start : null,
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(tr.gameStart),
            ),
          ),
        ],
      ),
    );
  }
}
