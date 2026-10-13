import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/injector.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/money_field.dart';
import '../../places/domain/place.dart';
import '../../places/domain/place_draft.dart';
import '../../places/presentation/place_picker_page.dart';
import 'outing_type_picker.dart';
import 'start_outing_cubit.dart';
import '../../l10n/l10n.dart';

/// Pops with the id of the created (or already running) outing.
class StartOutingPage extends StatelessWidget {
  const StartOutingPage({super.key, this.place});

  /// Saved place to start at ("Iniciar rolê aqui").
  final Place? place;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = getIt<StartOutingCubit>();
        if (place != null) cubit.selectPlace(place);
        return cubit;
      },
      child: const _StartOutingView(),
    );
  }
}

class _StartOutingView extends StatefulWidget {
  const _StartOutingView();

  @override
  State<_StartOutingView> createState() => _StartOutingViewState();
}

class _StartOutingViewState extends State<_StartOutingView> {
  bool _showAddress = false;

  Future<void> _pick(StartOutingCubit cubit) async {
    final draft = await PlacePickerPage.open(context,
        mode: PlacePickerMode.start, type: cubit.state.type);
    if (draft != null) cubit.choosePlace(draft);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StartOutingCubit>();
    return BlocListener<StartOutingCubit, StartOutingState>(
      listenWhen: (p, c) => p.createdId != c.createdId && c.createdId != null,
      listener: (context, state) => Navigator.of(context).pop(state.createdId),
      child: Scaffold(
        appBar: AppBar(title: Text(tr.startTitle)),
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
                        SectionTitle(tr.startWhatKind),
                        OutingTypePicker(
                          selected: state.type,
                          onSelected: cubit.setType,
                        ),
                        SectionTitle(tr.startWhere),
                        if (state.place != null)
                          _ChosenPlace(
                            place: state.place!,
                            onClear: () => cubit.selectPlace(null),
                          )
                        else ...[
                          SurfaceCard(
                            onTap: () => _pick(cubit),
                            child: Row(children: [
                              const Icon(Icons.search_rounded,
                                  color: AppColors.amber),
                              const SizedBox(width: AppSpace.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(tr.startSearchPlace,
                                        style: AppText.subtitle),
                                    Text(tr.startSearchPlaceHint,
                                        style: AppText.caption),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded,
                                  color: AppColors.textMuted),
                            ]),
                          ),
                          const SizedBox(height: AppSpace.md),
                          if (shortcuts.isNotEmpty) ...[
                            Text(tr.startSavedPlaces, style: AppText.caption),
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
                            Text(tr.startOrNickname, style: AppText.caption),
                            const SizedBox(height: AppSpace.sm),
                          ],
                          TextField(
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: tr.startNicknameLabel,
                              hintText: tr.startNicknameHint,
                              errorText: placeError,
                            ),
                            onChanged: cubit.setNickname,
                          ),
                          if (!_showAddress)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: () =>
                                    setState(() => _showAddress = true),
                                icon: const Icon(Icons.add_rounded),
                                label: Text(tr.startAddAddress),
                              ),
                            )
                          else ...[
                          const SizedBox(height: AppSpace.md),
                          TextField(
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: tr.startAddressLabel,
                              hintText: tr.startAddressHint,
                              helperText: tr.startAddressHelper,
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
                                  decoration: InputDecoration(
                                      labelText: tr.startCityLabel),
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
                                    labelText: tr.startStateLabel,
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
                          ],
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(tr.startSavePlace),
                            subtitle: Text(tr.startSavePlaceHint),
                            value: state.saveAsPlace,
                            activeThumbColor: AppColors.amber,
                            onChanged: cubit.setSaveAsPlace,
                          ),
                        ],
                        SectionTitle(tr.startWhen),
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
                            Text(tr.commonEdit,
                                style:
                                    const TextStyle(color: AppColors.amber)),
                          ]),
                        ),
                        SectionTitle(tr.startBudgetSection),
                        MoneyField(
                          label: tr.startBudgetLabel,
                          helper: tr.startBudgetHelper,
                          onChanged: cubit.setBudgetCents,
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
                      label: Text(tr.startBegin),
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

  final PlaceDraft place;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final saved = place.isSavedAsIs ? place.saved : null;
    final address = saved != null ? saved.subtitleAddress : place.address;
    final extra = [
      if (saved == null && place.nickname != null && place.providerName != null)
        place.providerName!,
      if (address != null && address != place.title) address,
      if (saved?.cityState != null) saved!.cityState!,
    ];
    final willSave = saved == null && (place.saved != null || place.save);
    return SurfaceCard(
      highlight: true,
      child: Row(children: [
        Icon(saved?.type.icon ?? Icons.place_rounded, color: AppColors.amber),
        const SizedBox(width: AppSpace.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(place.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.subtitle),
              for (final line in extra)
                Text(line,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.caption),
              if (willSave)
                Text(tr.startWillSavePlace, style: AppText.caption),
            ],
          ),
        ),
        TextButton(onPressed: onClear, child: Text(tr.startChangePlace)),
      ]),
    );
  }
}
