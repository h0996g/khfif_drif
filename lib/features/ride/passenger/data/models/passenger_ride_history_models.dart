import '../../../shared/models/shared_ride_models.dart';

/// A single entry in the passenger's ride history (completed + cancelled rides).
///
/// Matches the `PassengerRideHistoryItemResponse` schema in
/// `swagger/passenger.json`. Mirrors `DriverRideHistoryItem` but carries the
/// driver + vehicle identity instead of the passenger's name.
final class PassengerRideHistoryItem {
  const PassengerRideHistoryItem({
    required this.rideId,
    required this.rideRequestId,
    required this.state,
    required this.finalFare,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.serviceType,
    required this.driverFullName,
    required this.vehicleModel,
    required this.vehiclePlate,
    this.cancellationReason,
    this.acceptedAt,
    this.completedAt,
    this.cancelledAt,
  });

  final String rideId;
  final String rideRequestId;
  final RideOutcome state;
  final int finalFare;
  final String pickupAddress;
  final String dropoffAddress;
  final ServiceType serviceType;
  final String driverFullName;
  final String vehicleModel;
  final String vehiclePlate;
  final String? cancellationReason;
  final String? acceptedAt;
  final String? completedAt;
  final String? cancelledAt;

  /// Most relevant timestamp for display: completion, otherwise cancellation,
  /// otherwise acceptance.
  String? get displayDate => completedAt ?? cancelledAt ?? acceptedAt;

  factory PassengerRideHistoryItem.fromJson(Map<String, dynamic> json) {
    final fare = json['finalFare'];
    return PassengerRideHistoryItem(
      rideId: json['rideId'] as String,
      rideRequestId: json['rideRequestId'] as String,
      state: RideOutcome.fromJson(json['state'] as String),
      finalFare: fare is int ? fare : (fare as num).toInt(),
      pickupAddress: (json['pickupAddress'] as String?) ?? '',
      dropoffAddress: (json['dropoffAddress'] as String?) ?? '',
      serviceType: ServiceType.fromJson((json['serviceType'] as String?) ?? ''),
      driverFullName: (json['driverFullName'] as String?) ?? '',
      vehicleModel: (json['vehicleModel'] as String?) ?? '',
      vehiclePlate: (json['vehiclePlate'] as String?) ?? '',
      cancellationReason: json['cancellationReason'] as String?,
      acceptedAt: json['acceptedAt'] as String?,
      completedAt: json['completedAt'] as String?,
      cancelledAt: json['cancelledAt'] as String?,
    );
  }
}

/// Paginated wrapper for `GET /api/passenger/rides` (Spring `Page<T>` style).
final class PassengerRideHistoryResponse {
  const PassengerRideHistoryResponse({
    required this.rides,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  });

  final List<PassengerRideHistoryItem> rides;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;

  factory PassengerRideHistoryResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'];
    final rides = (rawList as List<dynamic>? ?? const [])
        .map((e) {
          try {
            return PassengerRideHistoryItem.fromJson(e as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<PassengerRideHistoryItem>()
        .toList();

    int asInt(Object? v, [int fallback = 0]) =>
        v is int ? v : (v is num ? v.toInt() : fallback);

    return PassengerRideHistoryResponse(
      rides: rides,
      page: asInt(json['page']),
      size: asInt(json['size']),
      totalElements: asInt(json['totalElements']),
      totalPages: asInt(json['totalPages']),
    );
  }
}
