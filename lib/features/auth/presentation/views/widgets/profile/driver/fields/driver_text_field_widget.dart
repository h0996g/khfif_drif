import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../../core/theme/app_text_styles.dart';

class DriverTextFieldWidget extends StatelessWidget {
  const DriverTextFieldWidget({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    required this.onChanged,
    required this.error,
    required this.enabled,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.words,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final ValueChanged<String> onChanged;
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
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: hasError ? AppColors.error : AppColors.borderDefault(context),
              width: 1.5.w,
            ),
          ),
          child: TextField(
            controller: controller,
            enabled: enabled,
            textInputAction: textInputAction,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
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
                      Icon(Icons.info_outline_rounded,
                          size: 13.w, color: AppColors.error),
                      SizedBox(width: 4.w),
                      Text(error,
                          style: AppTextStyles.inputError(context)),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
