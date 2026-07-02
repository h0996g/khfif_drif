import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/network/ride_socket_service.dart';
import '../../../data/driver_ride_repository.dart';
import '../../../data/models/driver_ride_models.dart';
import '../../../data/models/ride_socket_event.dart';
import 'driver_active_ride_state.dart';

final class DriverActiveRideCubit extends Cubit<DriverActiveRideState> {
  DriverActiveRideCubit(this._repository)
      : super(const DriverActiveRideState()) {
    _frameSub = RideSocketService.frameStream.listen(_onFrame);
  }

  final DriverRideRepository _repository;
  late final StreamSubscription<String> _frameSub;

  void _onFrame(String frame) {
    final event = RideSocketEvent.tryParse(frame);
    switch (event) {
      case RideStateChanged():
        loadActiveRide();
      case RideCancelled():
        emit(state.copyWith(status: DriverActiveRideStatus.cancelled));
      default:
        break;
    }
  }

  Future<void> loadActiveRide() async {
    emit(state.copyWith(
        status: DriverActiveRideStatus.loading, errorMessage: ''));
    try {
      final ride = await _repository.getActiveRide();
      if (ride == null) {
        emit(state.copyWith(status: DriverActiveRideStatus.noActiveRide));
      } else {
        emit(state.copyWith(status: DriverActiveRideStatus.loaded, ride: ride));
      }
    } catch (e) {
      emit(state.copyWith(
        status: DriverActiveRideStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> markArrived() async {
    final rideId = state.ride?.rideId;
    if (rideId == null) return;
    emit(state.copyWith(status: DriverActiveRideStatus.transitioning));
    try {
      await _repository.markArrived(rideId);
      await loadActiveRide();
    } catch (e) {
      emit(state.copyWith(
        status: DriverActiveRideStatus.actionFailure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> startRide() async {
    final rideId = state.ride?.rideId;
    if (rideId == null) return;
    emit(state.copyWith(status: DriverActiveRideStatus.transitioning));
    try {
      await _repository.startRide(rideId);
      await loadActiveRide();
    } catch (e) {
      emit(state.copyWith(
        status: DriverActiveRideStatus.actionFailure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> completeRide() async {
    final rideId = state.ride?.rideId;
    if (rideId == null) return;
    emit(state.copyWith(status: DriverActiveRideStatus.transitioning));
    try {
      final response = await _repository.completeRide(rideId);
      emit(state.copyWith(
        status: DriverActiveRideStatus.completed,
        completedFare: response.finalFare,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DriverActiveRideStatus.actionFailure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> cancelRide(CancelReason reason, {String? note}) async {
    final rideId = state.ride?.rideId;
    if (rideId == null) return;
    emit(state.copyWith(status: DriverActiveRideStatus.transitioning));
    try {
      await _repository.cancelRide(
        rideId,
        DriverCancelRequest(reason: reason.apiValue, note: note),
      );
      await loadActiveRide();
    } catch (e) {
      emit(state.copyWith(
        status: DriverActiveRideStatus.actionFailure,
        errorMessage: e.toString(),
      ));
    }
  }

  @override
  Future<void> close() {
    _frameSub.cancel();
    return super.close();
  }
}
