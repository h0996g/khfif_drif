import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';

class OtpBlockedBannerWidget extends StatelessWidget {
  const OtpBlockedBannerWidget({super.key, required this.seconds});

  final int seconds;

  String get _countdown {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 32.h),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_rounded,
              size: 24.sp,
              color: AppColors.error,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Account Temporarily Locked',
            style: AppTextStyles.headingSmall(context).copyWith(
              color: AppColors.error,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          Text(
            'Too many incorrect attempts.\nPlease try again in',
            style: AppTextStyles.bodySmall(context).copyWith(
              color: AppColors.error.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              _countdown,
              style: AppTextStyles.displaySmall(context).copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
