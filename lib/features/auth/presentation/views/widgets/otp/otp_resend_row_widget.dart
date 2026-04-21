// lib/features/auth/presentation/views/widgets/otp_resend_row_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../cubit/otp_cubit/otp_state.dart';

/// Resend countdown + button row.
class OtpResendRowWidget extends StatelessWidget {
  const OtpResendRowWidget(
      {super.key, required this.state, required this.onResend});

  final OtpState state;
  final VoidCallback onResend;

  String _timerLabel() {
    final m = state.secondsRemaining ~/ 60;
    final s = state.secondsRemaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final bool waiting = state.secondsRemaining > 0;
    final bool exhausted = state.resendCount >= 3;

    return Column(
      children: [
        if (waiting)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer_outlined,
                  size: 15.sp, color: AppColors.textSecondary(context)),
              SizedBox(width: 6.w),
              Text(
                'Resend code in ${_timerLabel()}',
                style: AppTextStyles.bodySmall(context),
              ),
            ],
          ),
        if (!waiting && !exhausted)
          GestureDetector(
            onTap: onResend,
            child: Text(
              'Resend Code',
              style: AppTextStyles.labelMedium(context).copyWith(
                color: AppColors.primary,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.primary,
              ),
            ),
          ),
        if (!waiting && exhausted)
          Text(
            'Maximum resend attempts reached',
            style: AppTextStyles.bodySmall(context).copyWith(
              color: AppColors.error,
            ),
          ),
        if (state.resendCount > 0 && !exhausted)
          Padding(
            padding: EdgeInsets.only(top: 6.h),
            child: Text(
              '${3 - state.resendCount} resend${3 - state.resendCount == 1 ? '' : 's'} remaining',
              style: AppTextStyles.labelSmall(context),
            ),
          ),
      ],
    );
  }
}
