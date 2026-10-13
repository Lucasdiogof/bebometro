import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/state_views.dart';
import '../data/game_repository.dart';
import '../domain/game_models.dart';

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
          title: const Text('Nova carta'),
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
                  segments: const [
                    ButtonSegment(value: GameMode.light, label: Text('Leve')),
                    ButtonSegment(value: GameMode.adult, label: Text('+18')),
                  ],
                  selected: {mode},
                  onSelectionChanged: (s) => setState(() => mode = s.first),
                ),
                if (game == GameType.truthOrDare) ...[
                  const SizedBox(height: AppSpace.md),
                  SegmentedButton<CardKind>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: CardKind.truth, label: Text('Verdade')),
                      ButtonSegment(value: CardKind.dare, label: Text('Desafio')),
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
                    labelText: 'Texto da carta',
                    hintText: game == GameType.neverHaveIEver
                        ? 'Eu nunca…'
                        : (game == GameType.mostLikely
                            ? 'Quem é mais provável de…'
                            : null),
                    errorText: error,
                  ),
                ),
                const SizedBox(height: AppSpace.xs),
                const Text(
                  'Sem exposição, gravação, coerção, direção, violência, '
                  'atividades perigosas ou beber como penalidade.',
                  style: AppText.caption,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar')),
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
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
    text.dispose();
    if (created == true && mounted) showToast(context, 'Carta criada');
  }

  Future<void> _delete(GameCard card) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir esta carta?'),
        content: Text(card.text),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Excluir',
                  style: TextStyle(color: AppColors.danger))),
        ],
      ),
    );
    if (ok == true) await _repo.deleteCustom(card.id);
  }

  @override
  Widget build(BuildContext context) {
    final cards = _repo.customCards;
    return Scaffold(
      appBar: AppBar(title: const Text('Minhas cartas')),
      body: Column(
        children: [
          Expanded(
            child: cards.isEmpty
                ? const EmptyView(
                    icon: Icons.edit_note_rounded,
                    title: 'Nenhuma carta sua ainda',
                    message: 'Crie cartas para os seus jogos. Elas entram no '
                        'sorteio das próximas partidas.',
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
                                      '${c.game.title} · ${c.mode.label}'
                                      '${c.game == GameType.truthOrDare ? ' · ${c.kind.label}' : ''}',
                                      style: AppText.caption,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: 'Excluir carta',
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
              label: const Text('Nova carta'),
            ),
          ),
        ],
      ),
    );
  }
}
