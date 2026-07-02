import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/models/token_payload.dart';
import '../../../../../../core/network/ride_socket_service.dart';
import '../../../data/models/passenger_ride_models.dart';
import '../../../data/passenger_ride_repository.dart';
import '../../../../../ride/driver/data/models/ride_socket_event.dart';
import 'waiting_offers_state.dart';

final class WaitingOffersCubit extends Cubit<WaitingOffersState> {
  WaitingOffersCubit(this._repository, this._rideRequestId)
      : super(const WaitingOffersState());

  final PassengerRideRepository _repository;
  final String _rideRequestId;
  StreamSubscription<String>? _wsSub;
  StreamSubscription<RideSocketStatus>? _statusSub;

  void startPolling() {
    // On cold start (app reopened on this screen) the socket is not connected,
    // so no offer.created frames arrive. Connect here — idempotent, so it is a
    // no-op when the fresh-request flow already opened the socket.
    RideSocketService.connect(ActiveRole.passenger);
    _poll();
    _wsSub = RideSocketService.frameStream.listen((frame) {
      final event = RideSocketEvent.tryParse(frame);
      if (event is OfferCreated && event.rideRequestId == _rideRequestId) {
        if (kDebugMode) debugPrint('[Passenger] offer.created → offerId=${event.offerId} fare=${event.fare} DZD');
        _poll();
      }
    });
    // REST is truth on (re)connect: reconcile offers once each time the socket
    // comes up, catching any bid that landed while it was down.
    _statusSub = RideSocketService.statusStream.listen((status) {
      if (status == RideSocketStatus.connected) _poll();
    });
  }

  Future<void> _poll() async {
    if (state.acceptStatus == AcceptStatus.success ||
        state.cancelStatus == CancelStatus.loading ||
        state.cancelStatus == CancelStatus.success) {
      return;
    }
    try {
      final result = await _repository.listOffers(_rideRequestId);
      final active = result.offers.where((o) => o.status == 'ACTIVE').toList();
      final phase = active.isEmpty ? RideRequestPhase.requested : RideRequestPhase.negotiating;
      emit(state.copyWith(offers: active, rideRequestPhase: phase));
    } catch (_) {
      // silently skip failed polls; show last known offers
    }
  }

  void removeOffer(String offerId) {
    final remaining = state.offers.where((o) => o.offerId != offerId).toList();
    final phase = remaining.isEmpty
        ? RideRequestPhase.requested
        : RideRequestPhase.negotiating;
    emit(state.copyWith(offers: remaining, rideRequestPhase: phase));
  }

  Future<void> acceptOffer(String offerId) async {
    emit(state.copyWith(acceptStatus: AcceptStatus.loading));
    try {
      await _repository.acceptOffer(_rideRequestId, offerId);
      _wsSub?.cancel();
      _statusSub?.cancel();
      emit(state.copyWith(
        acceptStatus: AcceptStatus.success,
        rideRequestPhase: RideRequestPhase.accepted,
      ));
    } catch (e) {
      emit(state.copyWith(
        acceptStatus: AcceptStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> refuseOffer(String offerId) async {
    emit(state.copyWith(refuseStatus: RefuseStatus.loading));
    try {
      await _repository.refuseOffer(_rideRequestId, offerId);
      final remaining =
          state.offers.where((o) => o.offerId != offerId).toList();
      final phase = remaining.isEmpty ? RideRequestPhase.requested : RideRequestPhase.negotiating;
      emit(state.copyWith(
        refuseStatus: RefuseStatus.success,
        offers: remaining,
        rideRequestPhase: phase,
      ));
    } catch (e) {
      emit(state.copyWith(
        refuseStatus: RefuseStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> cancelRide(CancelReason reason, {String? note}) async {
    emit(state.copyWith(cancelStatus: CancelStatus.loading));
    try {
      await _repository.cancelRide(
        _rideRequestId,
        CancelRideRequest(reason: reason.apiValue, note: note),
      );
      _wsSub?.cancel();
      _statusSub?.cancel();
      emit(state.copyWith(
        cancelStatus: CancelStatus.success,
        rideRequestPhase: RideRequestPhase.cancelled,
      ));
    } catch (e) {
      emit(state.copyWith(
        cancelStatus: CancelStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  @override
  Future<void> close() {
    _wsSub?.cancel();
    _statusSub?.cancel();
    return super.close();
  }
}
