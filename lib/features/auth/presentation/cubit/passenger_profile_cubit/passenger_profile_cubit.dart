import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/validators.dart';
import '../../../data/models/gender.dart';
import '../../../data/repo/auth_repository.dart';
import 'passenger_profile_state.dart';

final class PassengerProfileCubit extends Cubit<PassengerProfileState> {
  PassengerProfileCubit(this._repository)
      : super(const PassengerProfileState());

  final AuthRepository _repository;

  void nameChanged(String value) {
    emit(state.copyWith(
      fullName: value,
      nameError: Validators.name(value.trim()),
      status: ProfileStatus.idle,
      errorMessage: '',
    ));
  }

  void genderChanged(Gender gender) {
    emit(state.copyWith(
      gender: gender,
      status: ProfileStatus.idle,
      errorMessage: '',
    ));
  }

  void emailChanged(String value) {
    emit(state.copyWith(
      email: value,
      emailError: Validators.email(value.trim()),
      status: ProfileStatus.idle,
      errorMessage: '',
    ));
  }

  Future<void> submit() async {
    if (!state.canSubmit) return;

    emit(state.copyWith(status: ProfileStatus.submitting, errorMessage: ''));

    try {
      await _repository.savePassengerProfile(
        fullName: state.fullName.trim(),
        gender: state.gender!,
        email: state.email.trim().isEmpty ? null : state.email.trim(),
      );
      emit(state.copyWith(status: ProfileStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileStatus.failure,
        errorMessage:
            e is String ? e : 'Something went wrong. Please try again.',
      ));
    }
  }
}
