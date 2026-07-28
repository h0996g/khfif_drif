import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../ride/shared/utils/fare_formatter.dart';
import '../../../data/models/wallet_models.dart';

/// The balance hero tile.
///
/// A negative balance is rendered as debt rather than hidden or clamped — the
/// backend posts commission and penalty debits even when they push the driver
/// below zero (integration/epic-04-wallet.md §7).
class WalletBalanceCard extends StatelessWidget {
  const WalletBalanceCard({super.key, required this.balance});

  final WalletBalance balance;

  @override
  Widget build(BuildContext context) {
    final isDebt = balance.balanceDzd < 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 22.h),
      decoration: BoxDecoration(
        color: AppColors.isDark(context) ? AppColors.white : AppColors.black,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 28.r,
            offset: Offset(0, 12.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                size: 18.w,
                color: AppColors.primary,
              ),
              SizedBox(width: 8.w),
              Text(
                isDebt ? 'Outstanding balance' : 'Wallet balance',
                style: AppTextStyles.labelMedium(context).copyWith(
                  color: AppColors.isDark(context)
                      ? AppColors.black
                      : AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                formatFare(balance.balanceDzd),
                style: AppTextStyles.displayMedium(context).copyWith(
                  color: isDebt
                      ? AppColors.error
                      : (AppColors.isDark(context)
                          ? AppColors.black
                          : AppColors.white),
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                'DZD',
                style: AppTextStyles.labelLarge(context).copyWith(
                  color: AppColors.isDark(context)
                      ? AppColors.black.withValues(alpha: 0.6)
                      : AppColors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (balance.minOnlineBalanceDzd > 0) ...[
            SizedBox(height: 10.h),
            Text(
              '${formatFare(balance.minOnlineBalanceDzd)} DZD minimum to go '
              'online',
              style: AppTextStyles.bodySmall(context).copyWith(
                color: AppColors.isDark(context)
                    ? AppColors.black.withValues(alpha: 0.55)
                    : AppColors.white.withValues(alpha: 0.65),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
