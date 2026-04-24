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

  static const _emptyDigits = ['', '', '', '', '', ''];

  void digitChanged(int index, String value) {
    if (state.status == OtpStatus.blocked) return;
    final updated = List<String>.from(state.digits)..[index] = value;
    emit(state.copyWith(digits: updated, status: OtpStatus.idle, errorMessage: ''));
  }

  Future<void> verifyOtp() async {
    if (!state.isComplete || state.status == OtpStatus.verifying) return;

    emit(state.copyWith(status: OtpStatus.verifying, errorMessage: ''));

    try {
      await _repository.verifyOtp(state.otpValue);
      emit(state.copyWith(status: OtpStatus.verified, failedAttempts: 0));
    } catch (_) {
      final attempts = state.failedAttempts + 1;
      if (attempts >= AppConstants.otpMaxFailedAttempts) {
        _startBlockTimer();
        emit(state.copyWith(
          status: OtpStatus.blocked,
          failedAttempts: attempts,
          blockSecondsRemaining: AppConstants.otpBlockDurationSecs,
          errorMessage: '',
        ));
      } else {
        emit(state.copyWith(
          status: OtpStatus.wrongCode,
          failedAttempts: attempts,
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
      emit(state.copyWith(
        resendCount: state.resendCount + 1,
        secondsRemaining: AppConstants.otpResendCooldownSecs,
        digits: _emptyDigits,
        failedAttempts: 0,
        status: OtpStatus.idle,
        errorMessage: '',
      ));
      _startResendTimer();
    } catch (e) {
      emit(state.copyWith(
        status: OtpStatus.wrongCode,
        errorMessage: e is String ? e : 'Could not resend OTP. Please try again.',
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
        emit(state.copyWith(
          status: OtpStatus.idle,
          blockSecondsRemaining: 0,
          failedAttempts: 0,
          digits: _emptyDigits,
          errorMessage: '',
        ));
        return;
      }
      emit(state.copyWith(blockSecondsRemaining: state.blockSecondsRemaining - 1));
    });
  }

  @override
  Future<void> close() {
    _resendTimer?.cancel();
    _blockTimer?.cancel();
    return super.close();
  }
}
