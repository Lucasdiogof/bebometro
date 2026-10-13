import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/widgets/common.dart';
import '../application/tracking_coordinator.dart';

/// "Rolê na tela bloqueada" in the settings. The status line comes from the
/// coordinator, which confirms with the native side; "Ativo" is never claimed
/// just because a switch is on.
class TrackingSettingsSection extends StatefulWidget {
  const TrackingSettingsSection({super.key});

  @override
  State<TrackingSettingsSection> createState() =>
      _TrackingSettingsSectionState();
}

class _TrackingSettingsSectionState extends State<TrackingSettingsSection> {
  final _coordinator = getIt<TrackingCoordinator>();
  StreamSubscription<void>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = _coordinator.prefs.changes.listen((_) {
      if (mounted) setState(() {});
    });
    // Refresh what the system says (permission or Live Activities may have
    // been changed in the system settings).
    _coordinator.schedule(immediate: true);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  String _statusText(TrackingStatus s) {
    switch (s) {
      case TrackingStatus.unsupported:
        if (!_coordinator.platform.isNativePlatform) {
          return 'Não disponível no navegador: o acompanhamento fica só '
              'dentro do app.';
        }
        return _coordinator.platform.isIos
            ? 'Não disponível nesta versão do iOS (precisa do iOS 16.2 ou '
                'mais novo).'
            : 'Não disponível neste aparelho.';
      case TrackingStatus.disabled:
        return 'Desativado por você.';
      case TrackingStatus.permissionDenied:
        return 'Permissão do sistema indisponível. Libere as notificações do '
            'Bebômetro nas configurações do aparelho.';
      case TrackingStatus.systemOff:
        return _coordinator.platform.isIos
            ? 'Desligado nos ajustes do iPhone (Atividades ao Vivo).'
            : 'Notificações desligadas nas configurações do aparelho.';
      case TrackingStatus.noOuting:
        return 'Disponível durante um rolê.';
      case TrackingStatus.hidden:
        return 'Oculto neste rolê. Use "Mostrar novamente" na tela do rolê.';
      case TrackingStatus.dismissed:
        return 'Você removeu da tela bloqueada neste rolê. Use "Mostrar '
            'novamente" na tela do rolê.';
      case TrackingStatus.active:
        return 'Ativo agora.';
      case TrackingStatus.pending:
        return 'Ligado, mas ainda não apareceu. No iPhone ele só começa com '
            'o app aberto; abra o rolê.';
    }
  }

  Future<void> _toggle(bool on) async {
    if (on) {
      final result = await _coordinator.enable();
      if (!mounted) return;
      if (result == TrackingStatus.permissionDenied) {
        showToast(context,
            'Sem permissão de notificações. Dá para liberar nas configurações do aparelho.');
      }
    } else {
      await _coordinator.disable();
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final prefs = _coordinator.prefs;
    return ValueListenableBuilder<TrackingStatus>(
      valueListenable: _coordinator.status,
      builder: (context, status, _) {
        final available = status != TrackingStatus.unsupported;
        return SurfaceCard(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.lg, vertical: AppSpace.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Ativar acompanhamento'),
                subtitle: const Text(
                    'Mostra o tempo e a contagem do rolê em andamento na tela '
                    'bloqueada. Sem som nem vibração.'),
                value: prefs.enabled && available,
                onChanged: available ? _toggle : null,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Mostrar gastos'),
                subtitle: const Text(
                    'Quanto você informou ter gasto em bebidas, não o total '
                    'da mesa.'),
                value: prefs.showSpend,
                onChanged: available && prefs.enabled
                    ? (v) => prefs.setShowSpend(v)
                    : null,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Mostrar nome do local'),
                subtitle: const Text(
                    'Desligado, aparece só "Rolê em andamento". O endereço '
                    'nunca aparece.'),
                value: prefs.showPlace,
                onChanged: available && prefs.enabled
                    ? (v) => prefs.setShowPlace(v)
                    : null,
              ),
              const Divider(height: 20),
              Text(_statusText(status), style: AppText.body),
              const SizedBox(height: AppSpace.xs),
              const Text(
                'O contador mostra quantos registros de bebida alcoólica você '
                'fez (água não conta; uma garrafa dividida é um registro). Não '
                'são doses nem medem alcoolemia. O sistema pode encerrar a '
                'exibição sozinho depois de algumas horas, sem encerrar o '
                'rolê.',
                style: AppText.caption,
              ),
            ],
          ),
        );
      },
    );
  }
}
