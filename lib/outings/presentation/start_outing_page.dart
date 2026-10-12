import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../domain/outing.dart';
import 'start_outing_cubit.dart';

/// Pops with the id of the created (or already running) outing.
class StartOutingPage extends StatelessWidget {
  const StartOutingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<StartOutingCubit>(),
      child: const _StartOutingView(),
    );
  }
}

class _StartOutingView extends StatelessWidget {
  const _StartOutingView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StartOutingCubit>();
    return BlocListener<StartOutingCubit, StartOutingState>(
      listenWhen: (p, c) => p.createdId != c.createdId && c.createdId != null,
      listener: (context, state) => Navigator.of(context).pop(state.createdId),
      child: Scaffold(
        appBar: AppBar(title: const Text('Iniciar rolê')),
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<StartOutingCubit, StartOutingState>(
            builder: (context, state) {
              final placeError =
                  state.showErrors ? state.placeError : null;
              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.fromLTRB(
                          AppSpace.gutter, 0, AppSpace.gutter, AppSpace.xl),
                      children: [
                        const SectionTitle('Que tipo de rolê?'),
                        _TypePicker(
                          selected: state.type,
                          onSelected: cubit.setType,
                        ),
                        const SectionTitle('Onde?'),
                        TextField(
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Apelido do local',
                            hintText: 'Ex.: Bar MELT, Casa da Samara',
                            errorText: placeError,
                          ),
                          onChanged: cubit.setNickname,
                        ),
                        const SizedBox(height: AppSpace.md),
                        TextField(
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            labelText: 'Endereço (opcional)',
                            hintText: 'Rua, número, bairro',
                            helperText: 'Apelido ou endereço já bastam.',
                            errorText: placeError == null ? null : ' ',
                          ),
                          onChanged: cubit.setAddress,
                          onSubmitted: (_) => cubit.submit(),
                        ),
                        const SectionTitle('Quando começou?'),
                        SurfaceCard(
                          onTap: () async {
                            final picked =
                                await pickDateTime(context, state.startedAt);
                            if (picked != null) cubit.setStartedAt(picked);
                          },
                          child: Row(children: [
                            const Icon(Icons.schedule_rounded,
                                color: AppColors.amber),
                            const SizedBox(width: AppSpace.md),
                            Expanded(
                              child: Text(formatDateTime(state.startedAt),
                                  style: AppText.subtitle),
                            ),
                            const Text('Editar',
                                style: TextStyle(color: AppColors.amber)),
                          ]),
                        ),
                        if (state.error != null)
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpace.md),
                            child: Text(state.error!,
                                style:
                                    const TextStyle(color: AppColors.danger)),
                          ),
                      ],
                    ),
                  ),
                  BottomActionBar(
                    child: FilledButton.icon(
                      onPressed: state.submitting ? null : cubit.submit,
                      icon: state.submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.play_arrow_rounded),
                      label: const Text('Começar o rolê'),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _TypePicker extends StatelessWidget {
  const _TypePicker({required this.selected, required this.onSelected});

  final OutingType selected;
  final ValueChanged<OutingType> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      const gap = AppSpace.sm;
      final width = (constraints.maxWidth - gap * 2) / 3;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final t in OutingType.values)
            SizedBox(
              width: width,
              child: Semantics(
                button: true,
                selected: selected == t,
                label: t.label,
                child: SurfaceCard(
                  selected: selected == t,
                  onTap: () => onSelected(t),
                  padding: const EdgeInsets.symmetric(
                      vertical: AppSpace.md, horizontal: AppSpace.xs),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        t.icon,
                        size: 26,
                        color: selected == t
                            ? AppColors.amber
                            : AppColors.textMuted,
                      ),
                      const SizedBox(height: AppSpace.xs),
                      Text(
                        t.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: selected == t
                              ? AppColors.text
                              : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}
