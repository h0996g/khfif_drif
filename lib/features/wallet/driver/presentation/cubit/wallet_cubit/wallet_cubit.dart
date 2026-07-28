import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/constants/wallet_api_constants.dart';
import '../../../../../../core/errors/api_exception.dart';
import '../../../../../../core/network/ride_socket_service.dart';
import '../../../../../ride/driver/data/models/ride_socket_event.dart';
import '../../../data/models/wallet_models.dart';
import '../../../data/wallet_repository.dart';
import 'wallet_state.dart';

/// Owns the driver's balance, ledger and in-flight top-up.
///
/// Shell-scoped: the balance gate is read by the availability toggle as well as
/// the wallet screens, and it must survive navigation between them.
///
/// REST is truth, WS is hints — every (re)connect triggers a full refetch, and
/// live frames are applied on top. The four balance-carrying events already
/// include the new balance, so they patch the tile directly rather than
/// round-tripping (integration/epic-04-wallet.md §8).
final class WalletCubit extends Cubit<WalletState> {
  WalletCubit(this._repository) : super(const WalletState()) {
    _frameSub = RideSocketService.frameStream.listen(_onFrame);
    _statusSub = RideSocketService.statusStream.listen(_onStatus);
  }

  final WalletRepository _repository;
  late final StreamSubscription<String> _frameSub;
  late final StreamSubscription<RideSocketStatus> _statusSub;

  static const int _pageSize = 20;

  /// Balance, first ledger page and the pending top-up, fetched together.
  Future<void> load() async {
    emit(state.copyWith(status: WalletStatus.loading, errorMessage: ''));
    try {
      final (balance, page, pending) = await (
        _repository.getBalance(),
        _repository.getTransactions(size: _pageSize),
        _repository.getPendingTopUp(),
      ).wait;

      emit(state.copyWith(
        status: WalletStatus.loaded,
        balance: balance,
        transactions: page.data,
        currentPage: page.page,
        totalPages: page.totalPages,
        pendingTopUp: pending,
        clearPendingTopUp: pending == null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: WalletStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Refreshes only the balance — cheap enough to call after any action that
  /// might have moved money without a corresponding socket frame.
  Future<void> refreshBalance() async {
    try {
      final balance = await _repository.getBalance();
      emit(state.copyWith(balance: balance));
    } catch (_) {
      // Best-effort: keep whatever the tile already shows.
    }
  }

  Future<void> loadMoreTransactions() async {
    if (state.isLoading || state.isLoadingMore || state.hasReachedMax) return;

    emit(state.copyWith(status: WalletStatus.loadingMore, errorMessage: ''));
    try {
      final page = await _repository.getTransactions(
        page: state.currentPage + 1,
        size: _pageSize,
      );
      emit(state.copyWith(
        status: WalletStatus.loaded,
        transactions: [...state.transactions, ...page.data],
        currentPage: page.page,
        totalPages: page.totalPages,
      ));
    } catch (e) {
      // Keep the rows already on screen; surface the failure transiently.
      emit(state.copyWith(
        status: WalletStatus.loaded,
        errorMessage: e.toString(),
      ));
    }
  }

  /// Called by the top-up form once a request is submitted so the shell-scoped
  /// pending card appears without a refetch.
  void setPendingTopUp(TopUp? topUp) => emit(
        state.copyWith(pendingTopUp: topUp, clearPendingTopUp: topUp == null),
      );

  /// Withdraws the in-flight request. A `409 TOPUP_NOT_PENDING` (or a `404`)
  /// only means an admin decided it first — the view is stale, so clear the
  /// card and refetch rather than surfacing an error.
  Future<bool> cancelPendingTopUp() async {
    final pending = state.pendingTopUp;
    if (pending == null) return false;

    try {
      await _repository.cancelTopUp(pending.id);
      emit(state.copyWith(clearPendingTopUp: true));
      return true;
    } catch (e) {
      final code = e is ApiException ? e.code : '';
      if (code == WalletErrorCodes.topUpNotPending ||
          code == WalletErrorCodes.topUpNotFound) {
        emit(state.copyWith(clearPendingTopUp: true));
        await load();
        return true;
      }
      emit(state.copyWith(errorMessage: e.toString()));
      return false;
    }
  }

  void clearLowBalanceWarning() => emit(state.copyWith(lowBalanceWarning: ''));

  void _onStatus(RideSocketStatus status) {
    if (status == RideSocketStatus.connected) load();
  }

  void _onFrame(String frame) {
    final event = RideSocketEvent.tryParse(frame);
    switch (event) {
      case WalletTopUpApproved():
        // The pending request is decided; the balance arrives with the event.
        emit(state.copyWith(clearPendingTopUp: true));
        _applyBalance(event.balanceDzd);
      case WalletTopUpRejected(:final reason):
        emit(state.copyWith(
          clearPendingTopUp: true,
          errorMessage: reason.isEmpty ? 'Your top-up was rejected.' : reason,
        ));
      case WalletBalanceLow(:final balanceDzd, :final thresholdDzd):
        // Often arrives right behind a commission/penalty frame for the same
        // debit — the balance is already correct, so this only raises the flag.
        _applyBalance(balanceDzd);
        emit(state.copyWith(
          lowBalanceWarning: 'Balance is below the $thresholdDzd DZD minimum. '
              'Top up to keep going online.',
        ));
      case WalletBalanceEvent():
        // Commission, penalty and admin adjustment: balance only.
        _applyBalance(event.balanceDzd);
      default:
        break;
    }
  }

  /// Patches the tile from a socket payload. The threshold isn't repeated in
  /// those frames, so the gate is recomputed against the last known minimum;
  /// the next connect-triggered refetch restores the server's own verdict.
  void _applyBalance(int balanceDzd) {
    if (balanceDzd == state.balance.balanceDzd) return;
    emit(state.copyWith(balance: state.balance.withBalance(balanceDzd)));
  }

  @override
  Future<void> close() {
    _frameSub.cancel();
    _statusSub.cancel();
    return super.close();
  }
}
