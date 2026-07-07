import '../../../../core/constants/ride_api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../shared/utils/date_formatter.dart';
import 'models/passenger_ride_history_models.dart';
import 'models/passenger_ride_models.dart';

final class PassengerRideRepository {
  const PassengerRideRepository();

  Future<CreateRideResponse> createRide(CreateRideRequest request) async {
    final response = await DioClient.post(
      path: PassengerRideApiConstants.create,
      data: request.toJson(),
    );
    return CreateRideResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<OfferListResponse> listOffers(String rideRequestId) async {
    final response = await DioClient.get(
      path: PassengerRideApiConstants.offers(rideRequestId),
    );
    return OfferListResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AcceptOfferResponse> acceptOffer(
    String rideRequestId,
    String offerId,
  ) async {
    final response = await DioClient.post(
      path: PassengerRideApiConstants.acceptOffer(rideRequestId, offerId),
      data: <String, dynamic>{},
    );
    return AcceptOfferResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<RefuseOfferResponse> refuseOffer(
    String rideRequestId,
    String offerId,
  ) async {
    final response = await DioClient.post(
      path: PassengerRideApiConstants.refuseOffer(rideRequestId, offerId),
      data: <String, dynamic>{},
    );
    return RefuseOfferResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CancelRideResponse> cancelRide(
    String rideRequestId,
    CancelRideRequest request,
  ) async {
    final response = await DioClient.post(
      path: PassengerRideApiConstants.cancel(rideRequestId),
      data: request.toJson(),
    );
    return CancelRideResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ActiveRideResponse> getActiveRide() async {
    final response = await DioClient.get(path: PassengerRideApiConstants.active);
    return ActiveRideResponse.fromJson(response.data as Map<String, dynamic>);
  }

  /// Paginated ride history (completed + cancelled rides, newest first).
  Future<PassengerRideHistoryResponse> listHistory({
    int page = 0,
    int size = 20,
    RideOutcome? state,
    ServiceType? serviceType,
    DateTime? from,
    DateTime? to,
  }) async {
    final response = await DioClient.get(
      path: PassengerRideApiConstants.history,
      queryParameters: {
        'page': page,
        'size': size,
        if (state != null) 'state': state.apiValue,
        if (serviceType != null) 'serviceType': serviceType.toJson(),
        if (from != null) 'from': toHistoryFilterDateTime(from),
        if (to != null) 'to': toHistoryFilterDateTime(to, endOfDay: true),
      },
    );
    return PassengerRideHistoryResponse.fromJson(
        response.data as Map<String, dynamic>);
  }
}
