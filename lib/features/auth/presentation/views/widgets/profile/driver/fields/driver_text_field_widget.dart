// lib/features/driver/presentation/views/widgets/fields/driver_text_field_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../../core/theme/app_text_styles.dart';

/// Generic text field following the same AnimatedContainer + AnimatedSize
/// error pattern used throughout the passenger profile flow.
class DriverTextFieldWidget extends StatelessWidget {
  const DriverTextFieldWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    this.nextFocus,
    required this.hintText,
    required this.icon,
    required this.onChanged,
    required this.onFocusLost,
    required this.error,
    required this.enabled,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.words,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocus;
  final String hintText;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final VoidCallback onFocusLost;
  final String error;
  final bool enabled;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    final hasError = error.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: hasError
                  ? AppColors.error
                  : focusNode.hasFocus
                      ? AppColors.primary
                      : AppColors.borderDefault(context),
              width: 1.5.w,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            enabled: enabled,
            textInputAction: textInputAction,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            onSubmitted: (_) => nextFocus?.requestFocus(),
            style: AppTextStyles.inputText(context),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppTextStyles.inputHint(context),
              prefixIcon: Icon(
                icon,
                color: hasError
                    ? AppColors.error
                    : AppColors.textSecondary(context),
                size: 20.w,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 16.h,
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          child: hasError
              ? Padding(
                  padding: EdgeInsets.only(top: 6.h, left: 4.w),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 13.w,
                        color: AppColors.error,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        error,
                        style: AppTextStyles.inputError(context),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
