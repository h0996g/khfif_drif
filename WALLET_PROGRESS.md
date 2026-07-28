# Driver Wallet — Implementation Progress

**Status:** 🟢 Code complete — awaiting end-to-end verification against a live backend
**Spec:** [integration/epic-04-wallet.md](integration/epic-04-wallet.md) · [swagger/driver.json](swagger/driver.json) (`Driver Wallet` tag)
**Legend:** `[x]` done · `[ ]` pending

---

## Overview

The wallet holds the **driver's pre-paid platform commission** — it is *not* fare payment. Rides stay
cash: the passenger pays the driver in the car. Only the **driver app** has a wallet surface; the admin
side (top-up queue, approve/reject/adjust) is a separate web dashboard and is **out of scope here**.

Core rules that shape the client:

- All amounts are **whole DZD integers** (`2000` = 2000 DZD). No decimals, no minor units.
- **REST is truth, WS is hints.** On every (re)connect, refetch `GET /api/driver/wallet` (+ transactions,
  top-ups) and reconcile, then let WS drive incremental updates.
- **Negative balance is valid** — it's driver debt, not a bug. Never validate against it client-side.
- **409 means "your view is stale"** — refetch and re-render, don't show an error dialog.
- The wallet **gates the ride flow**: below `minOnlineBalanceDzd`, go-online and bidding return `403`.

---

## Backend contract

### REST — `/api/driver/wallet`

| Method | Path | Returns | Notes |
|---|---|---|---|
| `GET` | `/api/driver/wallet` | `WalletBalanceResponse` | `{ balanceDzd, minOnlineBalanceDzd, belowGate }`. Get-or-create — a fresh driver reads `0`, never `404`. |
| `GET` | `/api/driver/wallet/transactions?page&size` | `PageResponse<WalletTransactionResponse>` | Newest-first. `amountDzd` is **signed** (negative = debit). |
| `POST` | `/api/driver/wallet/topups` | `201 TopUpResponse` (`PENDING`) | **`multipart/form-data`**: `amountDzd` (string), `channel` (`CASH`\|`BANK_TRANSFER`), `receipt` (file, required — jpeg/png/pdf, ≤5 MB). |
| `GET` | `/api/driver/wallet/topups?status&page&size` | `PageResponse<TopUpResponse>` | Own history. `status` filter optional. |
| `POST` | `/api/driver/wallet/topups/{id}/cancel` | `204` | Only while `PENDING`. |

**Models**

- `WalletBalanceResponse` — `balanceDzd`, `minOnlineBalanceDzd`, `belowGate`
- `WalletTransactionResponse` — `id`, `type`, `amountDzd` (signed), `balanceAfterDzd`, `sourceType`,
  `sourceRef`, `note`, `createdAt`
  - `type` ∈ `TOPUP_CREDIT` · `RIDE_COMMISSION` · `RIDE_CANCEL_PENALTY` · `ADMIN_CREDIT` · `ADMIN_DEBIT` · `STARTING_CREDIT`
- `TopUpResponse` — `id`, `amountDzd`, `channel`, `status`, `creditedAmountDzd?`, `decisionReason?`,
  `createdAt`, `decidedAt?`
  - `status` ∈ `PENDING` · `APPROVED` · `REJECTED` · `CANCELLED` (all three exits terminal)
  - `channel` ∈ `CASH` · `BANK_TRANSFER`
- `PageResponse<T>` — `{ data, page, size, totalElements, totalPages }`

**Top-up state machine** — `PENDING → APPROVED | REJECTED | CANCELLED`. Only **one `PENDING` per driver**
at a time (a second submit 409s).

### WebSocket — same `/ws/driver` socket, downstream only

> Reuses the existing connection and `{ type, payload, timestamp, clientMessageId }` envelope.
> **Do not open a second socket.** There are no upstream wallet messages.

| `type` | `payload` |
|---|---|
| `wallet.topup_approved` | `{ topUpId, creditedAmountDzd, balanceDzd }` |
| `wallet.topup_rejected` | `{ topUpId, reason }` |
| `wallet.commission_charged` | `{ rideId, amountDzd, balanceDzd }` — `amountDzd` **positive**, the debit amount |
| `wallet.penalty_charged` | `{ rideId, amountDzd, balanceDzd }` |
| `wallet.balance_low` | `{ balanceDzd, thresholdDzd }` — may arrive **immediately after** a charge event for the same debit; expect two back-to-back |
| `wallet.balance_adjusted` | `{ direction, amountDzd, newBalanceDzd }` |

### Error codes

| Code | HTTP | Client behaviour |
|---|---|---|
| `INSUFFICIENT_WALLET_BALANCE` | 403 | On go-online / bid → prompt to top up (don't show a raw error). |
| `TOPUP_BELOW_MINIMUM` | 400 | Show the minimum inline from the error `details`. |
| `TOPUP_RECEIPT_REQUIRED` | 400 | Missing / >5 MB / wrong mime — validate before enabling submit. |
| `TOPUP_PENDING_EXISTS` | 409 | Route to the existing pending request instead of the form. |
| `TOPUP_NOT_PENDING` | 409 | Refetch and re-render — view is stale. |
| `TOPUP_NOT_FOUND` | 404 | Refetch the list. |
| `STORAGE_UNAVAILABLE` | 503 | Retry; "receipt storage temporarily unavailable". |

---

## Phase 0 — Error codes reach the caller

`DioClient` threw a bare `String`, discarding the `code` from the error envelope, so nothing could branch
on `TOPUP_PENDING_EXISTS` or `INSUFFICIENT_WALLET_BALANCE` without sniffing message text.

- [x] `lib/core/errors/api_exception.dart` — `ApiException { message, code, statusCode }` whose
      `toString()` returns the bare message, so all pre-existing `catch (e) => e.toString()` sites are
      unchanged.
- [x] `DioClient._handleDioError` returns `ApiException` instead of `String`.
- [x] `WalletErrorCodes` constants in `wallet_api_constants.dart` — no code branches on a literal.

## Phase 1 — Data layer

- [x] `lib/core/constants/wallet_api_constants.dart` — `abstract final class` + private ctor, mirroring
      [driver_api_constants.dart](lib/core/constants/driver_api_constants.dart). `_base = '/api/driver/wallet'`;
      constants for `balance`, `transactions`, `topups`, and a `topUpCancel(String id)` helper.
- [x] `lib/features/wallet/driver/data/models/wallet_models.dart`
  - [x] `WalletBalance` (`fromJson`)
  - [x] `WalletTransaction` + `WalletTransactionType` enum (wire-name lookup, unknown → fallback)
  - [x] `TopUpRequest` + `TopUpStatus` + `TopUpChannel` enums
  - [x] Generic `PageResponse<T>` with an item-parser callback — pattern from
        [driver_ride_history_models.dart](lib/features/ride/driver/data/models/driver_ride_history_models.dart)
- [x] `lib/features/wallet/driver/data/wallet_repository.dart` — `const` class over `DioClient`:
  - [x] `getBalance()`
  - [x] `getTransactions({page, size})`
  - [x] `submitTopUp({amountDzd, channel, receiptPath})` via
        [`DioClient.postMultipart`](lib/core/network/dio_client.dart#L298) + `FormData`/`MultipartFile`
  - [x] `getTopUps({status, page, size})`
  - [x] `cancelTopUp(id)`

> Note: the Dio idempotency interceptor still attaches an `Idempotency-Key` to `POST /topups` (it only
> skips `/api/auth/*`). Harmless — the server ignores it; rely on the `TOPUP_PENDING_EXISTS` 409 instead
> of client-side dedupe.

## Phase 2 — WebSocket events

- [x] Add the 6 wire names to `RideSocketEventType` in
      [ride_socket_event.dart](lib/features/ride/driver/data/models/ride_socket_event.dart)
- [x] Add 6 sealed `RideSocketEvent` subclasses (`WalletTopUpApproved`, `WalletTopUpRejected`,
      `WalletCommissionCharged`, `WalletPenaltyCharged`, `WalletBalanceLow`, `WalletBalanceAdjusted`)
- [x] Add the matching `tryParse` branches
- [x] Fix exhaustiveness in every existing `switch` over the sealed class (available rides, active ride,
      passenger cubits) — they must ignore wallet events, not crash

## Phase 3 — State (Cubits)

- [x] `WalletCubit` + `WalletState` under `lib/features/wallet/driver/presentation/cubit/wallet_cubit/`
  - [x] Loads balance + first transaction page
  - [x] Subscribes to `RideSocketService.frameStream`, applies the 6 wallet events (update balance from
        the payload — no refetch)
  - [x] Refetches on `RideSocketStatus.connected`, mirroring `_onStatus` in
        [available_rides_cubit.dart](lib/features/ride/driver/presentation/cubit/available_rides_cubit/available_rides_cubit.dart)
  - [x] Exposes `belowGate` for the availability toggle
  - [x] Provided at the **driver `ShellRoute`** level in [app_router.dart](lib/core/router/app_router.dart#L280)
        so balance/gate survives navigation and is shared with the home screen
- [x] `TopUpCubit` + `TopUpState` — form (amount, channel, picked receipt), submit, cancel, history paging,
      `TOPUP_PENDING_EXISTS` handling

## Phase 4 — UI

- [x] `lib/features/wallet/driver/presentation/views/driver_wallet_view.dart`
  - [x] Balance tile (whole DZD, negative rendered as debt)
  - [x] Gate banner when `belowGate` — "Top up to go online" + CTA
  - [x] Pending top-up card with a cancel action
  - [x] Transaction list: signed amounts (debit red / credit green), type label, `balanceAfterDzd`, date
  - [x] Pagination / infinite scroll + pull-to-refresh
- [x] `top_up_form_view.dart` — amount field, `CASH`/`BANK_TRANSFER` selector, receipt picker
      (jpeg/png/pdf, ≤5 MB — reuse the image helper in `lib/core/utils/`), submit + inline errors
- [x] `top_up_history_view.dart` (or a tab on the wallet view) with a status filter
- [x] Routes `driverWallet`, `driverTopUp`, `driverTopUpHistory` in
      [route_names.dart](lib/core/router/route_names.dart) + `GoRoute`s inside the driver shell
- [x] Wire the drawer: rename the dead `'Earnings'` item to `Wallet` and give it a real branch in
      `_onMenuItemTap` / the highlight switch
      ([driver_home_drawer.dart:39](lib/features/home/driver/presentation/views/widgets/driver_home_drawer.dart#L39))
- [ ] Optional: small balance chip on the driver home screen *(not done — the drawer entry and the
      gate hint on the availability toggle already surface it)*

## Phase 5 — Balance-gate integration (ride flow)

- [x] Disable / gray out the go-online toggle when `belowGate`, with a "Top up" CTA
      ([driver_availability_toggle_widget.dart](lib/features/ride/driver/presentation/views/widgets/driver_availability_toggle_widget.dart))
- [x] Handle `403 INSUFFICIENT_WALLET_BALANCE` on **go-online**
      ([driver_availability_cubit.dart](lib/features/ride/driver/presentation/cubit/driver_availability_cubit/driver_availability_cubit.dart))
      → top-up prompt, not a raw toast
- [x] Handle the same 403 on **bid submit**
- [x] After `ride .../complete` or a driver-fault `ride .../cancel`, update the balance from the incoming
      `wallet.commission_charged` / `wallet.penalty_charged` event — **no polling**
- [x] Surface `wallet.balance_low` as a non-blocking warning (there is **no** mid-session force-offline)

## Phase 6 — Verification

- [x] `flutter analyze` clean (only the 9 pre-existing infos remain)
- [x] `flutter build apk --debug` succeeds
- [ ] Fresh driver: `GET /wallet` → `balanceDzd: 0`, `belowGate: true`, go-online disabled
- [ ] Submit top-up with receipt → `201 PENDING`; a second submit → 409 routes to the pending request
- [ ] Cancel pending → `204`, list refreshes
- [ ] Admin approves out of band → `wallet.topup_approved` lands, balance tile updates with no manual refresh
- [ ] Go-online now succeeds
- [ ] Complete a ride → `wallet.commission_charged` (+ possibly `wallet.balance_low`) updates the tile
- [ ] Ledger renders debits negative and credits positive, paging works

---

## Notes / open questions

- **`topup.min-dzd` is not exposed** by any driver endpoint — it's only discoverable from the `details` of
  a `TOPUP_BELOW_MINIMUM` 400. Either hardcode a hint or ask backend for a config endpoint.
- **Admin surface out of scope** — `/api/admin/wallet/**` (queue, approve, reject, adjust) belongs to the
  web dashboard.
- **Commission & penalty are never driver-initiated.** There is no "charge commission" call — the backend
  reacts to ride completion / driver-fault cancellation and pushes the result.
- Only `DRIVER_TOO_FAR` / `DRIVER_VEHICLE_ISSUE` cancellations on an `ACCEPTED` ride charge a penalty.
