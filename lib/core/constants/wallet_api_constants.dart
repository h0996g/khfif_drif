/// Driver wallet REST paths (`Driver Wallet` tag in swagger/driver.json).
///
/// The admin surface (`/api/admin/wallet/**`) is a separate web dashboard and
/// has no place in this app.
abstract final class WalletApiConstants {
  WalletApiConstants._();

  static const String _base = '/api/driver/wallet';

  /// `GET` — balance + gate status. Get-or-create: a freshly KYC'd driver
  /// reads `0` rather than a `404`.
  static const String balance = _base;

  /// `GET` — the signed ledger, newest-first, paginated.
  static const String transactions = '$_base/transactions';

  /// `GET` — the driver's own top-up requests.
  /// `POST` — submit a new one (`multipart/form-data`, receipt required).
  static const String topUps = '$_base/topups';

  /// `POST` — cancel a request while it is still `PENDING`.
  static String cancelTopUp(String id) => '$_base/topups/$id/cancel';
}

/// Wallet error codes from the API error envelope, so nothing branches on
/// message text. See integration/epic-04-wallet.md §10.
abstract final class WalletErrorCodes {
  WalletErrorCodes._();

  /// `403` on go-online or bid while below `minOnlineBalanceDzd`.
  static const String insufficientBalance = 'INSUFFICIENT_WALLET_BALANCE';

  /// `400` — the submitted amount is under the server's configured minimum.
  static const String topUpBelowMinimum = 'TOPUP_BELOW_MINIMUM';

  /// `400` — receipt missing, over 5 MB, or of an unsupported mime type.
  static const String topUpReceiptRequired = 'TOPUP_RECEIPT_REQUIRED';

  /// `409` — the driver already has a `PENDING` request (only one at a time).
  static const String topUpPendingExists = 'TOPUP_PENDING_EXISTS';

  /// `409` — cancel on an already-decided request; the view is stale.
  static const String topUpNotPending = 'TOPUP_NOT_PENDING';

  /// `404` — unknown top-up id.
  static const String topUpNotFound = 'TOPUP_NOT_FOUND';

  /// `503` — receipt storage (MinIO) unreachable.
  static const String storageUnavailable = 'STORAGE_UNAVAILABLE';
}
