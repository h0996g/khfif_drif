// lib/features/auth/presentation/cubit/otp_cubit.dart

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repo/auth_repository.dart';
import 'otp_state.dart';

/// Drives the OTP verification screen.
///
/// Responsibilities:
///  • Maintains the 6-digit input as a [List<String>].
///  • Runs a 60-second resend countdown via Dart [Timer].
///  • Limits resend to 3 times per session.
///  • Tracks consecutive failed attempts; blocks for 10 minutes on the 3rd.
///  • Calls [AuthRepository.verifyOtp] (mock) and emits the appropriate status.
final class OtpCubit extends Cubit<OtpState> {
  OtpCubit(this._repository, {required String phoneNumber})
      : super(OtpState(phoneNumber: phoneNumber)) {
    _startResendTimer();
  }

  final AuthRepository _repository;

  Timer? _resendTimer;
  Timer? _blockTimer;

  // ── Digit input ──────────────────────────────────────────────────────────

  /// Updates [index] in the digit list and clears any inline error.
  void digitChanged(int index, String value) {
    if (state.status == OtpStatus.blocked) return;

    final updated = List<String>.from(state.digits);
    updated[index] = value;

    emit(
      state.copyWith(
        digits: updated,
        status: OtpStatus.idle,
        errorMessage: '',
      ),
    );
  }

  // ── Verify ───────────────────────────────────────────────────────────────

  Future<void> verifyOtp() async {
    if (!state.isComplete || state.status == OtpStatus.verifying) return;

    emit(state.copyWith(status: OtpStatus.verifying, errorMessage: ''));

    try {
      await _repository.verifyOtp(state.otpValue);
      emit(state.copyWith(status: OtpStatus.verified, failedAttempts: 0));
    } catch (_) {
      final newAttempts = state.failedAttempts + 1;

      if (newAttempts >= 3) {
        _startBlockTimer();
        emit(
          state.copyWith(
            status: OtpStatus.blocked,
            failedAttempts: newAttempts,
            blockSecondsRemaining: 600,
            errorMessage: '',
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: OtpStatus.wrongCode,
            failedAttempts: newAttempts,
            errorMessage: 'Incorrect code, try again',
          ),
        );
      }
    }
  }

  // ── Resend ───────────────────────────────────────────────────────────────

  Future<void> resendOtp() async {
    if (!state.canResend) return;

    _resendTimer?.cancel();

    await _repository.sendOtp(state.phoneNumber);

    emit(
      state.copyWith(
        resendCount: state.resendCount + 1,
        secondsRemaining: 60,
        // reset digits and error on resend
        digits: const ['', '', '', '', '', ''],
        failedAttempts: 0,
        status: OtpStatus.idle,
        errorMessage: '',
      ),
    );

    _startResendTimer();
  }

  // ── Timers ───────────────────────────────────────────────────────────────

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
        emit(
          state.copyWith(
            status: OtpStatus.idle,
            blockSecondsRemaining: 0,
            failedAttempts: 0,
            digits: const ['', '', '', '', '', ''],
            errorMessage: '',
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          blockSecondsRemaining: state.blockSecondsRemaining - 1,
        ),
      );
    });
  }

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  Future<void> close() {
    _resendTimer?.cancel();
    _blockTimer?.cancel();
    return super.close();
  }
}
