import 'package:equatable/equatable.dart';
import 'package:khfif_drif/features/ride/passenger/data/models/passenger_ride_history_models.dart';
import 'package:khfif_drif/features/ride/shared/models/shared_ride_models.dart';

enum PassengerRideHistoryStatus {
  initial,
  loading,
  loaded,
  loadingMore,
  failure,
}

final class PassengerRideHistoryState extends Equatable {
  const PassengerRideHistoryState({
    this.status = PassengerRideHistoryStatus.initial,
    this.rides = const [],
    this.currentPage = -1,
    this.totalPages = 0,
    this.errorMessage = '',
    this.filter = RideHistoryFilter.empty,
  });

  final PassengerRideHistoryStatus status;
  final List<PassengerRideHistoryItem> rides;
  final int currentPage;
  final int totalPages;
  final String errorMessage;
  final RideHistoryFilter filter;

  bool get isLoading => status == PassengerRideHistoryStatus.loading;
  bool get isLoadingMore => status == PassengerRideHistoryStatus.loadingMore;

  /// Whether the last page has been fetched. Guards against `totalPages == 0`
  /// (e.g. an empty history) so we never try to paginate into nothing.
  bool get hasReachedMax {
    if (totalPages <= 0) return true;
    return currentPage + 1 >= totalPages;
  }

  PassengerRideHistoryState copyWith({
    PassengerRideHistoryStatus? status,
    List<PassengerRideHistoryItem>? rides,
    int? currentPage,
    int? totalPages,
    String? errorMessage,
    RideHistoryFilter? filter,
  }) {
    return PassengerRideHistoryState(
      status: status ?? this.status,
      rides: rides ?? this.rides,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      errorMessage: errorMessage ?? this.errorMessage,
      filter: filter ?? this.filter,
    );
  }

  @override
  List<Object?> get props =>
      [status, rides, currentPage, totalPages, errorMessage, filter];
}
