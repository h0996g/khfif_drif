import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/router/route_names.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/app_toast.dart';
import '../../../../../shared/widgets/app_confirm_dialog.dart';
import '../../../../../shared/widgets/app_slim_app_bar.dart';
import '../cubit/wallet_cubit/wallet_cubit.dart';
import '../cubit/wallet_cubit/wallet_state.dart';
import 'widgets/pending_top_up_card.dart';
import 'widgets/wallet_balance_card.dart';
import 'widgets/wallet_gate_banner.dart';
import 'widgets/wallet_placeholders.dart';
import 'widgets/wallet_transaction_tile.dart';

/// Balance, gate status, in-flight top-up and the signed ledger.
///
/// Reads the shell-scoped [WalletCubit] so the balance shown here is the same
/// one the availability toggle gates on.
class DriverWalletView extends StatefulWidget {
  const DriverWalletView({super.key});

  @override
  State<DriverWalletView> createState() => _DriverWalletViewState();
}

class _DriverWalletViewState extends State<DriverWalletView> {
  final ScrollController _scrollController = ScrollController();
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // The shell-scoped cubit may already hold data from an earlier visit or a
    // socket (re)connect; refresh anyway so the screen always opens on truth.
    context.read<WalletCubit>().load();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      context.read<WalletCubit>().loadMoreTransactions();
    }
  }

  Future<void> _cancelPendingTopUp() async {
    final confirmed = await showAppConfirmDialog(
      context: context,
      title: 'Cancel top-up?',
      message: 'Your request will be withdrawn. You can submit a new one any '
          'time.',
      confirmLabel: 'Cancel request',
      cancelLabel: 'Keep it',
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;

    final cubit = context.read<WalletCubit>();
    setState(() => _isCancelling = true);
    final ok = await cubit.cancelPendingTopUp();
    if (!mounted) return;

    setState(() => _isCancelling = false);
    if (ok) {
      AppToast.success('Top-up request cancelled.');
    } else {
      AppToast.error(cubit.state.errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppSlimAppBar(
        title: 'Wallet',
        onLeadingTap: () => context.go(RouteNames.driverHome),
        trailing: IconButton(
          tooltip: 'Top-up history',
          onPressed: () => context.push(RouteNames.driverTopUpHistory),
          icon: Icon(Icons.receipt_long_rounded,
              size: 20.w, color: AppColors.text(context)),
        ),
      ),
      body: BlocConsumer<WalletCubit, WalletState>(
        listenWhen: (prev, curr) =>
            prev.lowBalanceWarning != curr.lowBalanceWarning &&
            curr.lowBalanceWarning.isNotEmpty,
        listener: (context, state) {
          AppToast.error(state.lowBalanceWarning);
          context.read<WalletCubit>().clearLowBalanceWarning();
        },
        builder: (context, state) {
          if (state.isLoading && state.transactions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => context.read<WalletCubit>().load(),
            child: ListView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
              children: [
                WalletBalanceCard(balance: state.balance),
                if (state.belowGate) ...[
                  SizedBox(height: 14.h),
                  WalletGateBanner(
                    balance: state.balance,
                    onTopUp: () => context.push(RouteNames.driverTopUp),
                  ),
                ],
                SizedBox(height: 14.h),
                if (state.pendingTopUp != null) ...[
                  PendingTopUpCard(
                    topUp: state.pendingTopUp!,
                    isCancelling: _isCancelling,
                    onCancel: _cancelPendingTopUp,
                  ),
                  SizedBox(height: 14.h),
                ] else ...[
                  _TopUpButton(
                      onTap: () => context.push(RouteNames.driverTopUp)),
                  SizedBox(height: 20.h),
                ],
                Text(
                  'Transactions',
                  style: AppTextStyles.headingSmall(context)
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4.h),
                ..._buildLedger(state),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildLedger(WalletState state) {
    if (state.transactions.isEmpty) {
      if (state.status == WalletStatus.failure) {
        return [
          WalletMessage(
            icon: Icons.error_outline_rounded,
            text: state.errorMessage.isEmpty
                ? 'Something went wrong'
                : state.errorMessage,
          ),
        ];
      }
      return const [
        WalletMessage(
          icon: Icons.receipt_long_rounded,
          text: 'No transactions yet. Top-ups and ride commissions will appear '
              'here.',
        ),
      ];
    }

    return [
      for (final transaction in state.transactions)
        WalletTransactionTile(transaction: transaction),
      WalletListFooter(isLoading: state.isLoadingMore),
    ];
  }
}

class _TopUpButton extends StatelessWidget {
  const _TopUpButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.4),
            width: 1.w,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.add_card_rounded, size: 20.w, color: AppColors.primary),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'Top up wallet',
                style: AppTextStyles.labelMedium(context).copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14.w, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
