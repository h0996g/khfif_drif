// lib/shared/widgets/primary_button.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:khfif_drif/core/theme/app_colors.dart';

import '../../core/theme/app_text_styles.dart';

/// A full-width primary action button used throughout the app.
///
/// - Enabled: solid primary background.
/// - Disabled: solid disabled background.
/// - Loading: replaces label with a default [CircularProgressIndicator].
/// - Background colour transitions smoothly over 200 ms.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final bool active = isEnabled && !isLoading;

    final disabledColor = AppColors.buttonDisabled(context);
    final disabledTextColor = AppColors.buttonDisabledText(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      height: 56.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : disabledColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: active ? onPressed : null,
          borderRadius: BorderRadius.circular(12.r),
          splashColor: AppColors.white.withValues(alpha: 0.2),
          highlightColor: AppColors.white.withValues(alpha: 0.1),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.white),
                    ),
                  )
                : Text(
                    label,
                    style: AppTextStyles.labelLarge(context).copyWith(
                      color: active ? AppColors.white : disabledTextColor,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
