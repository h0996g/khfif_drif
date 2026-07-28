import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/constants/wallet_api_constants.dart';
import '../../../../../../core/errors/api_exception.dart';
import '../../../data/models/wallet_models.dart';
import '../../../data/receipt_picker_service.dart';
import '../../../data/wallet_repository.dart';
import 'top_up_state.dart';

/// Drives the top-up form and the driver's own top-up history.
///
/// Route-scoped, unlike [WalletCubit] — nothing here needs to outlive the
/// screens. The wallet's balance is kept in sync by the views, which call back
/// into the shell-scoped cubit after a successful submit or cancel.
final class TopUpCubit extends Cubit<TopUpState> {
  TopUpCubit(this._repository, this._picker) : super(const TopUpState());

  final WalletRepository _repository;
  final ReceiptPickerService _picker;

  static const int _pageSize = 20;

  // ── Form ────────────────────────────────────────────────────────────────

  void amountChanged(String raw) {
    final amount = int.tryParse(raw.trim()) ?? 0;
    emit(state.copyWith(amountDzd: amount, amountError: '', errorMessage: ''));
  }

  void channelChanged(TopUpChannel channel) =>
      emit(state.copyWith(channel: channel));

  Future<void> pickReceipt(ReceiptSource source) async {
    final result = await _picker.pick(source);
    switch (result) {
      case ReceiptPickSuccess(:final path, :final name):
        emit(state.copyWith(
          receiptPath: path,
          receiptName: name,
          receiptError: '',
          errorMessage: '',
        ));
      case ReceiptPickFailure(:final message):
        emit(state.copyWith(receiptError: message));
      case ReceiptPickCancelled():
        break;
    }
  }

  void clearReceipt() =>
      emit(state.copyWith(receiptPath: '', receiptName: '', receiptError: ''));

  /// Submits the request. There is no `Idempotency-Key` on this endpoint —
  /// a duplicate submit is caught by the server's one-PENDING-per-driver rule
  /// and surfaced as [TopUpStatusUi.pendingExists] rather than an error.
  Future<TopUp?> submit() async {
    if (!state.canSubmit) return null;

    emit(state.copyWith(
      status: TopUpStatusUi.submitting,
      errorMessage: '',
      amountError: '',
      receiptError: '',
    ));
    try {
      final topUp = await _repository.submitTopUp(
        amountDzd: state.amountDzd,
        channel: state.channel,
        receiptPath: state.receiptPath,
      );
      emit(state.copyWith(status: TopUpStatusUi.submitted));
      return topUp;
    } catch (e) {
      emit(_failureFor(e));
      return null;
    }
  }

  /// Maps the API error code onto the field it belongs to, so the driver sees
  /// the problem where they can fix it (epic-04-wallet.md §10).
  TopUpState _failureFor(Object error) {
    final message = error.toString();
    final code = error is ApiException ? error.code : '';
    return switch (code) {
      WalletErrorCodes.topUpPendingExists =>
        state.copyWith(status: TopUpStatusUi.pendingExists),
      WalletErrorCodes.topUpBelowMinimum =>
        state.copyWith(status: TopUpStatusUi.failure, amountError: message),
      WalletErrorCodes.topUpReceiptRequired =>
        state.copyWith(status: TopUpStatusUi.failure, receiptError: message),
      _ => state.copyWith(status: TopUpStatusUi.failure, errorMessage: message),
    };
  }

  // ── History ─────────────────────────────────────────────────────────────

  Future<void> loadHistory({TopUpStatus? filter, bool clearFilter = false}) async {
    final activeFilter = clearFilter ? null : (filter ?? state.filter);
    emit(state.copyWith(
      status: TopUpStatusUi.loading,
      topUps: const [],
      filter: activeFilter,
      clearFilter: activeFilter == null,
      errorMessage: '',
    ));
    try {
      final page =
          await _repository.getTopUps(status: activeFilter, size: _pageSize);
      emit(state.copyWith(
        status: TopUpStatusUi.loaded,
        topUps: page.data,
        currentPage: page.page,
        totalPages: page.totalPages,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TopUpStatusUi.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || state.hasReachedMax) return;

    emit(state.copyWith(status: TopUpStatusUi.loadingMore, errorMessage: ''));
    try {
      final page = await _repository.getTopUps(
        status: state.filter,
        page: state.currentPage + 1,
        size: _pageSize,
      );
      emit(state.copyWith(
        status: TopUpStatusUi.loaded,
        topUps: [...state.topUps, ...page.data],
        currentPage: page.page,
        totalPages: page.totalPages,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TopUpStatusUi.loaded,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Cancels a `PENDING` request. A `409 TOPUP_NOT_PENDING` only means the view
  /// is stale (an admin decided it first), so it refetches instead of shouting.
  Future<bool> cancel(String id) async {
    try {
      await _repository.cancelTopUp(id);
      await _refreshHistoryIfLoaded();
      return true;
    } catch (e) {
      final code = e is ApiException ? e.code : '';
      if (code == WalletErrorCodes.topUpNotPending ||
          code == WalletErrorCodes.topUpNotFound) {
        await _refreshHistoryIfLoaded();
        return true;
      }
      emit(state.copyWith(
        status: TopUpStatusUi.failure,
        errorMessage: e.toString(),
      ));
      return false;
    }
  }

  Future<void> _refreshHistoryIfLoaded() async {
    if (state.topUps.isEmpty && state.status == TopUpStatusUi.initial) return;
    await loadHistory();
  }
}
