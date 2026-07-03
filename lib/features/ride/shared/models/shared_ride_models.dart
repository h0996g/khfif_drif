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

  static ServiceType fromJson(String value) =>
      ServiceType.values.firstWhere((e) => e.toJson() == value.toUpperCase());
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

  static VehicleCategory fromJson(String value) => VehicleCategory.values
      .firstWhere((e) => e.toJson() == value.toUpperCase());
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
