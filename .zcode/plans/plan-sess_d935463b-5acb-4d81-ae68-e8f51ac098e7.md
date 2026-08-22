Create a `progress/` folder with two markdown progress-tracking files based on the verified spec-vs-implementation analysis:

**1. `progress/passenger-progress.md`**
- Passenger API endpoints from `swagger/passenger.json` as a ✅/❌ checklist:
  - ✅ Addresses CRUD (list/add/update/delete)
  - ✅ Rides: create, offers list, accept/refuse offer, cancel, active, history
  - ❌ Places: search, reverse-geocode, resolve `{placeId}` (app bypasses backend, calls Nominatim directly)
  - ❌ Ride detail `GET /api/passenger/rides/{rideRequestId}` (constant exists, unused)
- Passenger WebSocket events (`swagger/websocket.json`): ✅ handled (`offer.created`, `ride.state_changed`, `ride.cancelled`, `driver.location`) vs ❌ not handled (`offer.countered`, `offer.rejected`, `offer.expired`, `ride.requested`, `ride.request_cancelled`)
- Dead code notes (unused `counterOffer` constant)

**2. `progress/driver-progress.md`**
- Driver API endpoints from `swagger/driver.json` as a ✅/❌ checklist:
  - ✅ KYC submit/status, availability online/offline, full ride lifecycle (available/bid/arrived/start/complete/cancel/active/history), full wallet (balance/transactions/topups list+submit+cancel), service-types update
  - ❌ `PUT /api/driver/profile` (not implemented at all)
  - ❌ `GET /api/driver/rides/{rideId}` ride detail (no repo method)
  - ⚠️ `POST /api/driver/location` REST — by design replaced by WS `driver.location` stream
- Driver WebSocket events: ✅ handled (`ride.broadcast`, `ride.broadcast_cancelled`, `offer.accepted`, `ride.state_changed`, `ride.cancelled`, wallet events) vs ❌ not consumed (`offer.rejected`, `offer.expired`, `offer.countered`)
- Dead code notes (unused `registration` constant)

Each file gets a summary line with counts (e.g., 9/15 done) and file references so items are easy to locate later. No code changes.