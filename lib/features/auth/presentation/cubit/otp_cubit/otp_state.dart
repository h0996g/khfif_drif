import 'package:equatable/equatable.dart';

import '../../../../../core/constants/app_constants.dart';

enum OtpStatus { idle, verifying, verified, wrongCode, blocked }

final class OtpState extends Equatable {
  const OtpState({
    required this.phoneNumber,
    this.status = OtpStatus.idle,
    this.digits = const ['', '', '', '', '', ''],
    this.secondsRemaining = AppConstants.otpResendCooldownSecs,
    this.resendCount = 0,
    this.failedAttempts = 0,
    this.blockSecondsRemaining = 0,
    this.errorMessage = '',
  });

  final String phoneNumber;
  final OtpStatus status;
  final List<String> digits;
  final int secondsRemaining;
  final int resendCount;
  final int failedAttempts;
  final int blockSecondsRemaining;
  final String errorMessage;

  String get otpValue => digits.join();
  bool get isComplete => digits.length == 6 && !digits.contains('');
  bool get canResend =>
      secondsRemaining == 0 &&
      resendCount < AppConstants.otpMaxResendCount &&
      blockSecondsRemaining == 0;
  String get lastFourDigits => phoneNumber.length >= 4
      ? phoneNumber.substring(phoneNumber.length - 4)
      : phoneNumber;

  OtpState copyWith({
    String? phoneNumber,
    OtpStatus? status,
    List<String>? digits,
    int? secondsRemaining,
    int? resendCount,
    int? failedAttempts,
    int? blockSecondsRemaining,
    String? errorMessage,
  }) =>
      OtpState(
        phoneNumber: phoneNumber ?? this.phoneNumber,
        status: status ?? this.status,
        digits: digits ?? this.digits,
        secondsRemaining: secondsRemaining ?? this.secondsRemaining,
        resendCount: resendCount ?? this.resendCount,
        failedAttempts: failedAttempts ?? this.failedAttempts,
        blockSecondsRemaining:
            blockSecondsRemaining ?? this.blockSecondsRemaining,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [
        phoneNumber,
        status,
        digits,
        secondsRemaining,
        resendCount,
        failedAttempts,
        blockSecondsRemaining,
        errorMessage,
      ];
}
