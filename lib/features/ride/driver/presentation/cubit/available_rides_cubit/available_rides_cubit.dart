import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:khfif_drif/core/widgets/app_toast.dart';

import '../../../../../../core/constants/wallet_api_constants.dart';
import '../../../../../../core/errors/api_exception.dart';
import '../../../../../../core/network/ride_socket_service.dart';
import '../../../data/driver_ride_repository.dart';
import '../../../data/models/driver_ride_models.dart';
import '../../../data/models/ride_socket_event.dart';
import 'available_rides_state.dart';

final class AvailableRidesCubit extends Cubit<AvailableRidesState> {
  AvailableRidesCubit(this._repository) : super(const AvailableRidesState()) {
    _frameSub = RideSocketService.frameStream.listen(_onFrame);
    _statusSub = RideSocketService.statusStream.listen(_onStatus);
    // The socket may already be live when this cubit mounts (e.g. the driver was
    // online before navigating here) — seed straight away so we don't wait for
    // the next connect event.
    if (RideSocketService.status == RideSocketStatus.connected) {
      loadAvailableRides();
    }
  }

  final DriverRideRepository _repository;
  late final StreamSubscription<String> _frameSub;
  late final StreamSubscription<RideSocketStatus> _statusSub;

  Future<void> loadAvailableRides() async {
    emit(
        state.copyWith(status: AvailableRidesStatus.loading, errorMessage: ''));
    try {
      final response = await _repository.listAvailableRides();
      emit(state.copyWith(
        status: AvailableRidesStatus.loaded,
        rides: response.requests,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AvailableRidesStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> submitBid(String rideRequestId, int fare) async {
    emit(
        state.copyWith(status: AvailableRidesStatus.bidding, errorMessage: ''));
    try {
      await _repository.submitBid(rideRequestId, fare);
      emit(state.copyWith(status: AvailableRidesStatus.bidSuccess));
    } catch (e) {
      // The wallet gate blocks bidding just as it blocks going online. It has
      // a concrete fix, so it is surfaced as a prompt rather than a raw toast.
      final gated =
          e is ApiException && e.code == WalletErrorCodes.insufficientBalance;
      if (!gated) AppToast.error(e.toString());
      emit(state.copyWith(
        status: gated
            ? AvailableRidesStatus.gatedByBalance
            : AvailableRidesStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  // REST is truth, WS is hints: reconcile against REST on every (re)connect, then
  // apply the live broadcast deltas on top.
  void _onStatus(RideSocketStatus status) {
    if (status == RideSocketStatus.connected) loadAvailableRides();
  }

  void _onFrame(String frame) {
    final event = RideSocketEvent.tryParse(frame);
    switch (event) {
      case RideBroadcast(:final request):
        _upsertRide(request);
      case RideBroadcastCancelled(:final rideRequestId):
        _removeRide(rideRequestId);
      case OfferAccepted(:final rideRequestId):
        // The driver's bid was accepted — drop this card so it can't resurface
        // (e.g. after the ride is later cancelled and the driver returns home).
        // The cubit is shell-scoped, so the list otherwise persists in memory.
        final rides = state.rides
            .where((r) => r.rideRequestId != rideRequestId)
            .toList();
        emit(state.copyWith(
          status: AvailableRidesStatus.offerAccepted,
          rides: rides,
        ));
      default:
        break;
    }
  }

  // Dedupe by rideRequestId: the re-broadcast sweeper re-emits the same request
  // as the cohort grows, so replace an existing card rather than appending.
  void _upsertRide(AvailableRequestCard request) {
    final rides = List<AvailableRequestCard>.from(state.rides);
    final index =
        rides.indexWhere((r) => r.rideRequestId == request.rideRequestId);
    if (index >= 0) {
      rides[index] = request;
    } else {
      rides.add(request);
    }
    emit(state.copyWith(status: AvailableRidesStatus.loaded, rides: rides));
  }

  void ignoreRide(String rideRequestId) => _removeRide(rideRequestId);

  void _removeRide(String rideRequestId) {
    final rides =
        state.rides.where((r) => r.rideRequestId != rideRequestId).toList();
    emit(state.copyWith(status: AvailableRidesStatus.loaded, rides: rides));
  }

  @override
  Future<void> close() {
    _frameSub.cancel();
    _statusSub.cancel();
    return super.close();
  }
}
