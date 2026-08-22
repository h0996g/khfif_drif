import '../../../shared/models/shared_ride_models.dart';

/// Full detail for a single past ride.
///
/// Matches the `DriverRideDetailResponse` schema in `swagger/driver.json` —
/// a superset of [DriverRideHistoryItem] that adds the passenger's id and
/// phone, pickup/dropoff coordinates, the arrived/started timestamps, and
/// trip distance/duration.
final class DriverRideDetail {
  const DriverRideDetail({
    required this.rideId,
    required this.rideRequestId,
    required this.passengerId,
    required this.passengerFullName,
    required this.passengerPhone,
    required this.state,
    required this.finalFare,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.serviceType,
    this.pickupLat,
    this.pickupLng,
    this.dropoffLat,
    this.dropoffLng,
    this.cancellationReason,
    this.acceptedAt,
    this.arrivedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.distanceMeters,
    this.durationSeconds,
  });

  final String rideId;
  final String rideRequestId;
  final String passengerId;
  final String passengerFullName;
  final String passengerPhone;
  final RideOutcome state;
  final int finalFare;
  final String pickupAddress;
  final String dropoffAddress;
  final ServiceType serviceType;
  final double? pickupLat;
  final double? pickupLng;
  final double? dropoffLat;
  final double? dropoffLng;
  final String? cancellationReason;
  final String? acceptedAt;
  final String? arrivedAt;
  final String? startedAt;
  final String? completedAt;
  final String? cancelledAt;
  final int? distanceMeters;
  final int? durationSeconds;

  /// Most relevant timestamp for display: completion, otherwise cancellation,
  /// otherwise acceptance.
  String? get displayDate => completedAt ?? cancelledAt ?? acceptedAt;

  factory DriverRideDetail.fromJson(Map<String, dynamic> json) {
    final fare = json['finalFare'];
    return DriverRideDetail(
      rideId: (json['rideId'] as String?) ?? '',
      rideRequestId: (json['rideRequestId'] as String?) ?? '',
      passengerId: (json['passengerId'] as String?) ?? '',
      passengerFullName: (json['passengerFullName'] as String?) ?? '',
      passengerPhone: (json['passengerPhone'] as String?) ?? '',
      state: RideOutcome.fromJson((json['state'] as String?) ?? ''),
      finalFare: fare is int ? fare : ((fare as num?)?.toInt() ?? 0),
      pickupAddress: (json['pickupAddress'] as String?) ?? '',
      dropoffAddress: (json['dropoffAddress'] as String?) ?? '',
      serviceType: ServiceType.fromJson((json['serviceType'] as String?) ?? ''),
      pickupLat: (json['pickupLat'] as num?)?.toDouble(),
      pickupLng: (json['pickupLng'] as num?)?.toDouble(),
      dropoffLat: (json['dropoffLat'] as num?)?.toDouble(),
      dropoffLng: (json['dropoffLng'] as num?)?.toDouble(),
      cancellationReason: json['cancellationReason'] as String?,
      acceptedAt: json['acceptedAt'] as String?,
      arrivedAt: json['arrivedAt'] as String?,
      startedAt: json['startedAt'] as String?,
      completedAt: json['completedAt'] as String?,
      cancelledAt: json['cancelledAt'] as String?,
      distanceMeters: (json['distanceMeters'] as num?)?.toInt(),
      durationSeconds: (json['durationSeconds'] as num?)?.toInt(),
    );
  }
}
