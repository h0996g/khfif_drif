# Passenger Progress

Spec vs. app implementation status. Source: `swagger/passenger.json` + `swagger/websocket.json` (passenger surface).
Legend: ✅ implemented & wired to UI · ❌ not implemented · ⚠️ partial / note

**Summary: 9/15 REST endpoints done · 4/9 WS events handled**

Last checked: 2026-08-22

---

## REST API — `swagger/passenger.json`

### Places — ❌ 0/3 (bypassed: app calls Nominatim directly)

| Status | Endpoint | Notes |
|--------|----------|-------|
| ❌ | `GET /api/passenger/places/search` | App queries Nominatim instead (`lib/features/ride/passenger/presentation/cubit/location_cubit/location_picker_cubit.dart:14`) |
| ❌ | `GET /api/passenger/places/reverse-geocode` | Same — Nominatim used directly |
| ❌ | `GET /api/passenger/places/{placeId}` | No implementation at all |

### Addresses — ✅ 4/4

| Status | Endpoint | Implementation |
|--------|----------|----------------|
| ✅ | `GET /api/passenger/addresses` | `address_repository.dart:9` → SavedPlacesCubit + location picker favorites |
| ✅ | `POST /api/passenger/addresses` | `address_repository.dart:17` → address create screen |
| ✅ | `PUT /api/passenger/addresses/{id}` | `address_repository.dart:25` → address edit screen |
| ✅ | `DELETE /api/passenger/addresses/{id}` | `address_repository.dart:33` → delete confirm on card |

### Rides — ✅ 7/8

| Status | Endpoint | Implementation |
|--------|----------|----------------|
| ✅ | `POST /api/passenger/rides` (create) | `passenger_ride_repository.dart:10` |
| ✅ | `GET /api/passenger/rides/active` | `passenger_ride_repository.dart:58` |
| ✅ | `GET /api/passenger/rides/{rideRequestId}/offers` | `passenger_ride_repository.dart:18` → waiting-offers screen (REST poll + WS trigger) |
| ✅ | `POST /api/passenger/rides/{rideRequestId}/offers/{offerId}/accept` | `passenger_ride_repository.dart:25` |
| ✅ | `POST /api/passenger/rides/{rideRequestId}/offers/{offerId}/refuse` | `passenger_ride_repository.dart:36` |
| ✅ | `POST /api/passenger/rides/{rideRequestId}/cancel` | `passenger_ride_repository.dart:47` |
| ✅ | `GET /api/passenger/rides` (history, paginated + filters) | `passenger_ride_repository.dart:64` |
| ❌ | `GET /api/passenger/rides/{rideRequestId}` (ride detail) | Constant exists (`ride_api_constants.dart:18`) but no repository method or screen uses it |

---

## WebSocket — `swagger/websocket.json` (`/ws/passenger`)

| Status | Event (server → client) | Notes |
|--------|--------------------------|-------|
| ✅ | `offer.created` | `waiting_offers_cubit.dart:30` — triggers REST repoll |
| ✅ | `ride.state_changed` | `passenger_active_ride_cubit.dart:70` |
| ✅ | `ride.cancelled` | `passenger_active_ride_cubit.dart:72` |
| ✅ | `driver.location` | `passenger_active_ride_cubit.dart:74` — live driver position |
| ❌ | `offer.countered` | Not parsed, not handled (no counter-offer feature) |
| ❌ | `offer.rejected` | Parsed in `ride_socket_event.dart` but no cubit consumes it |
| ❌ | `offer.expired` | Parsed in `ride_socket_event.dart` but no cubit consumes it |
| ❌ | `ride.requested` | Parsed but unused |
| ❌ | `ride.request_cancelled` | Parsed but unused |

Client → server: no passenger-side emits required by spec.

---

## Dead code (in app, not in spec)

- ❌ `POST /api/passenger/rides/{rideRequestId}/counter-offer` — constant at `ride_api_constants.dart:15`, never called, and endpoint doesn't exist in `passenger.json`.

## Feature gaps (not in spec either)

- ❌ Ratings — no submit/list endpoint in spec or app; `driverRatingAvg` is display-only on offer cards.
