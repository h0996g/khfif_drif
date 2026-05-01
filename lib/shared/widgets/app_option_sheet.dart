import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// A single selectable option rendered inside [showAppOptionSheet].
class AppSheetOption<T> {
  const AppSheetOption({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
  });

  final IconData icon;
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
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    isScrollControlled: true,
    builder: (_) => _AppOptionSheet<T>(title: title, options: options),
  );
}

class _AppOptionSheet<T> extends StatelessWidget {
  const _AppOptionSheet({required this.title, required this.options});

  final String title;
  final List<AppSheetOption<T>> options;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16.w,
        0,
        16.w,
        16.h + MediaQuery.of(context).padding.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background(context),
          borderRadius: BorderRadius.circular(28.r),
        ),
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.borderDefault(context),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Text(
                title,
                style: AppTextStyles.labelMedium(context).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            for (final option in options)
              _OptionRow<T>(
                option: option,
                onTap: () => Navigator.pop(context, option.value),
              ),
          ],
        ),
      ),
    );
  }
}

class _OptionRow<T> extends StatelessWidget {
  const _OptionRow({required this.option, required this.onTap});

  final AppSheetOption<T> option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          splashColor: AppColors.primary.withValues(alpha: 0.08),
          highlightColor: AppColors.primary.withValues(alpha: 0.05),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
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
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13.w,
                  color:
                      AppColors.textSecondary(context).withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
