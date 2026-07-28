import 'package:equatable/equatable.dart';

import '../../../data/models/driver_ride_models.dart';

enum AvailableRidesStatus {
  initial,
  loading,
  loaded,
  bidding,
  bidSuccess,
  offerAccepted,

  /// The bid was refused with `403 INSUFFICIENT_WALLET_BALANCE` — the driver
  /// needs a top-up, not an error toast.
  gatedByBalance,
  failure,
}

final class AvailableRidesState extends Equatable {
  const AvailableRidesState({
    this.status = AvailableRidesStatus.initial,
    this.rides = const [],
    this.errorMessage = '',
  });

  final AvailableRidesStatus status;
  final List<AvailableRequestCard> rides;
  final String errorMessage;

  AvailableRidesState copyWith({
    AvailableRidesStatus? status,
    List<AvailableRequestCard>? rides,
    String? errorMessage,
  }) =>
      AvailableRidesState(
        status: status ?? this.status,
        rides: rides ?? this.rides,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  @override
  List<Object?> get props => [status, rides, errorMessage];
}
