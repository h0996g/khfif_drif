import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khfif_drif/features/ride/driver/data/driver_ride_repository.dart';
import 'package:khfif_drif/features/ride/shared/models/shared_ride_models.dart';

import 'driver_ride_history_state.dart';

/// Loads the driver's ride history with infinite-scroll pagination.
///
/// - [loadHistory] resets and fetches the first page, optionally applying a
///   new [filter] (state/serviceType/date range); omit it to reuse the
///   currently active filter (e.g. on pull-to-refresh).
/// - [loadMore] appends the next page under the same active filter; on error
///   it keeps the existing items so the UI can surface a transient snackbar /
///   retry instead of wiping cards.
class DriverRideHistoryCubit extends Cubit<DriverRideHistoryState> {
  DriverRideHistoryCubit(this._repository)
      : super(const DriverRideHistoryState());

  final DriverRideRepository _repository;

  static const int _pageSize = 20;

  Future<void> loadHistory({RideHistoryFilter? filter}) async {
    final activeFilter = filter ?? state.filter;
    emit(state.copyWith(
      status: DriverRideHistoryStatus.loading,
      rides: const [],
      errorMessage: '',
      filter: activeFilter,
    ));
    try {
      final response = await _repository.listHistory(
        page: 0,
        size: _pageSize,
        state: activeFilter.state,
        serviceType: activeFilter.serviceType,
        from: activeFilter.from,
        to: activeFilter.to,
      );
      emit(state.copyWith(
        status: DriverRideHistoryStatus.loaded,
        rides: response.rides,
        currentPage: response.page,
        totalPages: response.totalPages,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DriverRideHistoryStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || state.hasReachedMax) return;

    emit(state.copyWith(
      status: DriverRideHistoryStatus.loadingMore,
      errorMessage: '',
    ));
    try {
      final response = await _repository.listHistory(
        page: state.currentPage + 1,
        size: _pageSize,
        state: state.filter.state,
        serviceType: state.filter.serviceType,
        from: state.filter.from,
        to: state.filter.to,
      );
      emit(state.copyWith(
        status: DriverRideHistoryStatus.loaded,
        rides: [...state.rides, ...response.rides],
        currentPage: response.page,
        totalPages: response.totalPages,
      ));
    } catch (e) {
      // Keep the items already on screen; surface the error transiently.
      emit(state.copyWith(
        status: DriverRideHistoryStatus.loaded,
        errorMessage: e.toString(),
      ));
    }
  }
}
