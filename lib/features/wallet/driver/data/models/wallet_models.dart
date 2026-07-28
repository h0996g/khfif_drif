/// Models for the driver wallet (`Driver Wallet` tag in swagger/driver.json).
///
/// All money is a **whole DZD integer** — no decimals, no minor units. Ledger
/// amounts are **signed**: negative for debits. A negative balance is valid and
/// expected (it is driver debt), so nothing here guards against it.
library;

/// `GET /api/driver/wallet` — balance plus the go-online gate status.
final class WalletBalance {
  const WalletBalance({
    required this.balanceDzd,
    required this.minOnlineBalanceDzd,
    required this.belowGate,
  });

  const WalletBalance.zero()
      : balanceDzd = 0,
        minOnlineBalanceDzd = 0,
        belowGate = false;

  final int balanceDzd;
  final int minOnlineBalanceDzd;

  /// Server-computed: below this, go-online and bidding return `403`.
  final bool belowGate;

  /// How much a top-up needs to clear to lift the gate. `0` when not gated.
  int get shortfallDzd =>
      belowGate ? (minOnlineBalanceDzd - balanceDzd).clamp(0, 1 << 31) : 0;

  /// Applies a balance pushed over the socket. The threshold isn't repeated in
  /// those payloads, so it is carried over and the gate recomputed locally —
  /// the next REST refetch re-establishes the server's own verdict.
  WalletBalance withBalance(int newBalanceDzd) => WalletBalance(
        balanceDzd: newBalanceDzd,
        minOnlineBalanceDzd: minOnlineBalanceDzd,
        belowGate: newBalanceDzd < minOnlineBalanceDzd,
      );

  factory WalletBalance.fromJson(Map<String, dynamic> json) => WalletBalance(
        balanceDzd: _asInt(json['balanceDzd']),
        minOnlineBalanceDzd: _asInt(json['minOnlineBalanceDzd']),
        belowGate: json['belowGate'] as bool? ?? false,
      );
}

/// Ledger entry kinds. Unrecognised server values fall back to [unknown] so a
/// newly added type can never blank the ledger.
enum WalletTransactionType {
  topUpCredit('TOPUP_CREDIT', 'Top-up'),
  rideCommission('RIDE_COMMISSION', 'Ride commission'),
  rideCancelPenalty('RIDE_CANCEL_PENALTY', 'Cancellation penalty'),
  adminCredit('ADMIN_CREDIT', 'Admin credit'),
  adminDebit('ADMIN_DEBIT', 'Admin debit'),
  startingCredit('STARTING_CREDIT', 'Starting credit'),
  unknown('', 'Transaction');

  const WalletTransactionType(this.wireName, this.label);

  final String wireName;
  final String label;

  static WalletTransactionType fromWire(String? value) {
    for (final type in values) {
      if (type.wireName == value) return type;
    }
    return unknown;
  }
}

/// A single row of the signed ledger.
final class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.type,
    required this.amountDzd,
    required this.balanceAfterDzd,
    required this.createdAt,
    this.sourceType,
    this.sourceRef,
    this.note,
  });

  final String id;
  final WalletTransactionType type;

  /// Signed: negative for debits (commission, penalty, admin debit).
  final int amountDzd;
  final int balanceAfterDzd;
  final String createdAt;
  final String? sourceType;
  final String? sourceRef;
  final String? note;

  bool get isCredit => amountDzd >= 0;

  factory WalletTransaction.fromJson(Map<String, dynamic> json) =>
      WalletTransaction(
        id: json['id'] as String,
        type: WalletTransactionType.fromWire(json['type'] as String?),
        amountDzd: _asInt(json['amountDzd']),
        balanceAfterDzd: _asInt(json['balanceAfterDzd']),
        createdAt: json['createdAt'] as String? ?? '',
        sourceType: json['sourceType'] as String?,
        sourceRef: json['sourceRef'] as String?,
        note: json['note'] as String?,
      );
}

/// How the driver handed over the money offline.
enum TopUpChannel {
  cash('CASH', 'Cash'),
  bankTransfer('BANK_TRANSFER', 'Bank transfer');

  const TopUpChannel(this.wireName, this.label);

  final String wireName;
  final String label;

  static TopUpChannel fromWire(String? value) => values.firstWhere(
        (channel) => channel.wireName == value,
        orElse: () => cash,
      );
}

/// Top-up lifecycle. All three exits are terminal — a decided request cannot be
/// re-submitted; the driver starts a new one.
enum TopUpStatus {
  pending('PENDING', 'Pending'),
  approved('APPROVED', 'Approved'),
  rejected('REJECTED', 'Rejected'),
  cancelled('CANCELLED', 'Cancelled');

  const TopUpStatus(this.wireName, this.label);

  final String wireName;
  final String label;

  bool get isPending => this == pending;

  static TopUpStatus fromWire(String? value) => values.firstWhere(
        (status) => status.wireName == value,
        orElse: () => pending,
      );
}

/// A manual top-up request with an uploaded receipt.
final class TopUp {
  const TopUp({
    required this.id,
    required this.amountDzd,
    required this.channel,
    required this.status,
    required this.createdAt,
    this.creditedAmountDzd,
    this.decisionReason,
    this.decidedAt,
  });

  final String id;
  final int amountDzd;
  final TopUpChannel channel;
  final TopUpStatus status;
  final String createdAt;

  /// What the admin actually credited — may differ from [amountDzd] when the
  /// receipt showed a different figure. Only set once approved.
  final int? creditedAmountDzd;

  /// Free-text rejection reason, shown to the driver.
  final String? decisionReason;
  final String? decidedAt;

  bool get isPending => status.isPending;

  factory TopUp.fromJson(Map<String, dynamic> json) => TopUp(
        id: json['id'] as String,
        amountDzd: _asInt(json['amountDzd']),
        channel: TopUpChannel.fromWire(json['channel'] as String?),
        status: TopUpStatus.fromWire(json['status'] as String?),
        createdAt: json['createdAt'] as String? ?? '',
        creditedAmountDzd: json['creditedAmountDzd'] == null
            ? null
            : _asInt(json['creditedAmountDzd']),
        decisionReason: json['decisionReason'] as String?,
        decidedAt: json['decidedAt'] as String?,
      );
}

int _asInt(Object? value, [int fallback = 0]) =>
    value is int ? value : (value is num ? value.toInt() : fallback);
