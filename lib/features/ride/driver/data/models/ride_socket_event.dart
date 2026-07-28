import 'dart:convert';

import 'driver_ride_models.dart';

/// Ride states as defined in the state machine (swagger/epic-03-ride.md §6).
enum RideState {
  accepted,
  arrived,
  inProgress,
  completed,
  cancelled;

  static RideState fromWire(String value) => switch (value) {
        'ACCEPTED' => RideState.accepted,
        'ARRIVED' => RideState.arrived,
        'IN_PROGRESS' => RideState.inProgress,
        'COMPLETED' => RideState.completed,
        'CANCELLED' => RideState.cancelled,
        _ => throw ArgumentError('Unknown ride state: $value'),
      };
}

/// All socket `type` values handled by this layer (driver + passenger downstream
/// + shared). Any other `type` is ignored.
enum RideSocketEventType {
  // Driver downstream
  rideBroadcast('ride.broadcast'),
  rideBroadcastCancelled('ride.broadcast_cancelled'),
  // Passenger downstream
  rideRequested('ride.requested'),
  rideRequestCancelled('ride.request_cancelled'),
  driverLocation('driver.location'),
  // Shared downstream (both surfaces)
  offerCreated('offer.created'),
  offerAccepted('offer.accepted'),
  offerRejected('offer.rejected'),
  offerExpired('offer.expired'),
  rideStateChanged('ride.state_changed'),
  rideCancelled('ride.cancelled'),
  // Wallet downstream (driver only — see integration/epic-04-wallet.md §5)
  walletTopUpApproved('wallet.topup_approved'),
  walletTopUpRejected('wallet.topup_rejected'),
  walletCommissionCharged('wallet.commission_charged'),
  walletPenaltyCharged('wallet.penalty_charged'),
  walletBalanceLow('wallet.balance_low'),
  walletBalanceAdjusted('wallet.balance_adjusted'),
  // System
  systemTokenExpiring('system.token_expiring');

  const RideSocketEventType(this.wireName);

  final String wireName;

  static RideSocketEventType? fromWire(String value) {
    for (final type in values) {
      if (type.wireName == value) return type;
    }
    return null;
  }
}

/// Typed events decoded from raw socket frames (`{ type, payload, timestamp }`
/// envelope) as defined in swagger/epic-03-ride.md §5/§9. Covers both the
/// driver and passenger WebSocket surfaces — each cubit filters to the events
/// it cares about. Malformed or unrecognised frames parse to `null` and are
/// dropped; socket frames are best-effort hints, not guaranteed delivery.
sealed class RideSocketEvent {
  const RideSocketEvent();

  static RideSocketEvent? tryParse(String frame) {
    try {
      final envelope = jsonDecode(frame) as Map<String, dynamic>;
      final type = RideSocketEventType.fromWire(envelope['type'] as String? ?? '');
      final payload = envelope['payload'] as Map<String, dynamic>?;
      if (type == null || payload == null) return null;

      return switch (type) {
        RideSocketEventType.rideBroadcast =>
          RideBroadcast(AvailableRequestCard.fromJson(payload)),
        RideSocketEventType.rideBroadcastCancelled => RideBroadcastCancelled(
            rideRequestId: payload['rideRequestId'] as String,
            reason: payload['reason'] as String? ?? '',
          ),
        RideSocketEventType.rideRequested => RideRequested(
            rideRequestId: payload['rideRequestId'] as String,
            serviceType: payload['serviceType'] as String? ?? '',
            femaleOnly: payload['femaleOnly'] as bool? ?? false,
            proposedFare: payload['proposedFare'] as int,
          ),
        RideSocketEventType.rideRequestCancelled => RideRequestCancelled(
            rideRequestId: payload['rideRequestId'] as String,
            reason: payload['reason'] as String? ?? '',
          ),
        RideSocketEventType.offerCreated => OfferCreated(
            offerId: payload['offerId'] as String,
            rideRequestId: payload['rideRequestId'] as String,
            driverId: payload['driverId'] as String,
            fare: payload['fare'] as int,
            expiresAt: payload['expiresAt'] as String,
          ),
        RideSocketEventType.offerAccepted => OfferAccepted(
            offerId: payload['offerId'] as String,
            rideRequestId: payload['rideRequestId'] as String,
            rideId: payload['rideId'] as String,
            fare: payload['fare'] as int,
            driverId: payload['driverId'] as String?,
          ),
        RideSocketEventType.offerRejected => OfferRejected(
            offerId: payload['offerId'] as String,
            rideRequestId: payload['rideRequestId'] as String,
            reason: payload['reason'] as String? ?? '',
          ),
        RideSocketEventType.offerExpired => OfferExpired(
            offerId: payload['offerId'] as String,
            rideRequestId: payload['rideRequestId'] as String,
          ),
        RideSocketEventType.rideStateChanged => RideStateChanged(
            rideId: payload['rideId'] as String,
            state: RideState.fromWire(payload['state'] as String),
            occurredAt: payload['occurredAt'] as String,
          ),
        RideSocketEventType.rideCancelled => RideCancelled(
            rideId: payload['rideId'] as String,
            actorType: payload['actorType'] as String? ?? '',
            reason: payload['reason'] as String? ?? '',
            occurredAt: payload['occurredAt'] as String,
          ),
        RideSocketEventType.driverLocation => DriverLocationUpdate(
            rideId: payload['rideId'] as String,
            driverId: payload['driverId'] as String,
            lat: (payload['lat'] as num).toDouble(),
            lng: (payload['lng'] as num).toDouble(),
            capturedAt: payload['capturedAt'] as String,
          ),
        RideSocketEventType.walletTopUpApproved => WalletTopUpApproved(
            topUpId: payload['topUpId'] as String,
            creditedAmountDzd: _asInt(payload['creditedAmountDzd']),
            balanceDzd: _asInt(payload['balanceDzd']),
          ),
        RideSocketEventType.walletTopUpRejected => WalletTopUpRejected(
            topUpId: payload['topUpId'] as String,
            reason: payload['reason'] as String? ?? '',
          ),
        RideSocketEventType.walletCommissionCharged => WalletCommissionCharged(
            rideId: payload['rideId'] as String,
            amountDzd: _asInt(payload['amountDzd']),
            balanceDzd: _asInt(payload['balanceDzd']),
          ),
        RideSocketEventType.walletPenaltyCharged => WalletPenaltyCharged(
            rideId: payload['rideId'] as String,
            amountDzd: _asInt(payload['amountDzd']),
            balanceDzd: _asInt(payload['balanceDzd']),
          ),
        RideSocketEventType.walletBalanceLow => WalletBalanceLow(
            balanceDzd: _asInt(payload['balanceDzd']),
            thresholdDzd: _asInt(payload['thresholdDzd']),
          ),
        RideSocketEventType.walletBalanceAdjusted => WalletBalanceAdjusted(
            direction: payload['direction'] as String? ?? '',
            amountDzd: _asInt(payload['amountDzd']),
            balanceDzd: _asInt(payload['newBalanceDzd']),
          ),
        RideSocketEventType.systemTokenExpiring => SystemTokenExpiring(
            expiresAt: payload['expiresAt'] as String,
          ),
      };
    } catch (_) {
      return null;
    }
  }

  static int _asInt(Object? value) =>
      value is int ? value : (value is num ? value.toInt() : 0);
}

// ── Driver downstream ──────────────────────────────────────────────────────

/// A request matched this driver; upsert into the available list by
/// `rideRequestId` — the server re-broadcasts every ~10 s.
final class RideBroadcast extends RideSocketEvent {
  const RideBroadcast(this.request);

  final AvailableRequestCard request;
}

/// A previously broadcast request is gone; remove the card from the list.
final class RideBroadcastCancelled extends RideSocketEvent {
  const RideBroadcastCancelled({
    required this.rideRequestId,
    required this.reason,
  });

  final String rideRequestId;
  final String reason;
}

// ── Passenger downstream ───────────────────────────────────────────────────

/// Echo confirmation that the server received the ride request.
final class RideRequested extends RideSocketEvent {
  const RideRequested({
    required this.rideRequestId,
    required this.serviceType,
    required this.femaleOnly,
    required this.proposedFare,
  });

  final String rideRequestId;
  final String serviceType;
  final bool femaleOnly;
  final int proposedFare;
}

/// The ride request was cancelled by the system (no drivers found or timeout).
final class RideRequestCancelled extends RideSocketEvent {
  const RideRequestCancelled({
    required this.rideRequestId,
    required this.reason, // NO_DRIVERS | TIMEOUT
  });

  final String rideRequestId;
  final String reason;
}

/// Live driver position; throttled to ~1 update per 5 s by the server.
/// Only emitted while the ride is between ACCEPTED and a terminal state.
final class DriverLocationUpdate extends RideSocketEvent {
  const DriverLocationUpdate({
    required this.rideId,
    required this.driverId,
    required this.lat,
    required this.lng,
    required this.capturedAt,
  });

  final String rideId;
  final String driverId;
  final double lat;
  final double lng;
  final String capturedAt;
}

// ── Shared downstream (both surfaces) ─────────────────────────────────────

/// A driver placed a bid on the passenger's ride request.
final class OfferCreated extends RideSocketEvent {
  const OfferCreated({
    required this.offerId,
    required this.rideRequestId,
    required this.driverId,
    required this.fare,
    required this.expiresAt,
  });

  final String offerId;
  final String rideRequestId;
  final String driverId;
  final int fare;
  final String expiresAt;
}

/// An offer was accepted; a `Ride` entity now exists under `rideId`.
/// `driverId` is present on the passenger surface, absent on the driver surface.
final class OfferAccepted extends RideSocketEvent {
  const OfferAccepted({
    required this.offerId,
    required this.rideRequestId,
    required this.rideId,
    required this.fare,
    this.driverId,
  });

  final String offerId;
  final String rideRequestId;
  final String rideId;
  final int fare;
  final String? driverId;
}

/// The offer ended without acceptance.
/// `reason` values: EXPLICIT_REJECT, SIBLING_ACCEPTED, REQUEST_CANCELLED,
/// DRIVER_OCCUPIED (driver surface), DRIVER_OFFLINE (driver surface).
final class OfferRejected extends RideSocketEvent {
  const OfferRejected({
    required this.offerId,
    required this.rideRequestId,
    required this.reason,
  });

  final String offerId;
  final String rideRequestId;
  final String reason;
}

/// The offer hit its 30 s server-side timeout without a passenger decision.
final class OfferExpired extends RideSocketEvent {
  const OfferExpired({
    required this.offerId,
    required this.rideRequestId,
  });

  final String offerId;
  final String rideRequestId;
}

/// The active ride transitioned to a new state.
final class RideStateChanged extends RideSocketEvent {
  const RideStateChanged({
    required this.rideId,
    required this.state,
    required this.occurredAt,
  });

  final String rideId;
  final RideState state;
  final String occurredAt;
}

/// The active ride was cancelled.
/// `actorType` values: PASSENGER, DRIVER, SYSTEM, ADMIN.
final class RideCancelled extends RideSocketEvent {
  const RideCancelled({
    required this.rideId,
    required this.actorType,
    required this.reason,
    required this.occurredAt,
  });

  final String rideId;
  final String actorType;
  final String reason;
  final String occurredAt;
}

// ── Wallet downstream (driver only) ───────────────────────────────────────

/// Common shape of every wallet event that carries the resulting balance —
/// four of the six do, letting the wallet cubit patch its tile uniformly
/// instead of refetching. `wallet.topup_rejected` moves no money, and
/// `wallet.balance_low` merely restates the balance that just changed.
sealed class WalletBalanceEvent extends RideSocketEvent {
  const WalletBalanceEvent();

  /// The balance after the move, straight from the payload.
  int get balanceDzd;
}

/// An admin approved a top-up. `creditedAmountDzd` may differ from the amount
/// the driver requested if the receipt showed something else.
final class WalletTopUpApproved extends WalletBalanceEvent {
  const WalletTopUpApproved({
    required this.topUpId,
    required this.creditedAmountDzd,
    required this.balanceDzd,
  });

  final String topUpId;
  final int creditedAmountDzd;
  @override
  final int balanceDzd;
}

/// An admin rejected a top-up; `reason` is free text meant for the driver.
final class WalletTopUpRejected extends RideSocketEvent {
  const WalletTopUpRejected({required this.topUpId, required this.reason});

  final String topUpId;
  final String reason;
}

/// A completed ride was settled. `amountDzd` is the **positive** commission
/// that was debited — the ledger row carries the signed value.
final class WalletCommissionCharged extends WalletBalanceEvent {
  const WalletCommissionCharged({
    required this.rideId,
    required this.amountDzd,
    required this.balanceDzd,
  });

  final String rideId;
  final int amountDzd;
  @override
  final int balanceDzd;
}

/// A post-accept cancellation with a driver-fault reason
/// (`DRIVER_TOO_FAR` / `DRIVER_VEHICLE_ISSUE`) charged a penalty.
final class WalletPenaltyCharged extends WalletBalanceEvent {
  const WalletPenaltyCharged({
    required this.rideId,
    required this.amountDzd,
    required this.balanceDzd,
  });

  final String rideId;
  final int amountDzd;
  @override
  final int balanceDzd;
}

/// The last debit pushed the balance under `minOnlineBalanceDzd`. May arrive
/// immediately after a commission/penalty event for the same debit — expect
/// two frames back to back. Never sent on credits, and never forces the driver
/// offline mid-session; it only warns.
final class WalletBalanceLow extends WalletBalanceEvent {
  const WalletBalanceLow({
    required this.balanceDzd,
    required this.thresholdDzd,
  });

  @override
  final int balanceDzd;
  final int thresholdDzd;
}

/// An admin manually credited or debited the wallet.
/// `direction` is `CREDIT` or `DEBIT`.
final class WalletBalanceAdjusted extends WalletBalanceEvent {
  const WalletBalanceAdjusted({
    required this.direction,
    required this.amountDzd,
    required this.balanceDzd,
  });

  final String direction;
  final int amountDzd;
  @override
  final int balanceDzd;
}

// ── System ─────────────────────────────────────────────────────────────────

/// Server warning ~2 min before JWT expiry. Respond with upstream
/// `system.auth_refresh` carrying the new token to keep the socket alive.
final class SystemTokenExpiring extends RideSocketEvent {
  const SystemTokenExpiring({required this.expiresAt});

  final String expiresAt;
}
