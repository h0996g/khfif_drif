// lib/features/auth/presentation/cubit/phone_cubit.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/validation_patterns.dart';
import '../../../../../core/utils/phone_formatter.dart';
import '../../../data/repo/auth_repository.dart';
import 'phone_state.dart';

/// Manages state for the phone-entry screen.
///
/// Calls [AuthRepository] directly — no use case layer for the MVP.
final class PhoneCubit extends Cubit<PhoneState> {
  PhoneCubit(this._repository) : super(const PhoneState());

  final AuthRepository _repository;

  /// Called on every keystroke in the phone field.
  void phoneChanged(String value) {
    emit(
      state.copyWith(
        phoneNumber: value,
        isValid: ValidationPatterns.dzPhone.hasMatch(value),
        status: PhoneStatus.initial,
        errorMessage: '',
      ),
    );
  }

  /// Converts the local number to E.164, calls the repository, and
  /// emits [PhoneStatus.success] or [PhoneStatus.failure] accordingly.
  Future<void> sendOtp() async {
    if (!state.isValid) return;

    emit(state.copyWith(status: PhoneStatus.loading));

    try {
      await _repository.sendOtp(PhoneFormatter.toE164(state.phoneNumber));
      emit(state.copyWith(status: PhoneStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: PhoneStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
