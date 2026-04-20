// lib/features/auth/presentation/views/widgets/otp_blocked_banner_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// Red banner shown when user is blocked for 10 minutes.
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
      margin: EdgeInsets.only(bottom: 32.h),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.lock_outline_rounded, size: 36.sp, color: AppColors.error),
          SizedBox(height: 12.h),
          Text(
            'Too many incorrect attempts',
            style: AppTextStyles.headingSmall(context).copyWith(
              color: AppColors.error,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'You\'ve been temporarily blocked.\nTry again in $_countdown.',
            style: AppTextStyles.bodySmall(context).copyWith(
              color: AppColors.error.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
