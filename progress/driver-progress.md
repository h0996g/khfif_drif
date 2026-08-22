# Driver Progress

Spec vs. app implementation status. Source: `swagger/driver.json` + `swagger/websocket.json` (driver surface).
Legend: ✅ implemented & wired to UI · ❌ not implemented · ⚠️ partial / by design

**Summary: 19/21 REST endpoints done (1 by-design WS substitution) · 8/11 WS events handled**

Last checked: 2026-08-22

---

## REST API — `swagger/driver.json`

### Profile — ✅ 2/2

| Status | Endpoint | Implementation |
|--------|----------|----------------|
| ✅ | `PUT /api/driver/profile` (update profile) | `driver_profile_repository.dart:10` → driver profile screen "Preferences" (`acceptsFemaleOnly`) toggle |
| ✅ | `PUT /api/driver/profile/service-types` | `driver_service_types_repository.dart:14` → driver profile screen |

### Location — ⚠️ by design

| Status | Endpoint | Notes |
|--------|----------|-------|
| ⚠️ | `POST /api/driver/location` | Not called as REST — GPS is streamed over WS `driver.location` every 15s while online (`driver_location_streamer.dart:91`), which is the intended transport per `websocket.json` |

### KYC — ✅ 2/2

| Status | Endpoint | Implementation |
|--------|----------|----------------|
| ✅ | `POST /api/driver/kyc/submit` (multipart) | `driver_repository.dart:56` → registration wizard step 3 |
| ✅ | `GET /api/driver/kyc/status` | `driver_repository.dart:92` → KycStatusCubit |

### Availability — ✅ 2/2

| Status | Endpoint | Implementation |
|--------|----------|----------------|
| ✅ | `POST /api/driver/availability/online` | `driver_availability_repository.dart:8` → online toggle |
| ✅ | `POST /api/driver/availability/offline` | `driver_availability_repository.dart:16` |

### Rides — ✅ 8/9

| Status | Endpoint | Implementation |
|--------|----------|----------------|
| ✅ | `GET /api/driver/rides/available` | `driver_ride_repository.dart:10` → available-rides feed |
| ✅ | `POST /api/driver/rides/{rideRequestId}/bid` | `driver_ride_repository.dart:17` |
| ✅ | `POST /api/driver/rides/{rideId}/arrived` | `driver_ride_repository.dart:25` |
| ✅ | `POST /api/driver/rides/{rideId}/start` | `driver_ride_repository.dart:33` |
| ✅ | `POST /api/driver/rides/{rideId}/complete` | `driver_ride_repository.dart:41` |
| ✅ | `POST /api/driver/rides/{rideId}/cancel` | `driver_ride_repository.dart:49` |
| ✅ | `GET /api/driver/rides/active` | `driver_ride_repository.dart:58` |
| ✅ | `GET /api/driver/rides` (history, paginated + filters) | `driver_ride_repository.dart:66` |
| ❌ | `GET /api/driver/rides/{rideId}` (ride detail) | No repository method; only list/active are used |

### Wallet — ✅ 5/5

| Status | Endpoint | Implementation |
|--------|----------|----------------|
| ✅ | `GET /api/driver/wallet` (balance + gate) | `wallet_repository.dart:17` → WalletCubit |
| ✅ | `GET /api/driver/wallet/transactions` (paginated) | `wallet_repository.dart:25` |
| ✅ | `GET /api/driver/wallet/topups` | `wallet_repository.dart:40` |
| ✅ | `POST /api/driver/wallet/topups` (multipart, receipt) | `wallet_repository.dart:89` → top-up sheet |
| ✅ | `POST /api/driver/wallet/topups/{id}/cancel` | `wallet_repository.dart:98` |

---

## WebSocket — `swagger/websocket.json` (`/ws/driver`)

### Server → driver

| Status | Event | Notes |
|--------|-------|-------|
| ✅ | `ride.broadcast` | `available_rides_cubit.dart:76` — new request card |
| ✅ | `ride.broadcast_cancelled` | `available_rides_cubit.dart:78` |
| ✅ | `offer.accepted` | `available_rides_cubit.dart:80` — bid won |
| ✅ | `ride.state_changed` | `driver_active_ride_cubit.dart:23` |
| ✅ | `ride.cancelled` | `driver_active_ride_cubit.dart:25` |
| ✅ | `wallet.topup_approved` / `wallet.topup_rejected` / `wallet.balance_low` | `wallet_cubit.dart:135-156` |
| ✅ | `wallet.commission_charged` / `wallet.penalty_charged` / `wallet.balance_adjusted` | Via `WalletBalanceEvent` catch-all, `wallet_cubit.dart:135-156` |
| ❌ | `offer.countered` | Not parsed, not handled |
| ❌ | `offer.rejected` | Parsed in `ride_socket_event.dart` but no cubit consumes it — driver never learns a bid was rejected |
| ❌ | `offer.expired` | Parsed but unused — bid cards go stale silently |

### Client → server

| Status | Event | Notes |
|--------|-------|-------|
| ✅ | `driver.location` | `driver_location_streamer.dart:91` — every 15s while online |
| ✅ | `system.auth_refresh` | `ride_socket_service.dart:264` — replies to token-expiring warning |

---

## Dead code (in app, not in spec)

- ❌ `POST /api/driver/registration` — constant at `driver_api_constants.dart:7`, never referenced; onboarding goes through KYC submit.

## Feature gaps (not in spec either)

- ❌ Ratings — no submit endpoint for passengers to rate drivers (or vice versa); not in `driver.json` either.
- ❌ Earnings screen — no dedicated endpoint; earnings are inferred from wallet transactions/commission events.
