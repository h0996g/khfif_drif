import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'app_bottom_sheet.dart';

/// Beautiful, minimal bottom sheet for picking a date.
/// Returns the selected [DateTime], or null if dismissed.
///
/// Tapping a day immediately confirms and closes the sheet.
Future<DateTime?> showAppDatePickerSheet({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  return showAppBottomSheet<DateTime>(
    context: context,
    title: 'Select Date',
    child: Builder(builder: (context) {
      final isDark = AppColors.isDark(context);
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: isDark
              ? ColorScheme.dark(
                  primary: AppColors.text(context),
                  onPrimary: AppColors.background(context),
                  surface: AppColors.surface(context),
                  onSurface: AppColors.text(context),
                )
              : ColorScheme.light(
                  primary: AppColors.text(context),
                  onPrimary: AppColors.background(context),
                  surface: AppColors.surface(context),
                  onSurface: AppColors.text(context),
                ),
          datePickerTheme: DatePickerThemeData(
            backgroundColor: AppColors.surface(context),
            surfaceTintColor: Colors.transparent,
            headerBackgroundColor: AppColors.surface(context),
            headerForegroundColor: AppColors.text(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.r),
            ),
            dayStyle: AppTextStyles.bodyMedium(context)
                .copyWith(fontWeight: FontWeight.w500),
          ),
        ),
        child: CalendarDatePicker(
          initialDate: initialDate,
          firstDate: firstDate,
          lastDate: lastDate,
          onDateChanged: (date) => Navigator.pop(context, date),
        ),
      );
    }),
  );
}
