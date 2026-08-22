import '../../../../core/constants/driver_ride_api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../shared/utils/date_formatter.dart';
import 'models/driver_ride_detail_models.dart';
import 'models/driver_ride_history_models.dart';
import 'models/driver_ride_models.dart';

final class DriverRideRepository {
  const DriverRideRepository();

  Future<AvailableRequestsResponse> listAvailableRides() async {
    final response =
        await DioClient.get(path: DriverRideApiConstants.available);
    return AvailableRequestsResponse.fromJson(
        response.data as Map<String, dynamic>);
  }

  Future<BidResponse> submitBid(String rideRequestId, int fare) async {
    final response = await DioClient.post(
      path: DriverRideApiConstants.bid(rideRequestId),
      data: BidRequest(fare: fare).toJson(),
    );
    return BidResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ArrivedResponse> markArrived(String rideId) async {
    final response = await DioClient.post(
      path: DriverRideApiConstants.arrived(rideId),
      data: <String, dynamic>{},
    );
    return ArrivedResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<StartResponse> startRide(String rideId) async {
    final response = await DioClient.post(
      path: DriverRideApiConstants.start(rideId),
      data: <String, dynamic>{},
    );
    return StartResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CompleteResponse> completeRide(String rideId) async {
    final response = await DioClient.post(
      path: DriverRideApiConstants.complete(rideId),
      data: <String, dynamic>{},
    );
    return CompleteResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<DriverCancelResponse> cancelRide(
      String rideId, DriverCancelRequest request) async {
    final response = await DioClient.post(
      path: DriverRideApiConstants.cancel(rideId),
      data: request.toJson(),
    );
    return DriverCancelResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ActiveDriverRideResponse?> getActiveRide() async {
    final response = await DioClient.get(path: DriverRideApiConstants.active);
    final data = response.data;
    if (data is! Map<String, dynamic>) return null;
    return ActiveDriverRideResponse.fromJson(data);
  }

  /// Paginated ride history (completed + cancelled rides, newest first).
  Future<DriverRideHistoryResponse> listHistory({
    int page = 0,
    int size = 20,
    RideOutcome? state,
    ServiceType? serviceType,
    DateTime? from,
    DateTime? to,
  }) async {
    final response = await DioClient.get(
      path: DriverRideApiConstants.history,
      queryParameters: {
        'page': page,
        'size': size,
        if (state != null) 'state': state.apiValue,
        if (serviceType != null) 'serviceType': serviceType.toJson(),
        if (from != null) 'from': toHistoryFilterDateTime(from),
        if (to != null) 'to': toHistoryFilterDateTime(to, endOfDay: true),
      },
    );
    return DriverRideHistoryResponse.fromJson(
        response.data as Map<String, dynamic>);
  }

  /// Full detail for a single past ride.
  Future<DriverRideDetail> getRideDetail(String rideId) async {
    final response = await DioClient.get(
      path: DriverRideApiConstants.detail(rideId),
    );
    return DriverRideDetail.fromJson(response.data as Map<String, dynamic>);
  }
}
