import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/outing_repository.dart';
import '../domain/outing.dart';

class StartOutingState {
  const StartOutingState({
    required this.type,
    required this.startedAt,
    this.nickname = '',
    this.address = '',
    this.submitting = false,
    this.showErrors = false,
    this.error,
    this.createdId,
  });

  final OutingType type;
  final DateTime startedAt;
  final String nickname;
  final String address;
  final bool submitting;
  final bool showErrors;
  final String? error;

  /// Set once the outing exists; the page then navigates away.
  final String? createdId;

  /// Needs at least a nickname or an address.
  String? get placeError => (nickname.trim().isEmpty && address.trim().isEmpty)
      ? 'Informe um apelido (ex.: Casa da Samara) ou um endereço'
      : null;

  StartOutingState copyWith({
    OutingType? type,
    DateTime? startedAt,
    String? nickname,
    String? address,
    bool? submitting,
    bool? showErrors,
    String? error,
    String? createdId,
  }) =>
      StartOutingState(
        type: type ?? this.type,
        startedAt: startedAt ?? this.startedAt,
        nickname: nickname ?? this.nickname,
        address: address ?? this.address,
        submitting: submitting ?? this.submitting,
        showErrors: showErrors ?? this.showErrors,
        error: error,
        createdId: createdId ?? this.createdId,
      );
}

class StartOutingCubit extends Cubit<StartOutingState> {
  StartOutingCubit(this._outings)
      : super(StartOutingState(
          type: OutingType.bar,
          startedAt: DateTime.now(),
        ));

  final OutingRepository _outings;

  void setType(OutingType type) => emit(state.copyWith(type: type));
  void setNickname(String v) => emit(state.copyWith(nickname: v));
  void setAddress(String v) => emit(state.copyWith(address: v));
  void setStartedAt(DateTime v) => emit(state.copyWith(startedAt: v));

  Future<void> submit() async {
    if (state.submitting || state.createdId != null) return;
    if (state.placeError != null) {
      emit(state.copyWith(showErrors: true));
      return;
    }
    if (state.startedAt.isAfter(DateTime.now().add(const Duration(minutes: 5)))) {
      emit(state.copyWith(
        showErrors: true,
        error: 'O início não pode estar no futuro.',
      ));
      return;
    }
    emit(state.copyWith(submitting: true));
    try {
      final outing = await _outings.start(
        type: state.type,
        nickname: state.nickname,
        address: state.address,
        startedAt: state.startedAt,
      );
      emit(state.copyWith(submitting: false, createdId: outing.id));
    } on ActiveOutingExistsException {
      final active = _outings.active;
      // Recover the existing outing instead of creating a second one.
      emit(state.copyWith(submitting: false, createdId: active?.id));
    } catch (e) {
      emit(state.copyWith(
        submitting: false,
        showErrors: true,
        error: 'Não foi possível iniciar o rolê. Tente de novo.',
      ));
    }
  }
}
