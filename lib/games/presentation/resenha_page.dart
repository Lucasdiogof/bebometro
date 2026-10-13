import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../data/game_repository.dart';
import '../domain/game_models.dart';
import 'custom_cards_page.dart';
import 'game_play_page.dart';
import 'game_setup_page.dart';

/// Home of the party games. Works offline, needs no account and no active
/// outing, and nothing here registers drinks.
class ResenhaPage extends StatefulWidget {
  const ResenhaPage({super.key});

  @override
  State<ResenhaPage> createState() => _ResenhaPageState();
}

class _ResenhaPageState extends State<ResenhaPage> {
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

  Future<void> _open(Widget page) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final saved = _repo.savedSession;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resenha'),
        actions: const [SettingsAction()],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSpace.gutter, 0, AppSpace.gutter, AppSpace.xxl),
          children: [
            const Text(
              'Jogos para a mesa, sem internet e sem conta. As cartas não '
              'pedem para beber e não registram nenhuma bebida.',
              style: AppText.caption,
            ),
            if (saved != null) ...[
              const SectionTitle('Partida em andamento'),
              SurfaceCard(
                highlight: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(saved.game.title, style: AppText.title),
                    const SizedBox(height: AppSpace.xs),
                    Text(
                      '${saved.players.length} participantes · '
                      'modo ${saved.mode.label}',
                      style: AppText.caption,
                    ),
                    const SizedBox(height: AppSpace.md),
                    Row(children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () => _open(const GamePlayPage.resume()),
                          child: const Text('Retomar'),
                        ),
                      ),
                      const SizedBox(width: AppSpace.sm),
                      TextButton(
                        onPressed: () async {
                          await _repo.clearSession();
                          if (mounted) setState(() {});
                        },
                        child: const Text('Descartar'),
                      ),
                    ]),
                  ],
                ),
              ),
            ],
            const SectionTitle('Jogos'),
            for (final g in GameType.values)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpace.sm),
                child: SurfaceCard(
                  onTap: () => _open(GameSetupPage(game: g)),
                  child: Row(children: [
                    Icon(_icon(g), color: AppColors.amber, size: 30),
                    const SizedBox(width: AppSpace.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(g.title, style: AppText.subtitle),
                          Text(g.description, style: AppText.caption),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.textMuted),
                  ]),
                ),
              ),
            const SectionTitle('Cartas'),
            SurfaceCard(
              onTap: () => _open(const CustomCardsPage()),
              child: Row(children: [
                const Icon(Icons.edit_note_rounded, color: AppColors.amber),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Minhas cartas', style: AppText.subtitle),
                      Text(
                        '${_repo.customCards.length} criadas por você',
                        style: AppText.caption,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textMuted),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  IconData _icon(GameType g) => switch (g) {
        GameType.neverHaveIEver => Icons.do_not_disturb_alt_rounded,
        GameType.mostLikely => Icons.how_to_vote_rounded,
        GameType.truthOrDare => Icons.help_center_rounded,
      };
}
