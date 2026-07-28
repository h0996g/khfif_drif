import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../ride/shared/utils/date_formatter.dart';
import '../../../../../ride/shared/utils/fare_formatter.dart';
import '../../../data/models/wallet_models.dart';
import 'top_up_status_pill.dart';

/// The driver's single in-flight top-up. Nothing else is required of them —
/// an admin decides it out of band and the result arrives over the socket.
class PendingTopUpCard extends StatelessWidget {
  const PendingTopUpCard({
    super.key,
    required this.topUp,
    required this.onCancel,
    this.isCancelling = false,
  });

  final TopUp topUp;
  final VoidCallback onCancel;
  final bool isCancelling;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(14.r),
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
                  style: AppTextStyles.headingSmall(context)
                      .copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              TopUpStatusPill(status: topUp.status),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            '${topUp.channel.label} · submitted ${formatRideDate(topUp.createdAt)}',
            style: AppTextStyles.bodySmall(context)
                .copyWith(color: AppColors.textSecondary(context)),
          ),
          SizedBox(height: 10.h),
          Text(
            'Waiting for an admin to review your receipt. Your balance updates '
            'automatically once it is approved.',
            style: AppTextStyles.bodySmall(context)
                .copyWith(color: AppColors.textSecondary(context)),
          ),
          SizedBox(height: 8.h),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: isCancelling ? null : onCancel,
              child: isCancelling
                  ? SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      'Cancel request',
                      style: AppTextStyles.labelMedium(context).copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
