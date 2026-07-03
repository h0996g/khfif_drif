import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/models/token_payload.dart';
import '../../../../../../core/network/ride_socket_service.dart';
import '../../../data/models/passenger_ride_models.dart';
import '../../../data/passenger_ride_repository.dart';
import 'ride_request_state.dart';

final class RideRequestCubit extends Cubit<RideRequestState> {
  RideRequestCubit(this._repository) : super(const RideRequestState());

  final PassengerRideRepository _repository;

  void setServiceType(ServiceType value) {
    // If the current vehicle category isn't available for the new service
    // type (e.g. motorcycle under Delivery, van under Ride), fall back to car.
    final validCategories = value.availableCategories;
    final newCategory = validCategories.contains(state.vehicleCategory)
        ? state.vehicleCategory
        : VehicleCategory.car;
    emit(state.copyWith(serviceType: value, vehicleCategory: newCategory));
  }

  void setVehicleCategory(VehicleCategory value) =>
      emit(state.copyWith(vehicleCategory: value));

  void setFemaleOnly(bool value) => emit(state.copyWith(femaleOnly: value));

  Future<void> submitRide(CreateRideRequest request) async {
    emit(state.copyWith(status: RideRequestStatus.loading, errorMessage: ''));
    try {
      final response = await _repository.createRide(request);
      await RideSocketService.connect(ActiveRole.passenger);
      if (kDebugMode) debugPrint('[Passenger] WS connected for ride ${response.rideRequestId}');
      emit(state.copyWith(
        status: RideRequestStatus.success,
        createRideResponse: response,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: RideRequestStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
