import '../../../shared/models/shared_ride_models.dart';

export '../../../shared/models/shared_ride_models.dart';

enum ActiveDriverRideState {
  accepted,
  arrived,
  inProgress,
  completed,
  cancelled;

  static ActiveDriverRideState fromJson(String value) =>
      switch (value.toUpperCase()) {
        'ACCEPTED' => accepted,
        'ARRIVED' => arrived,
        'IN_PROGRESS' => inProgress,
        'COMPLETED' => completed,
        _ => cancelled,
      };
}

final class AvailableRequestCard {
  const AvailableRequestCard({
    required this.rideRequestId,
    required this.pickup,
    required this.dropoff,
    required this.proposedFare,
    required this.serviceType,
    this.vehicleCategory,
    required this.femaleOnly,
    required this.distanceMeters,
    required this.expiresAt,
  });

  final String rideRequestId;
  final CoordinatePoint pickup;
  final CoordinatePoint dropoff;
  final int proposedFare;
  final ServiceType serviceType;
  final VehicleCategory? vehicleCategory;
  final bool femaleOnly;
  final int? distanceMeters;
  final String expiresAt;

  factory AvailableRequestCard.fromJson(Map<String, dynamic> json) =>
      AvailableRequestCard(
        rideRequestId: json['rideRequestId'] as String,
        pickup: _coordinateFromJson(json['pickup'] as Map<String, dynamic>),
        dropoff: _coordinateFromJson(json['dropoff'] as Map<String, dynamic>),
        proposedFare: json['proposedFare'] as int,
        serviceType: ServiceType.fromJson(json['serviceType'] as String),
        vehicleCategory: json['vehicleCategory'] != null
            ? VehicleCategory.fromJson(json['vehicleCategory'] as String)
            : null,
        femaleOnly: json['femaleOnly'] as bool,
        distanceMeters: json['distanceMeters'] as int?,
        expiresAt: json['expiresAt'] as String,
      );
}

CoordinatePoint _coordinateFromJson(Map<String, dynamic> json) =>
    CoordinatePoint(
      address: json['address'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );

final class AvailableRequestsResponse {
  const AvailableRequestsResponse({required this.requests});

  final List<AvailableRequestCard> requests;

  factory AvailableRequestsResponse.fromJson(Map<String, dynamic> json) =>
      AvailableRequestsResponse(
        requests: (json['requests'] as List<dynamic>)
            .map((e) {
              try {
                return AvailableRequestCard.fromJson(
                    e as Map<String, dynamic>);
              } catch (_) {
                return null;
              }
            })
            .whereType<AvailableRequestCard>()
            .toList(),
      );
}

final class BidRequest {
  const BidRequest({required this.fare});

  final int fare;

  Map<String, dynamic> toJson() => {'fare': fare};
}

final class BidResponse {
  const BidResponse({
    required this.offerId,
    required this.rideRequestId,
    required this.fare,
    required this.direction,
    required this.round,
    required this.expiresAt,
  });

  final String offerId;
  final String rideRequestId;
  final int fare;
  final String direction;
  final int round;
  final String expiresAt;

  factory BidResponse.fromJson(Map<String, dynamic> json) => BidResponse(
        offerId: json['offerId'] as String,
        rideRequestId: json['rideRequestId'] as String,
        fare: json['fare'] as int,
        direction: json['direction'] as String,
        round: json['round'] as int,
        expiresAt: json['expiresAt'] as String,
      );
}

final class ArrivedResponse {
  const ArrivedResponse({
    required this.rideId,
    required this.state,
    required this.arrivedAt,
    required this.arrivalWaitDeadline,
  });

  final String rideId;
  final ActiveDriverRideState state;
  final String arrivedAt;
  final String arrivalWaitDeadline;

  factory ArrivedResponse.fromJson(Map<String, dynamic> json) =>
      ArrivedResponse(
        rideId: json['rideId'] as String,
        state: ActiveDriverRideState.fromJson(json['state'] as String),
        arrivedAt: json['arrivedAt'] as String,
        arrivalWaitDeadline: json['arrivalWaitDeadline'] as String,
      );
}

final class StartResponse {
  const StartResponse({
    required this.rideId,
    required this.state,
    required this.startedAt,
    required this.inProgressDeadline,
  });

  final String rideId;
  final ActiveDriverRideState state;
  final String startedAt;
  final String inProgressDeadline;

  factory StartResponse.fromJson(Map<String, dynamic> json) => StartResponse(
        rideId: json['rideId'] as String,
        state: ActiveDriverRideState.fromJson(json['state'] as String),
        startedAt: json['startedAt'] as String,
        inProgressDeadline: json['inProgressDeadline'] as String,
      );
}

final class CompleteResponse {
  const CompleteResponse({
    required this.rideId,
    required this.state,
    required this.completedAt,
    required this.finalFare,
  });

  final String rideId;
  final ActiveDriverRideState state;
  final String completedAt;
  final int finalFare;

  factory CompleteResponse.fromJson(Map<String, dynamic> json) =>
      CompleteResponse(
        rideId: json['rideId'] as String,
        state: ActiveDriverRideState.fromJson(json['state'] as String),
        completedAt: json['completedAt'] as String,
        finalFare: json['finalFare'] as int,
      );
}

final class DriverCancelRequest {
  const DriverCancelRequest({required this.reason, this.note});

  final String reason;
  final String? note;

  Map<String, dynamic> toJson() => {
        'reason': reason,
        if (note != null) 'note': note,
      };
}

final class DriverCancelResponse {
  const DriverCancelResponse({
    required this.rideId,
    required this.state,
    required this.cancelledAt,
  });

  final String rideId;
  final ActiveDriverRideState state;
  final String cancelledAt;

  factory DriverCancelResponse.fromJson(Map<String, dynamic> json) =>
      DriverCancelResponse(
        rideId: json['rideId'] as String,
        state: ActiveDriverRideState.fromJson(json['state'] as String),
        cancelledAt: json['cancelledAt'] as String,
      );
}

final class ActiveDriverRideResponse {
  const ActiveDriverRideResponse({
    required this.rideId,
    required this.rideRequestId,
    required this.passengerId,
    required this.passengerFullName,
    required this.passengerPhone,
    required this.pickup,
    required this.dropoff,
    required this.finalFare,
    required this.state,
    required this.acceptedAt,
    this.arrivedAt,
    this.startedAt,
    this.arrivalWaitDeadline,
  });

  final String rideId;
  final String rideRequestId;
  final String passengerId;
  final String passengerFullName;
  final String passengerPhone;
  final CoordinatePoint pickup;
  final CoordinatePoint dropoff;
  final int finalFare;
  final ActiveDriverRideState state;
  final String acceptedAt;
  final String? arrivedAt;
  final String? startedAt;
  final String? arrivalWaitDeadline;

  factory ActiveDriverRideResponse.fromJson(Map<String, dynamic> json) =>
      ActiveDriverRideResponse(
        rideId: json['rideId'] as String,
        rideRequestId: json['rideRequestId'] as String,
        passengerId: json['passengerId'] as String,
        passengerFullName: json['passengerFullName'] as String,
        passengerPhone: json['passengerPhone'] as String,
        pickup: _coordinateFromJson(json['pickup'] as Map<String, dynamic>),
        dropoff: _coordinateFromJson(json['dropoff'] as Map<String, dynamic>),
        finalFare: json['finalFare'] as int,
        state: ActiveDriverRideState.fromJson(json['state'] as String),
        acceptedAt: json['acceptedAt'] as String,
        arrivedAt: json['arrivedAt'] as String?,
        startedAt: json['startedAt'] as String?,
        arrivalWaitDeadline: json['arrivalWaitDeadline'] as String?,
      );
}
