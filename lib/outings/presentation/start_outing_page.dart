import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../places/domain/place.dart';
import 'outing_type_picker.dart';
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
              final placeError = state.showErrors ? state.placeError : null;
              final shortcuts = cubit.shortcuts;
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
                        OutingTypePicker(
                          selected: state.type,
                          onSelected: cubit.setType,
                        ),
                        const SectionTitle('Onde?'),
                        if (state.place != null)
                          _ChosenPlace(
                            place: state.place!,
                            onClear: () => cubit.selectPlace(null),
                          )
                        else ...[
                          if (shortcuts.isNotEmpty) ...[
                            const Text('Locais salvos', style: AppText.caption),
                            const SizedBox(height: AppSpace.sm),
                            SizedBox(
                              height: 44,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: shortcuts.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(width: AppSpace.sm),
                                itemBuilder: (context, i) {
                                  final p = shortcuts[i];
                                  return ActionChip(
                                    avatar: Icon(
                                      p.favorite
                                          ? Icons.star_rounded
                                          : p.type.icon,
                                      size: 18,
                                      color: AppColors.amber,
                                    ),
                                    label: ConstrainedBox(
                                      constraints:
                                          const BoxConstraints(maxWidth: 180),
                                      child: Text(p.displayName,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                    onPressed: () => cubit.selectPlace(p),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: AppSpace.md),
                            const Text('Ou informe um novo', style: AppText.caption),
                            const SizedBox(height: AppSpace.sm),
                          ],
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
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: 'Endereço (opcional)',
                              hintText: 'Rua, número, bairro',
                              helperText: 'Apelido ou endereço já bastam.',
                              errorText: placeError == null ? null : ' ',
                            ),
                            onChanged: cubit.setAddress,
                          ),
                          const SizedBox(height: AppSpace.md),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextField(
                                  textCapitalization: TextCapitalization.words,
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                      labelText: 'Cidade (opcional)'),
                                  onChanged: cubit.setCity,
                                ),
                              ),
                              const SizedBox(width: AppSpace.sm),
                              Expanded(
                                flex: 1,
                                child: TextField(
                                  textCapitalization:
                                      TextCapitalization.characters,
                                  maxLength: 2,
                                  decoration: InputDecoration(
                                    labelText: 'UF',
                                    counterText: '',
                                    errorText: state.showErrors
                                        ? state.stateError
                                        : null,
                                  ),
                                  onChanged: cubit.setState,
                                ),
                              ),
                            ],
                          ),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Salvar este local'),
                            subtitle: const Text(
                                'Para escolher de novo nos próximos rolês. '
                                'Fica privado no seu perfil.'),
                            value: state.saveAsPlace,
                            activeThumbColor: AppColors.amber,
                            onChanged: cubit.setSaveAsPlace,
                          ),
                        ],
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
                        const SectionTitle('Orçamento (opcional)'),
                        TextField(
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Orçamento para bebidas',
                            prefixText: r'R$ ',
                            helperText:
                                'Você pode definir ou mudar depois, durante o rolê.',
                          ),
                          onChanged: (v) => cubit.setBudgetCents(parseCents(v)),
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

class _ChosenPlace extends StatelessWidget {
  const _ChosenPlace({required this.place, required this.onClear});

  final Place place;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      highlight: true,
      child: Row(children: [
        Icon(place.type.icon, color: AppColors.amber),
        const SizedBox(width: AppSpace.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(place.displayName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.subtitle),
              if (place.subtitleAddress != null)
                Text(place.subtitleAddress!, style: AppText.caption),
              if (place.cityState != null)
                Text(place.cityState!, style: AppText.caption),
            ],
          ),
        ),
        TextButton(onPressed: onClear, child: const Text('Trocar')),
      ]),
    );
  }
}
