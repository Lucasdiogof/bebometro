import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
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
          child: BlocBuilder<StartOutingCubit, StartOutingState>(
            builder: (context, state) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  const SectionTitle('TIPO DE ROLÊ'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final t in OutingType.values)
                        ChoiceChip(
                          avatar: Icon(
                            t.icon,
                            size: 18,
                            color: state.type == t
                                ? const Color(0xFF241800)
                                : AppColors.textMuted,
                          ),
                          label: Text(t.label),
                          selected: state.type == t,
                          showCheckmark: false,
                          onSelected: (_) => cubit.setType(t),
                        ),
                    ],
                  ),
                  const SectionTitle('LOCAL'),
                  TextField(
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Apelido do local',
                      hintText: 'Ex.: Bar MELT, Casa da Samara',
                    ),
                    onChanged: cubit.setNickname,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Endereço (opcional se tiver apelido)',
                      hintText: 'Rua, número, bairro',
                    ),
                    onChanged: cubit.setAddress,
                  ),
                  if (state.showErrors && state.placeError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 4),
                      child: Text(
                        state.placeError!,
                        style: const TextStyle(color: AppColors.danger),
                      ),
                    ),
                  const SectionTitle('HORÁRIO DE INÍCIO'),
                  SurfaceCard(
                    onTap: () async {
                      final picked =
                          await pickDateTime(context, state.startedAt);
                      if (picked != null) cubit.setStartedAt(picked);
                    },
                    child: Row(children: [
                      const Icon(Icons.schedule_rounded,
                          color: AppColors.amber),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          formatDateTime(state.startedAt),
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const Text('Editar',
                          style: TextStyle(color: AppColors.amber)),
                    ]),
                  ),
                  if (state.error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        state.error!,
                        style: const TextStyle(color: AppColors.danger),
                      ),
                    ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
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
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
