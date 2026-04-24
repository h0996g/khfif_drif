import '../../../data/models/gender.dart';

enum ProfileStatus { idle, submitting, success, failure }

final class PassengerProfileState {
  const PassengerProfileState({
    this.fullName = '',
    this.gender,
    this.email = '',
    this.status = ProfileStatus.idle,
    this.nameError = '',
    this.emailError = '',
    this.errorMessage = '',
  });

  final String fullName;
  final Gender? gender;
  final String email;
  final ProfileStatus status;
  final String nameError;
  final String emailError;
  final String errorMessage;

  bool get isNameValid => nameError.isEmpty && fullName.trim().length >= 2;
  bool get isGenderSelected => gender != null;
  bool get isEmailValid => email.isEmpty || emailError.isEmpty;

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
  }) {
    return PassengerProfileState(
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      email: email ?? this.email,
      status: status ?? this.status,
      nameError: nameError ?? this.nameError,
      emailError: emailError ?? this.emailError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
