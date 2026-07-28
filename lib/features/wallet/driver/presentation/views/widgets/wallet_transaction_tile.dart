import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../ride/shared/utils/date_formatter.dart';
import '../../../../../ride/shared/utils/fare_formatter.dart';
import '../../../data/models/wallet_models.dart';

/// One ledger row. The amount is already signed by the server, so credits and
/// debits are told apart by sign rather than by re-deriving them from the type.
class WalletTransactionTile extends StatelessWidget {
  const WalletTransactionTile({super.key, required this.transaction});

  final WalletTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;
    final color = isCredit ? AppColors.primary : AppColors.error;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              _iconFor(transaction.type),
              size: 19.w,
              color: color,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.type.label,
                  style: AppTextStyles.labelMedium(context)
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 3.h),
                Text(
                  [
                    formatRideDate(transaction.createdAt),
                    if (transaction.note != null &&
                        transaction.note!.isNotEmpty)
                      transaction.note!,
                  ].where((part) => part.isNotEmpty).join(' · '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall(context)
                      .copyWith(color: AppColors.textSecondary(context)),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCredit ? '+' : ''}${formatFare(transaction.amountDzd)} DZD',
                style: AppTextStyles.labelMedium(context).copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                '${formatFare(transaction.balanceAfterDzd)} DZD',
                style: AppTextStyles.bodySmall(context)
                    .copyWith(color: AppColors.textSecondary(context)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static IconData _iconFor(WalletTransactionType type) => switch (type) {
        WalletTransactionType.topUpCredit => Icons.add_card_rounded,
        WalletTransactionType.rideCommission => Icons.percent_rounded,
        WalletTransactionType.rideCancelPenalty => Icons.gavel_rounded,
        WalletTransactionType.adminCredit => Icons.arrow_downward_rounded,
        WalletTransactionType.adminDebit => Icons.arrow_upward_rounded,
        WalletTransactionType.startingCredit => Icons.card_giftcard_rounded,
        WalletTransactionType.unknown => Icons.receipt_long_rounded,
      };
}
