import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khfif_drif/features/ride/passenger/data/passenger_ride_repository.dart';
import 'package:khfif_drif/features/ride/shared/models/shared_ride_models.dart';

import 'passenger_ride_history_state.dart';

/// Loads the passenger's ride history with infinite-scroll pagination.
///
/// - [loadHistory] resets and fetches the first page, optionally applying a
///   new [filter] (state/serviceType/date range); omit it to reuse the
///   currently active filter (e.g. on pull-to-refresh).
/// - [loadMore] appends the next page under the same active filter; on error
///   it keeps the existing items so the UI can surface a transient snackbar /
///   retry instead of wiping cards.
class PassengerRideHistoryCubit extends Cubit<PassengerRideHistoryState> {
  PassengerRideHistoryCubit(this._repository)
      : super(const PassengerRideHistoryState());

  final PassengerRideRepository _repository;

  static const int _pageSize = 20;

  Future<void> loadHistory({RideHistoryFilter? filter}) async {
    final activeFilter = filter ?? state.filter;
    emit(state.copyWith(
      status: PassengerRideHistoryStatus.loading,
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
        status: PassengerRideHistoryStatus.loaded,
        rides: response.rides,
        currentPage: response.page,
        totalPages: response.totalPages,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PassengerRideHistoryStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || state.hasReachedMax) return;

    emit(state.copyWith(
      status: PassengerRideHistoryStatus.loadingMore,
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
        status: PassengerRideHistoryStatus.loaded,
        rides: [...state.rides, ...response.rides],
        currentPage: response.page,
        totalPages: response.totalPages,
      ));
    } catch (e) {
      // Keep the items already on screen; surface the error transiently.
      emit(state.copyWith(
        status: PassengerRideHistoryStatus.loaded,
        errorMessage: e.toString(),
      ));
    }
  }
}
