import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/models/token_payload.dart';
import '../../../../../../core/network/ride_socket_service.dart';
import '../../../../driver/data/models/ride_socket_event.dart';
import '../../../data/models/passenger_ride_models.dart';
import '../../../data/passenger_ride_repository.dart';
import 'passenger_active_ride_state.dart';

final class PassengerActiveRideCubit extends Cubit<PassengerActiveRideState> {
  PassengerActiveRideCubit(this._repository)
      : super(const PassengerActiveRideState()) {
    _frameSub = RideSocketService.frameStream.listen(_onFrame);
  }

  final PassengerRideRepository _repository;
  late final StreamSubscription<String> _frameSub;

  Future<void> loadActiveRide() async {
    emit(state.copyWith(
        status: PassengerActiveRideStatus.loading, errorMessage: ''));
    try {
      final result = await _repository.getActiveRide();
      final ride = result.ride;
      if (ride == null) {
        emit(state.copyWith(
            status: PassengerActiveRideStatus.failure,
            errorMessage: 'No active ride found'));
        return;
      }
      await RideSocketService.connect(ActiveRole.passenger);
      emit(state.copyWith(
        status: PassengerActiveRideStatus.loaded,
        ride: ride,
        rideState: RideState.fromWire(ride.state),
        driverLat: ride.driver.currentLat,
        driverLng: ride.driver.currentLng,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PassengerActiveRideStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> cancelRide(CancelReason reason, {String? note}) async {
    final rideId = state.ride?.rideId;
    if (rideId == null) return;
    try {
      await _repository.cancelRide(
        rideId,
        CancelRideRequest(reason: reason.apiValue, note: note),
      );
      emit(state.copyWith(status: PassengerActiveRideStatus.cancelled));
    } catch (e) {
      emit(state.copyWith(
        status: PassengerActiveRideStatus.actionFailure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onFrame(String frame) {
    final event = RideSocketEvent.tryParse(frame);
    switch (event) {
      case RideStateChanged(state: final rideState):
        _handleStateChange(rideState);
      case RideCancelled():
        emit(state.copyWith(status: PassengerActiveRideStatus.cancelled));
      case DriverLocationUpdate(:final lat, :final lng):
        log(
          '[PassengerActiveRide] DriverLocationUpdate — rideState: ${state.rideState}, lat: $lat, lng: $lng',
          name: 'PassengerActiveRideCubit',
        );
        emit(state.copyWith(driverLat: lat, driverLng: lng));
      default:
        break;
    }
  }

  void _handleStateChange(RideState newState) {
    if (newState == RideState.completed) {
      emit(state.copyWith(
          status: PassengerActiveRideStatus.completed, rideState: newState));
    } else if (newState == RideState.cancelled) {
      emit(state.copyWith(
          status: PassengerActiveRideStatus.cancelled, rideState: newState));
    } else {
      emit(state.copyWith(
          status: PassengerActiveRideStatus.loaded, rideState: newState));
    }
  }

  @override
  Future<void> close() {
    _frameSub.cancel();
    return super.close();
  }
}
