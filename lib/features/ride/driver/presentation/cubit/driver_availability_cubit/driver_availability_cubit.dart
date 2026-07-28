import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/constants/wallet_api_constants.dart';
import '../../../../../../core/errors/api_exception.dart';
import '../../../../../../core/models/token_payload.dart';
import '../../../../../../core/network/driver_location_streamer.dart';
import '../../../../../../core/network/ride_socket_service.dart';
import '../../../data/driver_availability_repository.dart';
import 'driver_availability_state.dart';

class DriverAvailabilityCubit extends Cubit<DriverAvailabilityState> {
  DriverAvailabilityCubit(this._repo) : super(const DriverAvailabilityState());

  final DriverAvailabilityRepository _repo;

  Future<void> seed(bool isOnline) async {
    if (isOnline) {
      await RideSocketService.connect(ActiveRole.driver);
      DriverLocationStreamer.start();
    }
    emit(state.copyWith(isOnline: isOnline));
  }

  Future<void> toggle() async {
    if (state.status == DriverAvailabilityStatus.loading) return;
    emit(state.copyWith(
      status: DriverAvailabilityStatus.loading,
      errorMessage: '',
      gatedByBalance: false,
    ));
    try {
      final wasOnline = state.isOnline;
      final isOnline =
          wasOnline ? await _repo.goOffline() : await _repo.goOnline();

      // Ride socket lifecycle: open when the driver goes online, close when they
      // go offline. If connect() fails internally the service itself surfaces
      // a failed/reconnecting status and keeps retrying — the server-side
      // online flag stays as reported above either way. The location
      // streamer is armed/disarmed in lockstep: it sends `driver.location`
      // every 5s while connected (see swagger/epic-03-ride.md §9/§11) and
      // auto-pauses/resumes across any reconnects on its own.
      if (isOnline) {
        await RideSocketService.connect(ActiveRole.driver);
        DriverLocationStreamer.start();
      } else {
        DriverLocationStreamer.stop();
        await RideSocketService.disconnect();
      }

      emit(state.copyWith(
        status: DriverAvailabilityStatus.success,
        isOnline: isOnline,
      ));
    } catch (e) {
      // The wallet gate is the one failure with a fix the driver can act on,
      // so it is flagged separately for a "top up" prompt instead of a toast.
      final gated = e is ApiException &&
          e.code == WalletErrorCodes.insufficientBalance;
      emit(state.copyWith(
        status: DriverAvailabilityStatus.failed,
        errorMessage: e.toString(),
        gatedByBalance: gated,
      ));
    }
  }
}

