import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../data/models/wallet_models.dart';

/// Colour-coded badge for a top-up's terminal (or pending) status.
class TopUpStatusPill extends StatelessWidget {
  const TopUpStatusPill({super.key, required this.status});

  final TopUpStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      TopUpStatus.approved => AppColors.primary,
      TopUpStatus.rejected => AppColors.error,
      TopUpStatus.pending => const Color(0xFFF59E0B),
      TopUpStatus.cancelled => AppColors.textSecondary(context),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1.w),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.labelSmall(context).copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
