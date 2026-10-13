import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/state_views.dart';
import '../data/game_repository.dart';
import '../domain/game_models.dart';
import '../../l10n/l10n.dart';

/// The user's own cards: create and delete. Bundled cards are not editable.
class CustomCardsPage extends StatefulWidget {
  const CustomCardsPage({super.key});

  @override
  State<CustomCardsPage> createState() => _CustomCardsPageState();
}

class _CustomCardsPageState extends State<CustomCardsPage> {
  late final GameRepository _repo = getIt<GameRepository>();
  StreamSubscription<void>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = _repo.changes.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _add() async {
    var game = GameType.neverHaveIEver;
    var mode = GameMode.light;
    var kind = CardKind.truth;
    final text = TextEditingController();
    String? error;
    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text(tr.gameNewCard),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: AppSpace.sm,
                  runSpacing: AppSpace.sm,
                  children: [
                    for (final g in GameType.values)
                      ChoiceChip(
                        label: Text(g.title),
                        selected: game == g,
                        showCheckmark: false,
                        onSelected: (_) => setState(() => game = g),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpace.md),
                SegmentedButton<GameMode>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                        value: GameMode.light, label: Text(GameMode.light.label)),
                    ButtonSegment(
                        value: GameMode.adult, label: Text(GameMode.adult.label)),
                  ],
                  selected: {mode},
                  onSelectionChanged: (s) => setState(() => mode = s.first),
                ),
                if (game == GameType.truthOrDare) ...[
                  const SizedBox(height: AppSpace.md),
                  SegmentedButton<CardKind>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                          value: CardKind.truth,
                          label: Text(CardKind.truth.label)),
                      ButtonSegment(
                          value: CardKind.dare, label: Text(CardKind.dare.label)),
                    ],
                    selected: {kind},
                    onSelectionChanged: (s) => setState(() => kind = s.first),
                  ),
                ],
                const SizedBox(height: AppSpace.md),
                TextField(
                  controller: text,
                  maxLength: 240,
                  minLines: 2,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: tr.gameCardText,
                    hintText: game == GameType.neverHaveIEver
                        ? tr.gameCardHintNever
                        : (game == GameType.mostLikely
                            ? tr.gameCardHintMost
                            : null),
                    errorText: error,
                  ),
                ),
                const SizedBox(height: AppSpace.xs),
                Text(tr.gameCardRules, style: AppText.caption),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(tr.commonCancel)),
            TextButton(
              onPressed: () async {
                try {
                  await _repo.addCustom(
                      game: game, mode: mode, kind: kind, text: text.text);
                  if (ctx.mounted) Navigator.pop(ctx, true);
                } on ArgumentError catch (e) {
                  setState(() => error = '${e.message}');
                }
              },
              child: Text(tr.commonSave),
            ),
          ],
        ),
      ),
    );
    text.dispose();
    if (created == true && mounted) showToast(context, tr.gameCardCreated);
  }

  Future<void> _delete(GameCard card) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr.gameCardDeleteTitle),
        content: Text(card.text),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(tr.commonCancel)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(tr.commonDelete,
                  style: const TextStyle(color: AppColors.danger))),
        ],
      ),
    );
    if (ok == true) await _repo.deleteCustom(card.id);
  }

  @override
  Widget build(BuildContext context) {
    final cards = _repo.customCards;
    return Scaffold(
      appBar: AppBar(title: Text(tr.resenhaMyCards)),
      body: Column(
        children: [
          Expanded(
            child: cards.isEmpty
                ? EmptyView(
                    icon: Icons.edit_note_rounded,
                    title: tr.gameCardsEmptyTitle,
                    message: tr.gameCardsEmptyBody,
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpace.gutter, 0, AppSpace.gutter, AppSpace.xl),
                    children: [
                      for (final c in cards)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpace.sm),
                          child: SurfaceCard(
                            child: Row(children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(c.text, style: AppText.body),
                                    const SizedBox(height: AppSpace.xs),
                                    Text(
                                      c.game == GameType.truthOrDare
                                          ? tr.gameCardLineKind(c.game.title,
                                              c.mode.label, c.kind.label)
                                          : tr.gameCardLine(
                                              c.game.title, c.mode.label),
                                      style: AppText.caption,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: tr.gameCardDelete,
                                onPressed: () => _delete(c),
                                icon: const Icon(Icons.delete_outline_rounded,
                                    color: AppColors.danger),
                              ),
                            ]),
                          ),
                        ),
                    ],
                  ),
          ),
          BottomActionBar(
            child: FilledButton.icon(
              onPressed: _add,
              icon: const Icon(Icons.add_rounded),
              label: Text(tr.gameNewCard),
            ),
          ),
        ],
      ),
    );
  }
}
