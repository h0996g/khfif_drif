// lib/features/auth/presentation/cubit/otp_state.dart

/// Overall status of the OTP verification screen.
enum OtpStatus {
  /// Waiting for user input — no error.
  idle,

  /// Verifying the code with the server (or mock).
  verifying,

  /// The submitted code was accepted.
  verified,

  /// The submitted code was wrong (< 3 consecutive failures).
  wrongCode,

  /// 3 consecutive wrong codes — user is blocked for 10 minutes.
  blocked,
}

/// Immutable state for [OtpCubit].
final class OtpState {
  const OtpState({
    this.status = OtpStatus.idle,
    this.digits = const ['', '', '', '', '', ''],
    this.secondsRemaining = 60,
    this.resendCount = 0,
    this.failedAttempts = 0,
    this.blockSecondsRemaining = 0,
    this.errorMessage = '',
    this.phoneNumber = '',
  });

  final OtpStatus status;

  /// The 6 individual digit characters entered by the user.
  final List<String> digits;

  /// Seconds left on the resend countdown (0 = resend allowed).
  final int secondsRemaining;

  /// How many times the user has resent the OTP (max 3).
  final int resendCount;

  /// Consecutive wrong-code attempts (resets on correct code / resend).
  final int failedAttempts;

  /// Seconds remaining on the block countdown (> 0 when [status] == blocked).
  final int blockSecondsRemaining;

  /// Non-empty only when [status] is [OtpStatus.wrongCode].
  final String errorMessage;

  /// The phone number passed from the previous screen.
  final String phoneNumber;

  // ── Derived getters ──────────────────────────────────────────────────────

  /// The full 6-digit OTP the user has entered so far.
  String get otpValue => digits.join();

  /// True when all 6 boxes are filled.
  bool get isComplete => otpValue.length == 6 && !digits.contains('');

  /// True when the resend button should be tappable.
  bool get canResend => secondsRemaining == 0 && resendCount < 3;

  /// Last 4 digits of the raw phone number for the confirmation label.
  String get lastFourDigits => phoneNumber.length >= 4
      ? phoneNumber.substring(phoneNumber.length - 4)
      : phoneNumber;

  OtpState copyWith({
    OtpStatus? status,
    List<String>? digits,
    int? secondsRemaining,
    int? resendCount,
    int? failedAttempts,
    int? blockSecondsRemaining,
    String? errorMessage,
    String? phoneNumber,
  }) =>
      OtpState(
        status: status ?? this.status,
        digits: digits ?? this.digits,
        secondsRemaining: secondsRemaining ?? this.secondsRemaining,
        resendCount: resendCount ?? this.resendCount,
        failedAttempts: failedAttempts ?? this.failedAttempts,
        blockSecondsRemaining:
            blockSecondsRemaining ?? this.blockSecondsRemaining,
        errorMessage: errorMessage ?? this.errorMessage,
        phoneNumber: phoneNumber ?? this.phoneNumber,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OtpState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          digits == other.digits &&
          secondsRemaining == other.secondsRemaining &&
          resendCount == other.resendCount &&
          failedAttempts == other.failedAttempts &&
          blockSecondsRemaining == other.blockSecondsRemaining &&
          errorMessage == other.errorMessage &&
          phoneNumber == other.phoneNumber;

  @override
  int get hashCode =>
      status.hashCode ^
      digits.hashCode ^
      secondsRemaining.hashCode ^
      resendCount.hashCode ^
      failedAttempts.hashCode ^
      blockSecondsRemaining.hashCode ^
      errorMessage.hashCode ^
      phoneNumber.hashCode;
}
