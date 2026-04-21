// lib/features/auth/presentation/cubit/passenger_profile_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/validators.dart';
import '../../../data/models/gender.dart';
import '../../../data/repo/auth_repository.dart';
import 'passenger_profile_state.dart';

/// Drives the Passenger Profile screen (Step 5).
///
/// Validates Full Name (letters-only, min 2 chars), Gender (required),
/// and Email (optional, basic format). Calls [AuthRepository.savePassengerProfile]
/// on submit and emits [ProfileStatus.success] to trigger navigation.
final class PassengerProfileCubit extends Cubit<PassengerProfileState> {
  PassengerProfileCubit(this._repository)
      : super(const PassengerProfileState());

  final AuthRepository _repository;

  // ── Name ──────────────────────────────────────────────────────────────────

  void nameChanged(String value) {
    final trimmed = value.trim();
    final error = Validators.name(trimmed);
    emit(state.copyWith(
      fullName: value,
      nameError: error,
      nameTouched: true,
      status: ProfileStatus.idle,
      errorMessage: '',
    ));
  }

  void nameFocusLost() {
    if (!state.nameTouched) return;
    emit(state.copyWith(nameError: Validators.name(state.fullName.trim())));
  }

  // ── Gender ────────────────────────────────────────────────────────────────

  void genderChanged(Gender gender) {
    emit(state.copyWith(
        gender: gender, status: ProfileStatus.idle, errorMessage: ''));
  }

  // ── Email ─────────────────────────────────────────────────────────────────

  void emailChanged(String value) {
    final error = Validators.email(value.trim());
    emit(state.copyWith(
      email: value,
      emailError: error,
      emailTouched: true,
      status: ProfileStatus.idle,
      errorMessage: '',
    ));
  }

  void emailFocusLost() {
    if (!state.emailTouched || state.email.isEmpty) return;
    emit(state.copyWith(emailError: Validators.email(state.email.trim())));
  }

  // ── Submit ────────────────────────────────────────────────────────────────

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
