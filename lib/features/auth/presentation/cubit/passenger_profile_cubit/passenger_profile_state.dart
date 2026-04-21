// lib/features/auth/presentation/cubit/passenger_profile_state.dart

import '../../../data/models/gender.dart';

enum ProfileStatus { idle, submitting, success, failure }

/// Immutable state for the passenger profile form (Step 5).
final class PassengerProfileState {
  const PassengerProfileState({
    this.fullName = '',
    this.gender,
    this.email = '',
    this.status = ProfileStatus.idle,
    this.nameError = '',
    this.emailError = '',
    this.errorMessage = '',
    this.nameTouched = false,
    this.emailTouched = false,
  });

  final String fullName;
  final Gender? gender;
  final String email;
  final ProfileStatus status;

  /// Inline error for the full name field (empty = no error).
  final String nameError;

  /// Inline error for the email field (empty = no error).
  final String emailError;

  /// General submission error message.
  final String errorMessage;

  /// Whether the name field has been touched (to avoid showing errors before
  /// the user has interacted with the field).
  final bool nameTouched;

  /// Whether the email field has been touched.
  final bool emailTouched;

  // ── Derived helpers ────────────────────────────────────────────────────────

  bool get isNameValid => nameError.isEmpty && fullName.trim().length >= 2;
  bool get isGenderSelected => gender != null;
  bool get isEmailValid => email.isEmpty || emailError.isEmpty;

  /// The Continue button is only active when all required fields are valid.
  bool get canSubmit =>
      isNameValid &&
      isGenderSelected &&
      isEmailValid &&
      status != ProfileStatus.submitting;

  PassengerProfileState copyWith({
    String? fullName,
    Gender? gender,
    String? email,
    ProfileStatus? status,
    String? nameError,
    String? emailError,
    String? errorMessage,
    bool? nameTouched,
    bool? emailTouched,
  }) {
    return PassengerProfileState(
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      email: email ?? this.email,
      status: status ?? this.status,
      nameError: nameError ?? this.nameError,
      emailError: emailError ?? this.emailError,
      errorMessage: errorMessage ?? this.errorMessage,
      nameTouched: nameTouched ?? this.nameTouched,
      emailTouched: emailTouched ?? this.emailTouched,
    );
  }
}
