// lib/features/auth/presentation/cubit/passenger_profile_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

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
    final error = _validateName(trimmed);
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
    final error = _validateName(state.fullName.trim());
    emit(state.copyWith(nameError: error));
  }

  String _validateName(String value) {
    if (value.isEmpty) return 'Full name is required';
    if (value.length < 2) return 'Name must be at least 2 characters';
    // Only letters (and spaces between words) are allowed.
    if (!RegExp(r"^[a-zA-ZÀ-ÿ]+([ '-][a-zA-ZÀ-ÿ]+)*$").hasMatch(value)) {
      return 'Name must contain letters only';
    }
    return '';
  }

  // ── Gender ────────────────────────────────────────────────────────────────

  void genderChanged(Gender gender) {
    emit(state.copyWith(
        gender: gender, status: ProfileStatus.idle, errorMessage: ''));
  }

  // ── Email ─────────────────────────────────────────────────────────────────

  void emailChanged(String value) {
    final error = value.isEmpty ? '' : _validateEmail(value.trim());
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
    final error = _validateEmail(state.email.trim());
    emit(state.copyWith(emailError: error));
  }

  String _validateEmail(String value) {
    final pattern =
        RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
    if (!pattern.hasMatch(value)) return 'Enter a valid email address';
    return '';
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
