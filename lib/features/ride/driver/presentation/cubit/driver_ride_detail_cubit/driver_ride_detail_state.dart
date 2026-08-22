import 'package:equatable/equatable.dart';

import '../../../data/models/driver_ride_detail_models.dart';

enum DriverRideDetailStatus { initial, loading, loaded, failure }

final class DriverRideDetailState extends Equatable {
  const DriverRideDetailState({
    this.status = DriverRideDetailStatus.initial,
    this.ride,
    this.errorMessage = '',
  });

  final DriverRideDetailStatus status;
  final DriverRideDetail? ride;
  final String errorMessage;

  DriverRideDetailState copyWith({
    DriverRideDetailStatus? status,
    DriverRideDetail? ride,
    String? errorMessage,
  }) {
    return DriverRideDetailState(
      status: status ?? this.status,
      ride: ride ?? this.ride,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, ride, errorMessage];
}
