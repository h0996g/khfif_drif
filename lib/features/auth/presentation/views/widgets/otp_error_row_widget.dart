// lib/features/auth/presentation/views/widgets/otp_error_row_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// Red inline error row shown on wrong code.
class OtpErrorRowWidget extends StatelessWidget {
  const OtpErrorRowWidget({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline_rounded, size: 15.sp, color: AppColors.error),
        SizedBox(width: 6.w),
        Text(
          message,
          style: AppTextStyles.inputError(context),
        ),
      ],
    );
  }
}
