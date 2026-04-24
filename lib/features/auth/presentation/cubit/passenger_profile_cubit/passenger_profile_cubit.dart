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
      nameError: Validators.name(value.trim()),
      status: ProfileStatus.initial,
      errorMessage: '',
    ));
  }

  void genderChanged(Gender gender) {
    emit(state.copyWith(
      gender: gender,
      status: ProfileStatus.initial,
      errorMessage: '',
    ));
  }

  void emailChanged(String value) {
    emit(state.copyWith(
      emailError: Validators.email(value.trim()),
      status: ProfileStatus.initial,
      errorMessage: '',
    ));
  }

  Future<void> submit({required String fullName, required String email}) async {
    if (!state.canSubmit) return;

    emit(state.copyWith(status: ProfileStatus.loading, errorMessage: ''));

    try {
      await _repository.savePassengerProfile(
        fullName: fullName.trim(),
        gender: state.gender!,
        email: email.trim().isEmpty ? null : email.trim(),
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
