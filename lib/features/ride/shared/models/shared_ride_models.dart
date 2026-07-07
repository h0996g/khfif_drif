import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

final class CoordinatePoint {
  const CoordinatePoint({
    required this.address,
    required this.lat,
    required this.lng,
  });

  final String address;
  final double lat;
  final double lng;

  Map<String, dynamic> toJson() => {
        'address': address,
        'lat': lat,
        'lng': lng,
      };

  factory CoordinatePoint.fromJson(Map<String, dynamic> json) =>
      CoordinatePoint(
        address: (json['address'] as String?) ?? '',
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
      );
}

enum ServiceType {
  ride,
  delivery;

  String get label => switch (this) {
        ServiceType.ride => 'Ride',
        ServiceType.delivery => 'Delivery',
      };

  IconData get icon => switch (this) {
        ServiceType.ride => Icons.directions_car_rounded,
        ServiceType.delivery => Icons.local_shipping_rounded,
      };

  /// Vehicle categories the passenger may pick for this service type.
  List<VehicleCategory> get availableCategories => switch (this) {
        ServiceType.ride =>
          [VehicleCategory.car, VehicleCategory.motorcycle],
        ServiceType.delivery => [
          VehicleCategory.car,
          VehicleCategory.motorcycle,
          VehicleCategory.van,
        ],
      };

  String toJson() => name.toUpperCase();

  static ServiceType fromJson(String value) => ServiceType.values.firstWhere(
        (e) => e.toJson() == value.toUpperCase(),
        orElse: () => ServiceType.ride,
      );
}

/// Lifecycle state of a finished or in-progress ride, as returned by the
/// ride-history endpoints. Shared by the driver and passenger history surfaces.
enum RideOutcome {
  accepted,
  arrived,
  inProgress,
  completed,
  cancelled;

  static RideOutcome fromJson(String value) => switch (value.toUpperCase()) {
        'ACCEPTED' => accepted,
        'ARRIVED' => arrived,
        'IN_PROGRESS' => inProgress,
        'COMPLETED' => completed,
        _ => cancelled,
      };

  String get label => switch (this) {
        accepted => 'Accepted',
        arrived => 'Arrived',
        inProgress => 'In Progress',
        completed => 'Completed',
        cancelled => 'Cancelled',
      };

  /// Wire value for the `state` query filter on the ride-history endpoints.
  String get apiValue => switch (this) {
        accepted => 'ACCEPTED',
        arrived => 'ARRIVED',
        inProgress => 'IN_PROGRESS',
        completed => 'COMPLETED',
        cancelled => 'CANCELLED',
      };

  Color get color => switch (this) {
        completed => const Color(0xFF00C853),
        cancelled => const Color(0xFFEF4444),
        accepted || arrived || inProgress => const Color(0xFFF59E0B),
      };

  IconData get icon => switch (this) {
        completed => Icons.check_circle_rounded,
        cancelled => Icons.cancel_rounded,
        accepted => Icons.handshake_outlined,
        arrived => Icons.flag_outlined,
        inProgress => Icons.local_taxi_rounded,
      };
}

enum VehicleCategory {
  car,
  motorcycle,
  van;

  String get label => switch (this) {
        VehicleCategory.car => 'Car',
        VehicleCategory.motorcycle => 'Motorcycle',
        VehicleCategory.van => 'Van',
      };

  IconData get icon => switch (this) {
        VehicleCategory.car => Icons.directions_car_rounded,
        VehicleCategory.motorcycle => Icons.two_wheeler_rounded,
        VehicleCategory.van => Icons.airport_shuttle_rounded,
      };

  String toJson() => name.toUpperCase();

  static VehicleCategory fromJson(String value) =>
      VehicleCategory.values.firstWhere(
        (e) => e.toJson() == value.toUpperCase(),
        orElse: () => VehicleCategory.car,
      );
}

enum CancelReason {
  passengerChangedMind,
  passengerNoShow,
  driverTooFar,
  driverVehicleIssue,
}

extension CancelReasonX on CancelReason {
  String get apiValue => switch (this) {
        CancelReason.passengerChangedMind => 'PASSENGER_CHANGED_MIND',
        CancelReason.passengerNoShow => 'PASSENGER_NO_SHOW',
        CancelReason.driverTooFar => 'DRIVER_TOO_FAR',
        CancelReason.driverVehicleIssue => 'DRIVER_VEHICLE_ISSUE',
      };

  String get label => switch (this) {
        CancelReason.passengerChangedMind => 'Changed my mind',
        CancelReason.passengerNoShow => "I can't be reached",
        CancelReason.driverTooFar => 'Driver is too far',
        CancelReason.driverVehicleIssue => 'Driver has a vehicle issue',
      };
}

final class CancelRideRequest {
  const CancelRideRequest({required this.reason, this.note});

  final String reason;
  final String? note;

  Map<String, dynamic> toJson() => {
        'reason': reason,
        if (note != null) 'note': note,
      };
}

/// Optional filters for the passenger/driver ride-history endpoints
/// (`GET /api/passenger/rides`, `GET /api/driver/rides`).
final class RideHistoryFilter extends Equatable {
  const RideHistoryFilter({
    this.state,
    this.serviceType,
    this.from,
    this.to,
  });

  static const RideHistoryFilter empty = RideHistoryFilter();

  final RideOutcome? state;
  final ServiceType? serviceType;
  final DateTime? from;
  final DateTime? to;

  bool get isEmpty =>
      state == null && serviceType == null && from == null && to == null;

  RideHistoryFilter copyWith({
    RideOutcome? Function()? state,
    ServiceType? Function()? serviceType,
    DateTime? Function()? from,
    DateTime? Function()? to,
  }) {
    return RideHistoryFilter(
      state: state != null ? state() : this.state,
      serviceType: serviceType != null ? serviceType() : this.serviceType,
      from: from != null ? from() : this.from,
      to: to != null ? to() : this.to,
    );
  }

  @override
  List<Object?> get props => [state, serviceType, from, to];
}
