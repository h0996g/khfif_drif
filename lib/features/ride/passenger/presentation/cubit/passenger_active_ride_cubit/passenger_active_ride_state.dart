import 'package:equatable/equatable.dart';

import '../../../../../../features/ride/driver/data/models/ride_socket_event.dart';
import '../../../data/models/passenger_ride_models.dart';

enum PassengerActiveRideStatus {
  loading,
  loaded,
  cancelled,
  completed,
  actionFailure,
  failure,
}

final class PassengerActiveRideState extends Equatable {
  const PassengerActiveRideState({
    this.status = PassengerActiveRideStatus.loading,
    this.ride,
    this.rideState,
    this.driverLat,
    this.driverLng,
    this.errorMessage = '',
  });

  final PassengerActiveRideStatus status;
  final ActiveRideSummary? ride;
  final RideState? rideState;
  final double? driverLat;
  final double? driverLng;
  final String errorMessage;

  PassengerActiveRideState copyWith({
    PassengerActiveRideStatus? status,
    ActiveRideSummary? ride,
    RideState? rideState,
    double? driverLat,
    double? driverLng,
    String? errorMessage,
  }) =>
      PassengerActiveRideState(
        status: status ?? this.status,
        ride: ride ?? this.ride,
        rideState: rideState ?? this.rideState,
        driverLat: driverLat ?? this.driverLat,
        driverLng: driverLng ?? this.driverLng,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props =>
      [status, ride, rideState, driverLat, driverLng, errorMessage];
}
