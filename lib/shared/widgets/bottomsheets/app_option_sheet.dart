import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'app_bottom_sheet.dart';

/// A single selectable option rendered inside [showAppOptionSheet].
class AppSheetOption<T> {
  const AppSheetOption({
    this.icon,
    this.leading,
    required this.label,
    required this.value,
    this.subtitle,
  }) : assert(icon != null || leading != null,
            'Provide either an icon or a leading widget');

  final IconData? icon;
  final Widget? leading;
  final String label;
  final String? subtitle;
  final T value;
}

/// Beautiful, minimal bottom sheet for picking one of [options].
/// Returns the selected value, or null if dismissed.
Future<T?> showAppOptionSheet<T>({
  required BuildContext context,
  required String title,
  required List<AppSheetOption<T>> options,
}) {
  return showAppBottomSheet<T>(
    context: context,
    title: title,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final option in options) _OptionRow<T>(option: option),
      ],
    ),
  );
}

class _OptionRow<T> extends StatelessWidget {
  const _OptionRow({required this.option});

  final AppSheetOption<T> option;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pop(context, option.value),
          borderRadius: BorderRadius.circular(16.r),
          splashColor: AppColors.primary.withValues(alpha: 0.08),
          highlightColor: AppColors.primary.withValues(alpha: 0.05),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
            child: Row(
              children: [
                option.leading ??
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.09),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        option.icon,
                        size: 20.w,
                        color: AppColors.primary,
                      ),
                    ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.label,
                        style: AppTextStyles.labelMedium(context).copyWith(
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.1,
                        ),
                      ),
                      if (option.subtitle != null) ...[
                        SizedBox(height: 2.h),
                        Text(
                          option.subtitle!,
                          style: AppTextStyles.labelSmall(context).copyWith(
                            color: AppColors.textSecondary(context),
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
