import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../data/repo/auth_repository.dart';
import 'otp_state.dart';

final class OtpCubit extends Cubit<OtpState> {
  OtpCubit(this._repository, {required String phoneNumber})
      : super(OtpState(phoneNumber: phoneNumber)) {
    _startResendTimer();
  }

  final AuthRepository _repository;
  Timer? _resendTimer;
  Timer? _blockTimer;
  int _failedAttempts = 0;

  void otpChanged(String value) {
    if (state.status == OtpStatus.blocked) return;
    emit(state.copyWith(otpValue: value, errorMessage: ''));
  }

  Future<void> verifyOtp() async {
    if (!state.isComplete || state.status == OtpStatus.loading) return;

    emit(state.copyWith(status: OtpStatus.loading, errorMessage: ''));

    try {
      await _repository.verifyOtp(state.otpValue);
      _failedAttempts = 0;
      emit(state.copyWith(status: OtpStatus.success));
    } catch (_) {
      _failedAttempts++;
      if (_failedAttempts >= AppConstants.otpMaxFailedAttempts) {
        _startBlockTimer();
        emit(state.copyWith(
          status: OtpStatus.blocked,
          blockSecondsRemaining: AppConstants.otpBlockDurationSecs,
          errorMessage: '',
        ));
      } else {
        emit(state.copyWith(
          status: OtpStatus.failure,
          errorMessage: 'Incorrect code, try again',
        ));
      }
    }
  }

  Future<void> resendOtp() async {
    if (!state.canResend) return;
    _resendTimer?.cancel();

    try {
      await _repository.sendOtp(state.phoneNumber);
      _failedAttempts = 0;
      emit(state.copyWith(
        resendCount: state.resendCount + 1,
        secondsRemaining: AppConstants.otpResendCooldownSecs,
        otpValue: '',
        status: OtpStatus.initial,
        errorMessage: '',
      ));
      _startResendTimer();
    } catch (e) {
      emit(state.copyWith(
        status: OtpStatus.failure,
        errorMessage:
            e is String ? e : 'Could not resend OTP. Please try again.',
      ));
    }
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.secondsRemaining <= 0) {
        _resendTimer?.cancel();
        return;
      }
      emit(state.copyWith(secondsRemaining: state.secondsRemaining - 1));
    });
  }

  void _startBlockTimer() {
    _blockTimer?.cancel();
    _blockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.blockSecondsRemaining <= 1) {
        _blockTimer?.cancel();
        _failedAttempts = 0;
        emit(state.copyWith(
          status: OtpStatus.initial,
          blockSecondsRemaining: 0,
          otpValue: '',
          errorMessage: '',
        ));
        return;
      }
      emit(state.copyWith(
          blockSecondsRemaining: state.blockSecondsRemaining - 1));
    });
  }

  @override
  Future<void> close() {
    _resendTimer?.cancel();
    _blockTimer?.cancel();
    return super.close();
  }
}
