import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/driver_profile_repository.dart';
import 'driver_profile_state.dart';

class DriverProfileCubit extends Cubit<DriverProfileState> {
  DriverProfileCubit(this._repo) : super(const DriverProfileState());

  final DriverProfileRepository _repo;

  void seed(bool acceptsFemaleOnly) {
    emit(state.copyWith(acceptsFemaleOnly: acceptsFemaleOnly));
  }

  Future<void> setAcceptsFemaleOnly(bool enabled) async {
    if (state.status == DriverProfileStatus.loading) return;
    emit(state.copyWith(
      status: DriverProfileStatus.loading,
      errorMessage: '',
    ));
    try {
      final updated = await _repo.updateProfile(acceptsFemaleOnly: enabled);
      emit(state.copyWith(
        status: DriverProfileStatus.success,
        acceptsFemaleOnly: updated.acceptsFemaleOnly,
        updatedProfile: updated,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DriverProfileStatus.failed,
        errorMessage: e is String ? e : 'Failed to update preference.',
      ));
    }
  }
}
