import 'package:flutter_test/flutter_test.dart';
import 'package:khfif_drif/features/ride/driver/data/models/driver_ride_detail_models.dart';
import 'package:khfif_drif/features/ride/shared/models/shared_ride_models.dart';

/// Fixtures mirror the `DriverRideDetailResponse` schema in
/// `swagger/driver.json` (lines 1376-1411).
void main() {
  group('DriverRideDetail.fromJson', () {
    test('maps a full payload field by field', () {
      final ride = DriverRideDetail.fromJson({
        'rideId': 'ride-uuid',
        'rideRequestId': 'request-uuid',
        'passengerId': 'passenger-uuid',
        'passengerFullName': 'Amina B',
        'passengerPhone': '+213770000000',
        'state': 'COMPLETED',
        'finalFare': 1250,
        'pickupAddress': 'Rue Didouche Mourad, Alger',
        'pickupLat': 36.7753,
        'pickupLng': 3.0602,
        'dropoffAddress': 'Aéroport Houari Boumediene',
        'dropoffLat': 36.6979,
        'dropoffLng': 3.2154,
        'serviceType': 'RIDE',
        'acceptedAt': '2026-08-20T10:00:00Z',
        'arrivedAt': '2026-08-20T10:05:00Z',
        'startedAt': '2026-08-20T10:06:00Z',
        'completedAt': '2026-08-20T10:28:00Z',
        'distanceMeters': 8400,
        'durationSeconds': 1320,
      });

      expect(ride.rideId, 'ride-uuid');
      expect(ride.rideRequestId, 'request-uuid');
      expect(ride.passengerId, 'passenger-uuid');
      expect(ride.passengerFullName, 'Amina B');
      expect(ride.passengerPhone, '+213770000000');
      expect(ride.state, RideOutcome.completed);
      expect(ride.finalFare, 1250);
      expect(ride.pickupAddress, 'Rue Didouche Mourad, Alger');
      expect(ride.pickupLat, 36.7753);
      expect(ride.pickupLng, 3.0602);
      expect(ride.dropoffAddress, 'Aéroport Houari Boumediene');
      expect(ride.dropoffLat, 36.6979);
      expect(ride.dropoffLng, 3.2154);
      expect(ride.serviceType, ServiceType.ride);
      expect(ride.acceptedAt, '2026-08-20T10:00:00Z');
      expect(ride.arrivedAt, '2026-08-20T10:05:00Z');
      expect(ride.startedAt, '2026-08-20T10:06:00Z');
      expect(ride.completedAt, '2026-08-20T10:28:00Z');
      expect(ride.cancelledAt, isNull);
      expect(ride.cancellationReason, isNull);
      expect(ride.distanceMeters, 8400);
      expect(ride.durationSeconds, 1320);
    });

    test('tolerates a partial payload with tolerant defaults', () {
      final ride = DriverRideDetail.fromJson({
        'rideId': 'ride-2',
        'rideRequestId': 'request-2',
        'state': 'CANCELLED',
        'finalFare': 900.0, // JSON double, not int
        'serviceType': 'DELIVERY',
        'cancellationReason': 'Passenger no-show',
        'cancelledAt': '2026-08-19T18:00:00Z',
      });

      expect(ride.rideId, 'ride-2');
      expect(ride.state, RideOutcome.cancelled);
      expect(ride.finalFare, 900);
      expect(ride.serviceType, ServiceType.delivery);
      expect(ride.cancellationReason, 'Passenger no-show');
      expect(ride.passengerId, '');
      expect(ride.passengerFullName, '');
      expect(ride.passengerPhone, '');
      expect(ride.pickupAddress, '');
      expect(ride.dropoffAddress, '');
      expect(ride.pickupLat, isNull);
      expect(ride.pickupLng, isNull);
      expect(ride.dropoffLat, isNull);
      expect(ride.dropoffLng, isNull);
      expect(ride.distanceMeters, isNull);
      expect(ride.durationSeconds, isNull);
      expect(ride.acceptedAt, isNull);
      expect(ride.completedAt, isNull);
    });

    test('does not throw on an empty object', () {
      final ride = DriverRideDetail.fromJson({});

      expect(ride.rideId, '');
      expect(ride.finalFare, 0);
      expect(ride.state, RideOutcome.cancelled); // unknown → cancelled
      expect(ride.serviceType, ServiceType.ride); // unknown → ride
    });

    test('displayDate prefers completedAt, then cancelledAt, then acceptedAt',
        () {
      final base = <String, dynamic>{
        'rideId': 'r',
        'rideRequestId': 'q',
        'acceptedAt': '2026-08-20T10:00:00Z',
        'cancelledAt': '2026-08-20T10:10:00Z',
        'completedAt': '2026-08-20T10:30:00Z',
      };

      expect(
        DriverRideDetail.fromJson(base).displayDate,
        '2026-08-20T10:30:00Z',
      );
      expect(
        DriverRideDetail.fromJson({...base..remove('completedAt')}).displayDate,
        '2026-08-20T10:10:00Z',
      );
      expect(
        DriverRideDetail.fromJson(
          {...base..remove('completedAt')..remove('cancelledAt')},
        ).displayDate,
        '2026-08-20T10:00:00Z',
      );
    });
  });
}
