import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/driver_ride_repository.dart';
import 'driver_ride_detail_state.dart';

/// Loads the full detail of a single past ride.
class DriverRideDetailCubit extends Cubit<DriverRideDetailState> {
  DriverRideDetailCubit(
    this._repository, {
    required String rideId,
  })  : _rideId = rideId,
        super(const DriverRideDetailState());

  final DriverRideRepository _repository;
  final String _rideId;

  Future<void> load() async {
    emit(state.copyWith(
      status: DriverRideDetailStatus.loading,
      errorMessage: '',
    ));
    try {
      final ride = await _repository.getRideDetail(_rideId);
      emit(state.copyWith(status: DriverRideDetailStatus.loaded, ride: ride));
    } catch (e) {
      emit(state.copyWith(
        status: DriverRideDetailStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
