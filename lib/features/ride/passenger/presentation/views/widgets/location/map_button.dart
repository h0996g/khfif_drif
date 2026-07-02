import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/theme/app_colors.dart';

class MapButton extends StatelessWidget {
  const MapButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.isLoading = false,
    this.highlighted = false,
  });

  final IconData icon;
  final VoidCallback onTap;

  /// When true, a spinner replaces the icon and taps are ignored.
  final bool isLoading;

  /// When true, the button uses the primary color (e.g. active location).
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final color = highlighted
        ? AppColors.primary
        : AppColors.background(context);
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12.r),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: isLoading ? null : onTap,
        child: SizedBox(
          width: 44.w,
          height: 44.w,
          child: isLoading
              ? Center(
                  child: SizedBox(
                    width: 18.w,
                    height: 18.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: highlighted
                          ? AppColors.white
                          : AppColors.primary,
                    ),
                  ),
                )
              : Icon(
                  icon,
                  size: 20.w,
                  color: highlighted
                      ? AppColors.white
                      : AppColors.text(context),
                ),
        ),
      ),
    );
  }
}
