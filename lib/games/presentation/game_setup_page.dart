import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../data/game_repository.dart';
import '../domain/game_models.dart';
import 'game_play_page.dart';

/// Participants (nicknames only), mode and optional points, then start.
class GameSetupPage extends StatefulWidget {
  const GameSetupPage({super.key, required this.game});

  final GameType game;

  @override
  State<GameSetupPage> createState() => _GameSetupPageState();
}

class _GameSetupPageState extends State<GameSetupPage> {
  final _name = TextEditingController();
  late final List<String> _players =
      List.of(getIt<GameRepository>().lastPlayers);
  GameMode _mode = GameMode.light;
  bool _adultsConfirmed = false;
  bool _points = false;
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
      setState(() => _error = 'Já existe alguém com esse apelido.');
      return;
    }
    if (_players.length >= 20) {
      setState(() => _error = 'No máximo 20 participantes.');
      return;
    }
    setState(() {
      _players.add(value);
      _name.clear();
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
          usePoints: _points,
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
                  AppSpace.gutter, 0, AppSpace.gutter, AppSpace.xl),
              children: [
                Text(g.description, style: AppText.caption),
                const SectionTitle('Quem vai jogar?'),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _add(),
                      decoration: InputDecoration(
                        labelText: 'Apelido',
                        errorText: _error,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpace.sm),
                  IconButton.filled(
                    tooltip: 'Adicionar participante',
                    onPressed: _add,
                    icon: const Icon(Icons.add_rounded),
                  ),
                ]),
                const SizedBox(height: AppSpace.md),
                if (_players.isEmpty)
                  Text(
                    g.minPlayers == 1
                        ? 'Adicione pelo menos 1 participante.'
                        : 'Adicione pelo menos ${g.minPlayers} participantes.',
                    style: AppText.caption,
                  )
                else
                  Wrap(
                    spacing: AppSpace.sm,
                    runSpacing: AppSpace.sm,
                    children: [
                      for (final p in _players)
                        InputChip(
                          label: Text(p),
                          onDeleted: () => setState(() => _players.remove(p)),
                          deleteButtonTooltipMessage: 'Remover $p',
                        ),
                    ],
                  ),
                const SectionTitle('Modo'),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<GameMode>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: GameMode.light, label: Text('Leve')),
                      ButtonSegment(value: GameMode.adult, label: Text('+18')),
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
                  _mode == GameMode.light
                      ? 'Sem conteúdo sexual. Para qualquer turma.'
                      : 'Mistura as cartas leves com flerte e humor para '
                          'adultos. Nada explícito, e tudo pode ser pulado '
                          'sem punição.',
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
                    title: const Text(
                      'Confirmo que todas as pessoas que vão jogar são '
                      'adultas (18+) e toparam o modo +18.',
                    ),
                  ),
                const SectionTitle('Pontos'),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Contar pontos (opcional)'),
                  subtitle: const Text(
                      'Dá para jogar só na conversa, sem placar.'),
                  value: _points,
                  activeThumbColor: AppColors.amber,
                  onChanged: (v) => setState(() => _points = v),
                ),
                const SizedBox(height: AppSpace.md),
                const Text(
                  'As cartas nunca pedem para beber, virar doses ou '
                  'acumular bebidas, e nada aqui registra bebidas no seu rolê.',
                  style: AppText.caption,
                ),
              ],
            ),
          ),
          BottomActionBar(
            child: FilledButton.icon(
              onPressed: _canStart ? _start : null,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Começar'),
            ),
          ),
        ],
      ),
    );
  }
}
