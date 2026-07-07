import '../../../shared/models/shared_ride_models.dart';

/// A single entry in the driver's ride history (completed + cancelled rides).
///
/// Matches the `DriverRideHistoryItemResponse` schema in `swagger/driver.json`.
final class DriverRideHistoryItem {
  const DriverRideHistoryItem({
    required this.rideId,
    required this.rideRequestId,
    required this.state,
    required this.finalFare,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.serviceType,
    required this.passengerFullName,
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
  final String passengerFullName;
  final String? cancellationReason;
  final String? acceptedAt;
  final String? completedAt;
  final String? cancelledAt;

  /// Most relevant timestamp for display: completion, otherwise cancellation,
  /// otherwise acceptance.
  String? get displayDate => completedAt ?? cancelledAt ?? acceptedAt;

  factory DriverRideHistoryItem.fromJson(Map<String, dynamic> json) {
    final fare = json['finalFare'];
    return DriverRideHistoryItem(
      rideId: json['rideId'] as String,
      rideRequestId: json['rideRequestId'] as String,
      state: RideOutcome.fromJson(json['state'] as String),
      finalFare: fare is int ? fare : (fare as num).toInt(),
      pickupAddress: (json['pickupAddress'] as String?) ?? '',
      dropoffAddress: (json['dropoffAddress'] as String?) ?? '',
      serviceType: ServiceType.fromJson((json['serviceType'] as String?) ?? ''),
      passengerFullName: (json['passengerFullName'] as String?) ?? '',
      cancellationReason: json['cancellationReason'] as String?,
      acceptedAt: json['acceptedAt'] as String?,
      completedAt: json['completedAt'] as String?,
      cancelledAt: json['cancelledAt'] as String?,
    );
  }
}

/// Paginated wrapper for `GET /api/driver/rides` (Spring `Page<T>` style).
final class DriverRideHistoryResponse {
  const DriverRideHistoryResponse({
    required this.rides,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  });

  final List<DriverRideHistoryItem> rides;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;

  factory DriverRideHistoryResponse.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'];
    final rides = (rawList as List<dynamic>? ?? const [])
        .map((e) {
          try {
            return DriverRideHistoryItem.fromJson(e as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<DriverRideHistoryItem>()
        .toList();

    int asInt(Object? v, [int fallback = 0]) =>
        v is int ? v : (v is num ? v.toInt() : fallback);

    return DriverRideHistoryResponse(
      rides: rides,
      page: asInt(json['page']),
      size: asInt(json['size']),
      totalElements: asInt(json['totalElements']),
      totalPages: asInt(json['totalPages']),
    );
  }
}
