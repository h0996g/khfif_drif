import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../ride/shared/utils/fare_formatter.dart';
import '../../../data/models/wallet_models.dart';

/// Shown while `belowGate` is true: the driver can't go online or bid until a
/// top-up clears. Rendered proactively from `GET /wallet` rather than waiting
/// for the `403 INSUFFICIENT_WALLET_BALANCE`.
class WalletGateBanner extends StatelessWidget {
  const WalletGateBanner({
    super.key,
    required this.balance,
    required this.onTopUp,
  });

  final WalletBalance balance;
  final VoidCallback onTopUp;

  @override
  Widget build(BuildContext context) {
    final shortfall = balance.shortfallDzd;

    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.35),
          width: 1.w,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 22.w),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "You can't go online",
                  style: AppTextStyles.labelMedium(context).copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  shortfall > 0
                      ? 'Top up ${formatFare(shortfall)} DZD or more to start '
                          'accepting rides.'
                      : 'Top up your wallet to start accepting rides.',
                  style: AppTextStyles.bodySmall(context).copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                SizedBox(height: 10.h),
                GestureDetector(
                  onTap: onTopUp,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      'Top up',
                      style: AppTextStyles.labelMedium(context).copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
