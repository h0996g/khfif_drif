import 'package:equatable/equatable.dart';

enum DriverAvailabilityStatus { init, loading, success, failed }

final class DriverAvailabilityState extends Equatable {
  const DriverAvailabilityState({
    this.status = DriverAvailabilityStatus.init,
    this.isOnline = false,
    this.errorMessage = '',
    this.gatedByBalance = false,
  });

  final DriverAvailabilityStatus status;
  final bool isOnline;
  final String errorMessage;

  /// The last go-online attempt was refused with
  /// `403 INSUFFICIENT_WALLET_BALANCE` — prompt for a top-up rather than
  /// showing the raw message.
  final bool gatedByBalance;

  DriverAvailabilityState copyWith({
    DriverAvailabilityStatus? status,
    bool? isOnline,
    String? errorMessage,
    bool? gatedByBalance,
  }) {
    return DriverAvailabilityState(
      status: status ?? this.status,
      isOnline: isOnline ?? this.isOnline,
      errorMessage: errorMessage ?? this.errorMessage,
      gatedByBalance: gatedByBalance ?? this.gatedByBalance,
    );
  }

  @override
  List<Object?> get props => [status, isOnline, errorMessage, gatedByBalance];
}
