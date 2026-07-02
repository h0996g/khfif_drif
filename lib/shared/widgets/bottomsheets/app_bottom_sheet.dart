import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Generic bottom-sheet shell — the single source of truth for sheet chrome.
///
/// Renders a floating, rounded container with a drag handle and a standard
/// title, then [child] below. Callers own their content and pop the sheet via
/// `Navigator.pop(context, value)`; the generic [T] carries the returned value.
///
/// Returns the value passed to `Navigator.pop`, or null if dismissed.
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required String title,
  required Widget child,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    isScrollControlled: true,
    builder: (_) => _AppBottomSheet<T>(title: title, child: child),
  );
}

class _AppBottomSheet<T> extends StatelessWidget {
  const _AppBottomSheet({required this.title, required this.child});

  final String title;
  final Widget child;

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
                textAlign: TextAlign.center,
                style: AppTextStyles.labelMedium(context).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            child,
          ],
        ),
      ),
    );
  }
}
