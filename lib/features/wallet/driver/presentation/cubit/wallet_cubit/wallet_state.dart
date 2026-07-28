import 'package:equatable/equatable.dart';

import '../../../data/models/wallet_models.dart';

enum WalletStatus { initial, loading, loaded, loadingMore, failure }

final class WalletState extends Equatable {
  const WalletState({
    this.status = WalletStatus.initial,
    this.balance = const WalletBalance.zero(),
    this.transactions = const [],
    this.currentPage = -1,
    this.totalPages = 0,
    this.pendingTopUp,
    this.errorMessage = '',
    this.lowBalanceWarning = '',
  });

  final WalletStatus status;
  final WalletBalance balance;
  final List<WalletTransaction> transactions;
  final int currentPage;
  final int totalPages;

  /// The driver's single in-flight top-up, if any — the server allows one.
  final TopUp? pendingTopUp;
  final String errorMessage;

  /// Set by a `wallet.balance_low` frame; cleared once the UI has shown it.
  final String lowBalanceWarning;

  bool get isLoading => status == WalletStatus.loading;
  bool get isLoadingMore => status == WalletStatus.loadingMore;

  /// Whether the balance blocks going online and bidding.
  bool get belowGate => balance.belowGate;
  int get balanceDzd => balance.balanceDzd;

  /// True once a first successful load has happened — until then the gate is
  /// unknown and must not be used to disable the go-online switch.
  bool get isKnown => status == WalletStatus.loaded ||
      status == WalletStatus.loadingMore;

  bool get hasReachedMax => totalPages <= 0 || currentPage + 1 >= totalPages;

  WalletState copyWith({
    WalletStatus? status,
    WalletBalance? balance,
    List<WalletTransaction>? transactions,
    int? currentPage,
    int? totalPages,
    TopUp? pendingTopUp,
    bool clearPendingTopUp = false,
    String? errorMessage,
    String? lowBalanceWarning,
  }) {
    return WalletState(
      status: status ?? this.status,
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      pendingTopUp:
          clearPendingTopUp ? null : (pendingTopUp ?? this.pendingTopUp),
      errorMessage: errorMessage ?? this.errorMessage,
      lowBalanceWarning: lowBalanceWarning ?? this.lowBalanceWarning,
    );
  }

  @override
  List<Object?> get props => [
        status,
        balance.balanceDzd,
        balance.minOnlineBalanceDzd,
        balance.belowGate,
        transactions,
        currentPage,
        totalPages,
        pendingTopUp?.id,
        pendingTopUp?.status,
        errorMessage,
        lowBalanceWarning,
      ];
}
