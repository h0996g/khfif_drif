# Admin Configuration Catalogue

Everything an operator should be able to change from the admin panel — without a backend deploy or a new app release.

Two sections:

1. **Already configurable** — the backend already supports these. The admin panel just needs to show them.
2. **Should be configurable but isn't** — currently hardcoded, undocumented, or missing entirely.

Every setting has a plain explanation and a worked example.

---

# Section 1 — Already configurable

These live under `vtc.admin.configuration.*` on the backend and are documented in [epic-03-ride.md](swagger/epic-03-ride.md) §7. They can already change at runtime.

| Key                                          | Default | What it controls                                           |
| -------------------------------------------- | ------- | ---------------------------------------------------------- |
| `negotiation.no-driver-grace-s`              | 60 s    | "Searching…" time when zero drivers matched                |
| `negotiation.global-expiry-s`                | 300 s   | Total time the passenger can keep negotiating              |
| `negotiation.driver-response-timeout-s`      | 30 s    | How long a driver's bid stays alive                        |
| `negotiation.max-concurrent-bids-per-driver` | 3       | How many rides a driver can bid on at once                 |
| `ride.accepted-timeout-s`                    | 120 s   | Driver accepted but never arrived → auto-cancel            |
| `ride.arrival-wait-s`                        | 300 s   | Wait before the driver can claim a no-show                 |
| `ride.in-progress-cap-h`                     | 6 h     | Trip running too long → admin alert                        |
| `ride.cancellation-cooldown-s`               | 30 s    | Wait before a passenger can request again after cancelling |
| `matching.broadcast-radius-km`               | 10 km   | How far out drivers get notified                           |
| `matching.rebroadcast-interval`              | 10 s    | How often the request is re-sent to new drivers            |
| `location.tracking-broadcast-min-interval-s` | 5 s     | How often the passenger sees the driver marker move        |
| `fare.min-proposed-fare-dzd`                 | 150     | Lowest price a passenger may offer                         |
| `fare.counter-band-percent`                  | ±50 %   | How far a driver's bid may stray from the offer            |
| `min-online-balance-dzd`                     | —       | Wallet balance required to go online                       |
| `topup.min-dzd`                              | —       | Smallest allowed top-up                                    |
| `rate-limit.ws-msg-per-sec`                  | 20      | Anti-spam limit on the socket                              |

---

## Ride request timing

### `negotiation.no-driver-grace-s` — 60 seconds

How long the passenger sees "Searching for drivers…" when **no driver matched at all**, before the request auto-cancels with "No drivers available".

**Example:** Set it to `120`. A passenger requesting a ride at 2am in a quiet neighbourhood now waits 2 minutes instead of 1 — giving a driver time to come online and get picked up by the re-broadcast. The cost: when there genuinely is nobody, they stare at a spinner twice as long before giving up.

---

### `negotiation.global-expiry-s` — 300 seconds

The total negotiation window once at least one driver is bidding. When it runs out, the whole request is cancelled even if bids are still arriving.

**Example:** A passenger offers 400 DZD. Drivers bid 600, then 550, then 500. The passenger keeps waiting for a cheaper bid. At 5 minutes the request dies and they must start over. Raise to `600` and haggling gets twice as long — better price discovery, but drivers hold bids longer and the passenger's screen sits busy.

---

### `negotiation.driver-response-timeout-s` — 30 seconds

How long a single driver's bid stays live before it expires and disappears from the passenger's list.

**Example:** Driver bids 500 DZD at 10:00:00. The passenger has until 10:00:30 to tap Accept. At 10:00:31 the offer greys out and the driver is free to bid elsewhere. Raise to `60` and passengers get more time to compare — but a driver who bid and moved on is tied up for a full minute.

---

### `negotiation.max-concurrent-bids-per-driver` — 3

How many different ride requests one driver can have live bids on simultaneously.

**Example:** A driver at a busy intersection sees 5 requests. They bid on 3. The 4th attempt is rejected with `MAX_BIDS_REACHED`. Raise to `5` and drivers can cast a wider net — but more passengers end up accepting a bid from a driver who has already taken another ride.

---

### `ride.accepted-timeout-s` — 120 seconds

After a passenger accepts a bid, how long the driver has to mark themselves as arrived before the system cancels the ride.

**Example:** Passenger accepts at 10:00. The driver is 8 minutes away but never taps "I've arrived". At 10:02 the system cancels and the passenger is dumped back to the request screen. **This default is too short for real trips** — a driver 5 km away can't physically arrive in 2 minutes. Consider `900` (15 min) unless the intent is that drivers tap "arrived" only when actually there.

---

### `ride.arrival-wait-s` — 300 seconds

After the driver marks "arrived", how long they must wait before they're allowed to cancel for passenger no-show.

**Example:** Driver arrives at 10:00 and taps Arrived. The passenger doesn't come down. At 10:03 the driver tries to cancel — rejected with `ARRIVAL_GRACE_NOT_ELAPSED`. At 10:05 the cancel goes through, no penalty. Lower to `180` and drivers stop waiting sooner; raise to `600` and passengers get more slack but drivers waste time.

---

### `ride.in-progress-cap-h` — 6 hours

How long a trip may run before it raises an admin alert. **Does not auto-cancel** — it's a monitoring signal only.

**Example:** A driver forgets to tap "Complete" after dropping off. Six hours later the ride still shows as in-progress and the ops team gets flagged to close it manually. For a city app, `3` would catch stuck rides much sooner.

---

### `ride.cancellation-cooldown-s` — 30 seconds

After cancelling a request, how long the passenger must wait before creating a new one.

**Example:** A passenger cancels because the bids are too high, then immediately requests again hoping for cheaper drivers. For 30 seconds they get `RIDE_CREATE_COOLDOWN`. This stops request-spam that would flood the same drivers repeatedly. Raise to `120` if you see abuse.

---

## Matching

### `matching.broadcast-radius-km` — 10 km

The radius around the pickup point within which drivers are notified.

**Example:** Pickup in central Algiers with `10`, roughly 40 drivers get the request. Drop to `5` and maybe 15 do — fewer bids but all from drivers who can arrive quickly. Raise to `20` and you get more bids, but half are from drivers 25 minutes out who the passenger will never accept.

---

### `matching.rebroadcast-interval` — 10 seconds

How often an unmatched request is re-sent to newly eligible drivers (ones who just came online, finished a ride, or moved into range).

**Example:** A passenger requests at 10:00:00 and 3 drivers are notified. At 10:00:10 two more drivers came online — they get it too. At 10:00:20, one more. The passenger's bid list grows over the 5-minute window. Raise to `30` and the list fills more slowly; lower to `5` and the server does 6× the matching work.

---

### `location.tracking-broadcast-min-interval-s` — 5 seconds

How often the passenger's map updates the driver's position.

**Example:** At `5`, the driver marker jumps roughly every 5 seconds — smooth enough to feel live. Raise to `15` and the car appears to teleport between positions; the passenger thinks the app is frozen. Lower to `2` and it's very smooth but the server pushes 2.5× the messages.

Note this is separate from how often the **driver's phone sends** its GPS — see `location.driver-upstream-interval-s` in Section 2e.

---

## Fare bounds

### `fare.min-proposed-fare-dzd` — 150

The lowest price a passenger is allowed to offer.

**Example:** A passenger tries to offer 80 DZD for a 6 km trip. Rejected with `FARE_OUT_OF_BOUNDS`. Raising this to `250` prevents lowball offers that no driver will ever take — every request that gets through has a realistic chance of being served.

---

### `fare.counter-band-percent` — ±50 %

How far a driver's bid may sit above or below the passenger's proposed fare. Hard floor 100 DZD, hard ceiling 50 000 DZD.

**Example:** The passenger offers 400 DZD. Drivers may bid anywhere from 200 to 600. A driver who tries 700 gets `FARE_OUT_OF_BOUNDS`. Tighten to `25 %` and bids land between 300–500 — negotiation is faster and closer to the ask, but drivers can't price a genuinely long trip properly.

---

## Wallet gate

### `min-online-balance-dzd`

The wallet balance a driver must have before they can go online or place a bid.

**Example:** Set to `500`. A driver with 480 DZD taps "Go Online" and is blocked with `INSUFFICIENT_WALLET_BALANCE` and a prompt to top up. This is the main lever for guaranteeing the platform can collect its commission. Set too high and new drivers can't start working.

This is the one setting already correctly sent to the app, as `minOnlineBalanceDzd` on `GET /api/driver/wallet` — every other setting should follow this pattern.

---

### `topup.min-dzd`

The smallest top-up a driver may submit.

**Example:** At `1000`, a driver submitting a 500 DZD bank receipt is rejected with `TOPUP_BELOW_MINIMUM`. This keeps admins from manually reviewing dozens of tiny top-up receipts.

---

### `rate-limit.ws-msg-per-sec` — 20

Maximum messages a single app can push over its WebSocket per second.

**Example:** A buggy or modified client sends location updates in a tight loop. After 20 messages in one second the server closes the socket with code `4002`. This is a safety limit — normal use is well under 1 message per second.

---

# Section 2 — Should be configurable but isn't

---

## 2a. Fare estimation — doesn't exist at all

**This is the biggest gap in the app.** Today the passenger types a price into an empty box hinted `e.g. 1000`. There is no calculation anywhere — not on the client, not on the server. A first-time user has no idea whether a 4 km trip is worth 200 or 2000 DZD, so they guess, get rejected as too low, and give up.

Adding a server-computed suggestion needs four numbers:

| Key                       | Suggested | What it does                          |
| ------------------------- | --------- | ------------------------------------- |
| `fare.suggested-base-dzd` | 150       | Flat amount on every trip             |
| `fare.per-km-dzd`         | 25        | Added per kilometre of distance       |
| `fare.per-minute-dzd`     | 5         | Added per minute of expected duration |
| `fare.rounding-step-dzd`  | 10        | Round the result to a clean number    |

### Worked example

A 3 km trip expected to take 10 minutes:

```
base                  150
+ 3 km  × 25         = 75
+ 10 min × 5         = 50
                    ----
                      275  → rounded to 280
```

The passenger sees **"Suggested: 280 DZD"** pre-filled in the box instead of an empty field. They can still change it — this is a negotiation app — but they start from a realistic number.

Same trip at rush hour with a 1.4 multiplier applied on top: `280 × 1.4 = 392 → 390`. That gives an obvious later extension (`fare.surge-multiplier`) once the basic formula is in place.

Tuning these four numbers is how you set the platform's overall price level per city — the single most useful thing an admin can control.

---

## 2b. Money — charged today, but the amount is invisible

These amounts **are already being deducted** from driver wallets. The problem is that no endpoint or document states what they are — a driver only discovers the number from a `wallet.commission_charged` event _after_ the money is gone.

| Key                               | Suggested | What it does                                  |
| --------------------------------- | --------- | --------------------------------------------- |
| `commission.rate-percent`         | 10 %      | Platform's cut of each completed ride         |
| `cancellation.penalty-dzd`        | 50        | Charged when a driver cancels after accepting |
| `wallet.starting-credit-dzd`      | 500       | Free credit for a newly approved driver       |
| `topup.max-dzd`                   | 50 000    | Largest allowed top-up                        |
| `wallet.max-negative-balance-dzd` | −2000     | How deep into debt a driver may go            |

### `commission.rate-percent` — 10 %

**Example:** A driver completes a 600 DZD ride. At `10 %`, 60 DZD is deducted, leaving them 540. Raise to `15 %` and it's 90 DZD. This is the most sensitive number in the whole system — drivers notice a change within one shift. It should also be settable **per service type**, since delivery margins differ from rides.

### `cancellation.penalty-dzd` — 50

**Example:** A driver accepts a ride, realises the pickup is across town, and cancels with `DRIVER_TOO_FAR`. 50 DZD leaves their wallet. Today the driver has no way to know this cost 50 until it's charged — the app can't warn them. Worth pairing with a **free-cancel window** (say 60 seconds after accepting) so an honest mistake isn't punished.

### `wallet.starting-credit-dzd` — 500

**Example:** A driver's KYC is approved. They get 500 DZD credited so they can go online immediately without topping up first — a meaningful onboarding boost. The `STARTING_CREDIT` transaction type already exists in the ledger; the amount is documented nowhere.

### `topup.max-dzd` — 50 000

**Example:** A driver submits a 500 000 DZD top-up receipt. There is currently **no upper limit at all**, so this reaches an admin for approval. A cap makes fraudulent or mistyped receipts fail immediately.

### `wallet.max-negative-balance-dzd` — −2000

Negative balances are deliberately allowed — that's driver debt, not a bug. But there is **no floor**.

**Example:** A driver's balance is −1800 after several commissions. At `−2000` they can still work; one more ride takes them to −2100 and they're blocked from going online until they settle. Without this, debt can grow without limit and is unlikely to ever be recovered.

---

## 2c. KYC

| Key                            | Suggested                    | What it does                         |
| ------------------------------ | ---------------------------- | ------------------------------------ |
| `kyc.max-document-size-bytes`  | 5 MB                         | Upload size cap                      |
| `kyc.driver-min-age-years`     | 18                           | Minimum driver age                   |
| `kyc.license-expiry-warn-days` | 30                           | Days before expiry to require re-KYC |

### `kyc.max-document-size-bytes` — 5 MB

**Example:** A driver photographs their licence on a 108 MP phone camera and the file is 12 MB. Rejected. This limit is currently hardcoded in the app _and_ enforced on the server — if either changes, they silently disagree.

### `kyc.driver-min-age-years` — 18

**Example:** An applicant born in 2010 can't pick their real date of birth, because the date picker's upper bound is set 18 years back. But this is enforced **only in the UI** — there is no server check and no error code, so any client that skips the picker gets through. Should be a server rule.

### `kyc.license-expiry-warn-days` — 30

**Example:** A driver's licence expires on 1 September. At `30`, they start seeing "Re-submit your licence" from 2 August and the `requiresRekyc` flag flips. At 0 days they'd be cut off with no warning on the day it expires. Same setting applies to insurance expiry.

