// lib/features/auth/presentation/views/widgets/change_number_bar_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// "Change Number" link at the top-left to go back to the phone entry.
class ChangeNumberBarWidget extends StatelessWidget {
  const ChangeNumberBarWidget({super.key, required this.onChangeTap});

  final VoidCallback onChangeTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: onChangeTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back_ios_new_rounded,
                size: 14.sp, color: AppColors.primary),
            SizedBox(width: 4.w),
            Text(
              'Change Number',
              style: AppTextStyles.labelMedium(context).copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
