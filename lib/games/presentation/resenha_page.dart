import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../core/navigation/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../data/game_repository.dart';
import '../domain/game_models.dart';
import '../../glass/presentation/tip_glass_page.dart';
import 'custom_cards_page.dart';
import 'game_play_page.dart';
import 'game_setup_page.dart';
import '../../l10n/l10n.dart';

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
        title: Text(tr.navGames),
        actions: const [SettingsAction()],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSpace.gutter, 0, AppSpace.gutter, AppSpace.xxl),
          children: [
            Text(tr.resenhaIntro, style: AppText.caption),
            if (saved != null) ...[
              SectionTitle(tr.resenhaInProgress),
              SurfaceCard(
                highlight: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(saved.game.title, style: AppText.title),
                    const SizedBox(height: AppSpace.xs),
                    Text(
                      tr.resenhaSession(saved.players.length, saved.mode.label),
                      style: AppText.caption,
                    ),
                    const SizedBox(height: AppSpace.md),
                    Row(children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: () => _open(const GamePlayPage.resume()),
                          child: Text(tr.resenhaResume),
                        ),
                      ),
                      const SizedBox(width: AppSpace.sm),
                      TextButton(
                        onPressed: () async {
                          await _repo.clearSession();
                          if (mounted) setState(() {});
                        },
                        child: Text(tr.entryDiscard),
                      ),
                    ]),
                  ],
                ),
              ),
            ],
            SectionTitle(tr.resenhaGames),
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
            SectionTitle(tr.resenhaPlay),
            SurfaceCard(
              onTap: () => _open(const TipGlassPage()),
              child: Row(children: [
                const Icon(Icons.rotate_right_rounded, color: AppColors.amber),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tr.resenhaTipTitle, style: AppText.subtitle),
                      Text(tr.resenhaTipBody, style: AppText.caption),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textMuted),
              ]),
            ),
            SectionTitle(tr.resenhaCards),
            SurfaceCard(
              onTap: () => _open(const CustomCardsPage()),
              child: Row(children: [
                const Icon(Icons.edit_note_rounded, color: AppColors.amber),
                const SizedBox(width: AppSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tr.resenhaMyCards, style: AppText.subtitle),
                      Text(
                        tr.resenhaMyCardsCount(_repo.customCards.length),
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
