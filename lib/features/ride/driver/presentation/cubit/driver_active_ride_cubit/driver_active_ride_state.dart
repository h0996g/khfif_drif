import 'package:equatable/equatable.dart';

import '../../../data/models/driver_ride_models.dart';

enum DriverActiveRideStatus {
  initial,
  loading,
  loaded,
  transitioning,
  noActiveRide,
  cancelled,
  completed,
  actionFailure,
  failure,
}

final class DriverActiveRideState extends Equatable {
  const DriverActiveRideState({
    this.status = DriverActiveRideStatus.initial,
    this.ride,
    this.errorMessage = '',
    this.completedFare,
  });

  final DriverActiveRideStatus status;
  final ActiveDriverRideResponse? ride;
  final String errorMessage;
  final int? completedFare;

  DriverActiveRideState copyWith({
    DriverActiveRideStatus? status,
    ActiveDriverRideResponse? ride,
    String? errorMessage,
    int? completedFare,
  }) =>
      DriverActiveRideState(
        status: status ?? this.status,
        ride: ride ?? this.ride,
        errorMessage: errorMessage ?? this.errorMessage,
        completedFare: completedFare ?? this.completedFare,
      );

  @override
  List<Object?> get props => [status, ride, errorMessage, completedFare];
}
