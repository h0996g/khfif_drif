import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../ride/shared/utils/date_formatter.dart';
import '../../../../../ride/shared/utils/fare_formatter.dart';
import '../../../data/models/wallet_models.dart';
import 'top_up_status_pill.dart';

/// One row of the top-up history.
///
/// Shows the credited amount whenever it differs from the requested one — an
/// admin can override it when the receipt reads differently — and the
/// rejection reason, which is written for the driver to act on.
class TopUpHistoryCard extends StatelessWidget {
  const TopUpHistoryCard({super.key, required this.topUp});

  final TopUp topUp;

  @override
  Widget build(BuildContext context) {
    final credited = topUp.creditedAmountDzd;
    final wasAdjusted = credited != null && credited != topUp.amountDzd;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderDefault(context), width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${formatFare(topUp.amountDzd)} DZD',
                  style: AppTextStyles.labelLarge(context)
                      .copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              TopUpStatusPill(status: topUp.status),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            [
              topUp.channel.label,
              formatRideDate(topUp.createdAt),
            ].where((part) => part.isNotEmpty).join(' · '),
            style: AppTextStyles.bodySmall(context)
                .copyWith(color: AppColors.textSecondary(context)),
          ),
          if (wasAdjusted) ...[
            SizedBox(height: 8.h),
            Text(
              'Credited ${formatFare(credited)} DZD',
              style: AppTextStyles.bodySmall(context).copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (topUp.decisionReason != null &&
              topUp.decisionReason!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                topUp.decisionReason!,
                style: AppTextStyles.bodySmall(context)
                    .copyWith(color: AppColors.error),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
