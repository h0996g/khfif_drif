export '../../../shared/models/shared_ride_models.dart';

import '../../../shared/models/shared_ride_models.dart';

final class WaitingOffersArgs {
  const WaitingOffersArgs({
    this.pickup,
    this.dropoff,
    this.serviceType,
    this.vehicleCategory,
    required this.proposedFare,
    required this.response,
  });

  final CoordinatePoint? pickup;
  final CoordinatePoint? dropoff;
  final int proposedFare;
  final ServiceType? serviceType;
  final VehicleCategory? vehicleCategory;
  final CreateRideResponse response;
}

final class CreateRideRequest {
  const CreateRideRequest({
    required this.pickup,
    required this.dropoff,
    required this.serviceType,
    required this.vehicleCategory,
    required this.femaleOnly,
    required this.proposedFare,
    this.recipientName,
    this.recipientPhone,
    this.packageNote,
  });

  final CoordinatePoint pickup;
  final CoordinatePoint dropoff;
  final ServiceType serviceType;
  final VehicleCategory vehicleCategory;
  final bool femaleOnly;
  final int proposedFare;
  final String? recipientName;
  final String? recipientPhone;
  final String? packageNote;

  Map<String, dynamic> toJson() => {
        'pickup': pickup.toJson(),
        'dropoff': dropoff.toJson(),
        'serviceType': serviceType.toJson(),
        'vehicleCategory': vehicleCategory.toJson(),
        'femaleOnly': femaleOnly,
        'proposedFare': proposedFare,
        if (recipientName != null) 'recipientName': recipientName,
        if (recipientPhone != null) 'recipientPhone': recipientPhone,
        if (packageNote != null) 'packageNote': packageNote,
      };
}

final class CreateRideResponse {
  const CreateRideResponse({
    required this.rideRequestId,
    required this.state,
    required this.proposedFare,
    required this.expiresAt,
    required this.broadcastDriverCount,
  });

  final String rideRequestId;
  final String state;
  final int proposedFare;
  final String expiresAt;
  final int broadcastDriverCount;

  factory CreateRideResponse.fromJson(Map<String, dynamic> json) =>
      CreateRideResponse(
        rideRequestId: json['rideRequestId'] as String,
        state: json['state'] as String,
        proposedFare: json['proposedFare'] as int,
        expiresAt: json['expiresAt'] as String,
        broadcastDriverCount: json['broadcastDriverCount'] as int,
      );
}

final class OfferEntry {
  const OfferEntry({
    required this.offerId,
    required this.driverId,
    required this.driverFullName,
    required this.driverRatingAvg,
    required this.vehicleModel,
    required this.vehiclePlate,
    required this.fare,
    required this.direction,
    required this.status,
    required this.round,
    required this.etaSeconds,
    required this.expiresAt,
    this.previousOfferId,
  });

  final String offerId;
  final String driverId;
  final String driverFullName;
  final double? driverRatingAvg;
  final String vehicleModel;
  final String? vehiclePlate;
  final int fare;
  final String direction;
  final String status;
  final int round;
  final int? etaSeconds;
  final String expiresAt;
  final String? previousOfferId;

  factory OfferEntry.fromJson(Map<String, dynamic> json) => OfferEntry(
        offerId: json['offerId'] as String,
        driverId: json['driverId'] as String,
        driverFullName: json['driverFullName'] as String,
        driverRatingAvg: (json['driverRatingAvg'] as num?)?.toDouble(),
        vehicleModel: json['vehicleModel'] as String,
        vehiclePlate: json['vehiclePlate'] as String?,
        fare: json['fare'] as int,
        direction: json['direction'] as String,
        status: json['status'] as String,
        round: json['round'] as int,
        etaSeconds: json['etaSeconds'] as int?,
        expiresAt: json['expiresAt'] as String,
        previousOfferId: json['previousOfferId'] as String?,
      );
}

final class OfferListResponse {
  const OfferListResponse({required this.offers});

  final List<OfferEntry> offers;

  factory OfferListResponse.fromJson(Map<String, dynamic> json) =>
      OfferListResponse(
        offers: (json['offers'] as List<dynamic>)
            .map((e) => OfferEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

final class AcceptOfferResponse {
  const AcceptOfferResponse({
    required this.rideId,
    required this.state,
    required this.finalFare,
  });

  final String rideId;
  final String state;
  final int finalFare;

  factory AcceptOfferResponse.fromJson(Map<String, dynamic> json) =>
      AcceptOfferResponse(
        rideId: json['rideId'] as String,
        state: json['state'] as String,
        finalFare: json['finalFare'] as int,
      );
}

final class RefuseOfferResponse {
  const RefuseOfferResponse({required this.offerId, required this.status});

  final String offerId;
  final String status;

  factory RefuseOfferResponse.fromJson(Map<String, dynamic> json) =>
      RefuseOfferResponse(
        offerId: json['offerId'] as String,
        status: json['status'] as String,
      );
}

final class ActiveRideResponse {
  const ActiveRideResponse({this.request, this.ride});

  final ActiveRequestSummary? request;
  final ActiveRideSummary? ride;

  factory ActiveRideResponse.fromJson(Map<String, dynamic> json) =>
      ActiveRideResponse(
        request: json['request'] != null
            ? ActiveRequestSummary.fromJson(
                json['request'] as Map<String, dynamic>)
            : null,
        ride: json['ride'] != null
            ? ActiveRideSummary.fromJson(json['ride'] as Map<String, dynamic>)
            : null,
      );
}

final class ActiveRequestSummary {
  const ActiveRequestSummary({
    required this.rideRequestId,
    required this.state,
    required this.proposedFare,
    required this.expiresAt,
    required this.offerCount,
    required this.broadcastDriverCount,
    this.pickup,
    this.dropoff,
  });

  final String rideRequestId;
  final String state;
  final int proposedFare;
  final String expiresAt;
  final int offerCount;
  final int broadcastDriverCount;
  final CoordinatePoint? pickup;
  final CoordinatePoint? dropoff;

  factory ActiveRequestSummary.fromJson(Map<String, dynamic> json) =>
      ActiveRequestSummary(
        rideRequestId: json['rideRequestId'] as String,
        state: json['state'] as String,
        proposedFare: json['proposedFare'] as int,
        expiresAt: json['expiresAt'] as String,
        offerCount: json['offerCount'] as int,
        broadcastDriverCount: json['broadcastDriverCount'] as int? ?? 0,
        pickup: json['pickup'] != null
            ? CoordinatePoint.fromJson(json['pickup'] as Map<String, dynamic>)
            : null,
        dropoff: json['dropoff'] != null
            ? CoordinatePoint.fromJson(json['dropoff'] as Map<String, dynamic>)
            : null,
      );
}

final class DriverInRide {
  const DriverInRide({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.vehicleModel,
    required this.vehiclePlate,
    this.currentLat,
    this.currentLng,
  });

  final String id;
  final String fullName;
  final String phone;
  final String vehicleModel;
  final String vehiclePlate;
  final double? currentLat;
  final double? currentLng;

  factory DriverInRide.fromJson(Map<String, dynamic> json) {
    final pos = json['currentPosition'] as Map<String, dynamic>?;
    return DriverInRide(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      phone: json['phone'] as String,
      vehicleModel: json['vehicleModel'] as String,
      vehiclePlate: json['vehiclePlate'] as String,
      currentLat: pos != null ? (pos['lat'] as num).toDouble() : null,
      currentLng: pos != null ? (pos['lng'] as num).toDouble() : null,
    );
  }
}

final class ActiveRideSummary {
  const ActiveRideSummary({
    required this.rideId,
    required this.state,
    required this.finalFare,
    required this.driver,
    required this.acceptedAt,
    this.arrivedAt,
    this.startedAt,
    this.pickup,
    this.dropoff,
  });

  final String rideId;
  final String state;
  final int finalFare;
  final DriverInRide driver;
  final String acceptedAt;
  final String? arrivedAt;
  final String? startedAt;
  final CoordinatePoint? pickup;
  final CoordinatePoint? dropoff;

  factory ActiveRideSummary.fromJson(Map<String, dynamic> json) =>
      ActiveRideSummary(
        rideId: json['rideId'] as String,
        state: json['state'] as String,
        finalFare: json['finalFare'] as int,
        driver: DriverInRide.fromJson(json['driver'] as Map<String, dynamic>),
        acceptedAt: json['acceptedAt'] as String,
        arrivedAt: json['arrivedAt'] as String?,
        startedAt: json['startedAt'] as String?,
        pickup: json['pickup'] != null
            ? CoordinatePoint.fromJson(json['pickup'] as Map<String, dynamic>)
            : null,
        dropoff: json['dropoff'] != null
            ? CoordinatePoint.fromJson(json['dropoff'] as Map<String, dynamic>)
            : null,
      );
}

final class CancelRideResponse {
  const CancelRideResponse({required this.state, required this.cancelledAt});

  final String state;
  final String cancelledAt;

  factory CancelRideResponse.fromJson(Map<String, dynamic> json) =>
      CancelRideResponse(
        state: json['state'] as String,
        cancelledAt: json['cancelledAt'] as String,
      );
}
