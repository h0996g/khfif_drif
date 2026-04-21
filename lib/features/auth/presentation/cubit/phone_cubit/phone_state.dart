// lib/features/auth/presentation/cubit/phone_state.dart

/// Status lifecycle for the phone-entry screen.
enum PhoneStatus {
  initial,
  loading,
  success,
  failure,
}

/// Immutable state for [PhoneCubit].
///
/// Uses the concrete class + status enum pattern — no sealed classes, no freezed.
/// All fields have default values so the constructor is always const.
final class PhoneState {
  const PhoneState({
    this.status = PhoneStatus.initial,
    this.phoneNumber = '',
    this.isValid = false,
    this.errorMessage = '',
  });

  final PhoneStatus status;

  /// Raw local number as the user typed it (e.g. "0661234567").
  final String phoneNumber;

  /// True when [phoneNumber] matches the Algerian mobile regex.
  final bool isValid;

  /// Non-empty on [PhoneStatus.failure].
  final String errorMessage;

  PhoneState copyWith({
    PhoneStatus? status,
    String? phoneNumber,
    bool? isValid,
    String? errorMessage,
  }) =>
      PhoneState(
        status: status ?? this.status,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        isValid: isValid ?? this.isValid,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  String toString() => 'PhoneState('
      'status: $status, '
      'phoneNumber: $phoneNumber, '
      'isValid: $isValid, '
      'errorMessage: $errorMessage)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhoneState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          phoneNumber == other.phoneNumber &&
          isValid == other.isValid &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode =>
      status.hashCode ^
      phoneNumber.hashCode ^
      isValid.hashCode ^
      errorMessage.hashCode;
}
