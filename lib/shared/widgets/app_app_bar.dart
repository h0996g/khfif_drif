// lib/shared/widgets/app_app_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// App-wide [AppBar] that blends with the scaffold background.
///
/// [title] is displayed centered. [onLeadingTap] shows a leading back icon.
class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppAppBar({
    super.key,
    this.title,
    this.onLeadingTap,
  });

  final String? title;
  final VoidCallback? onLeadingTap;

  @override
  Size get preferredSize => Size.fromHeight(56.h);

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        AppColors.background(context),
        AppColors.surface(context),
        AppColors.surface(context).withValues(alpha: 1),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    return Container(
      decoration: BoxDecoration(gradient: gradient),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: preferredSize.height,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: AppTextStyles.headingSmall(context),
                  ),
                if (onLeadingTap != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: onLeadingTap,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 16.sp,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
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
