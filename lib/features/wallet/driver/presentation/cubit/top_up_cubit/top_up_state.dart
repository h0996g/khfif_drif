import 'package:equatable/equatable.dart';

import '../../../data/models/wallet_models.dart';

enum TopUpStatusUi {
  initial,
  loading,
  loaded,
  loadingMore,
  submitting,
  submitted,

  /// `409 TOPUP_PENDING_EXISTS` — a request is already in flight, so the view
  /// should show it rather than the form.
  pendingExists,
  failure,
}

final class TopUpState extends Equatable {
  const TopUpState({
    this.status = TopUpStatusUi.initial,
    this.amountDzd = 0,
    this.channel = TopUpChannel.cash,
    this.receiptPath = '',
    this.receiptName = '',
    this.topUps = const [],
    this.currentPage = -1,
    this.totalPages = 0,
    this.filter,
    this.errorMessage = '',
    this.amountError = '',
    this.receiptError = '',
  });

  final TopUpStatusUi status;

  // ── Form ────────────────────────────────────────────────────────────────
  final int amountDzd;
  final TopUpChannel channel;
  final String receiptPath;
  final String receiptName;

  // ── History ─────────────────────────────────────────────────────────────
  final List<TopUp> topUps;
  final int currentPage;
  final int totalPages;
  final TopUpStatus? filter;

  // ── Errors ──────────────────────────────────────────────────────────────
  final String errorMessage;
  final String amountError;
  final String receiptError;

  bool get hasReceipt => receiptPath.isNotEmpty;
  bool get isSubmitting => status == TopUpStatusUi.submitting;
  bool get isLoading => status == TopUpStatusUi.loading;
  bool get isLoadingMore => status == TopUpStatusUi.loadingMore;

  /// The receipt is mandatory server-side, so the button stays inert without
  /// one rather than trading a tap for a `TOPUP_RECEIPT_REQUIRED`.
  bool get canSubmit => amountDzd > 0 && hasReceipt && !isSubmitting;

  bool get hasReachedMax => totalPages <= 0 || currentPage + 1 >= totalPages;

  TopUpState copyWith({
    TopUpStatusUi? status,
    int? amountDzd,
    TopUpChannel? channel,
    String? receiptPath,
    String? receiptName,
    List<TopUp>? topUps,
    int? currentPage,
    int? totalPages,
    TopUpStatus? filter,
    bool clearFilter = false,
    String? errorMessage,
    String? amountError,
    String? receiptError,
  }) {
    return TopUpState(
      status: status ?? this.status,
      amountDzd: amountDzd ?? this.amountDzd,
      channel: channel ?? this.channel,
      receiptPath: receiptPath ?? this.receiptPath,
      receiptName: receiptName ?? this.receiptName,
      topUps: topUps ?? this.topUps,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      filter: clearFilter ? null : (filter ?? this.filter),
      errorMessage: errorMessage ?? this.errorMessage,
      amountError: amountError ?? this.amountError,
      receiptError: receiptError ?? this.receiptError,
    );
  }

  @override
  List<Object?> get props => [
        status,
        amountDzd,
        channel,
        receiptPath,
        receiptName,
        topUps,
        currentPage,
        totalPages,
        filter,
        errorMessage,
        amountError,
        receiptError,
      ];
}
