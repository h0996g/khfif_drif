import 'package:equatable/equatable.dart';

import '../../../../../core/constants/app_constants.dart';

enum OtpStatus { initial, loading, success, failure, blocked }

final class OtpState extends Equatable {
  const OtpState({
    required this.phoneNumber,
    this.status = OtpStatus.initial,
    this.otpValue = '',
    this.secondsRemaining = AppConstants.otpResendCooldownSecs,
    this.resendCount = 0,
    this.blockSecondsRemaining = 0,
    this.errorMessage = '',
  });

  final String phoneNumber;
  final OtpStatus status;
  final String otpValue;
  final int secondsRemaining;
  final int resendCount;
  final int blockSecondsRemaining;
  final String errorMessage;

  bool get isComplete => otpValue.length == 6;
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
    String? otpValue,
    int? secondsRemaining,
    int? resendCount,
    int? blockSecondsRemaining,
    String? errorMessage,
  }) =>
      OtpState(
        phoneNumber: phoneNumber ?? this.phoneNumber,
        status: status ?? this.status,
        otpValue: otpValue ?? this.otpValue,
        secondsRemaining: secondsRemaining ?? this.secondsRemaining,
        resendCount: resendCount ?? this.resendCount,
        blockSecondsRemaining:
            blockSecondsRemaining ?? this.blockSecondsRemaining,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [
        phoneNumber,
        status,
        otpValue,
        secondsRemaining,
        resendCount,
        blockSecondsRemaining,
        errorMessage,
      ];
}
