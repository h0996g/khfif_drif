import 'package:equatable/equatable.dart';
import 'package:khfif_drif/features/ride/driver/data/models/driver_ride_history_models.dart';
import 'package:khfif_drif/features/ride/shared/models/shared_ride_models.dart';

enum DriverRideHistoryStatus { initial, loading, loaded, loadingMore, failure }

final class DriverRideHistoryState extends Equatable {
  const DriverRideHistoryState({
    this.status = DriverRideHistoryStatus.initial,
    this.rides = const [],
    this.currentPage = -1,
    this.totalPages = 0,
    this.errorMessage = '',
    this.filter = RideHistoryFilter.empty,
  });

  final DriverRideHistoryStatus status;
  final List<DriverRideHistoryItem> rides;
  final int currentPage;
  final int totalPages;
  final String errorMessage;
  final RideHistoryFilter filter;

  bool get isLoading => status == DriverRideHistoryStatus.loading;
  bool get isLoadingMore => status == DriverRideHistoryStatus.loadingMore;

  /// Whether the last page has been fetched. Guards against `totalPages == 0`
  /// (e.g. an empty history) so we never try to paginate into nothing.
  bool get hasReachedMax {
    if (totalPages <= 0) return true;
    return currentPage + 1 >= totalPages;
  }

  DriverRideHistoryState copyWith({
    DriverRideHistoryStatus? status,
    List<DriverRideHistoryItem>? rides,
    int? currentPage,
    int? totalPages,
    String? errorMessage,
    RideHistoryFilter? filter,
  }) {
    return DriverRideHistoryState(
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
