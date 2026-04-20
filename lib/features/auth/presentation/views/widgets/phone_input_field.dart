// lib/features/auth/presentation/views/widgets/phone_input_field.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// Algeria-specific phone input field with DZ flag prefix pill and
/// animated error message.
class PhoneInputField extends StatefulWidget {
  const PhoneInputField({
    super.key,
    required this.onChanged,
    this.errorMessage,
    this.controller,
  });

  final ValueChanged<String> onChanged;

  /// When non-null and non-empty the border turns red and the message
  /// slides in underneath the field.
  final String? errorMessage;

  final TextEditingController? controller;

  @override
  State<PhoneInputField> createState() => _PhoneInputFieldState();
}

class _PhoneInputFieldState extends State<PhoneInputField> {
  late final FocusNode _focusNode;
  bool _isFocused = false;
  String? _localError;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()
      ..addListener(() {
        setState(() => _isFocused = _focusNode.hasFocus);
      });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handlePhoneChanged(String value) {
    String? error;
    if (value.isNotEmpty) {
      if (!value.startsWith('0')) {
        error = 'Number must start with 0';
      } else if (value.length >= 2 && !RegExp(r'^0[567]').hasMatch(value)) {
        error = 'Number must start with 05, 06, or 07';
      }
    }

    setState(() {
      _localError = error;
    });

    widget.onChanged(value);
  }

  bool get _hasError =>
      (_localError != null && _localError!.isNotEmpty) ||
      (widget.errorMessage != null && widget.errorMessage!.isNotEmpty);

  String get _displayError => (_localError != null && _localError!.isNotEmpty)
      ? _localError!
      : (widget.errorMessage ?? '');

  Color _getBorderColor(BuildContext context) {
    if (_hasError) return AppColors.error;
    if (_isFocused) return AppColors.primary;
    return AppColors.borderDefault(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Input container ──────────────────────────────────────────────
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 56.h,
          decoration: BoxDecoration(
            color: AppColors.background(context),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: _getBorderColor(context),
              width: 1.5.w,
            ),
          ),
          child: Row(
            children: [
              SizedBox(width: 12.w),
              // Text field
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  onChanged: _handlePhoneChanged,
                  keyboardType: TextInputType.phone,
                  maxLength: AppConstants.phoneMaxLength,
                  style: AppTextStyles.inputText(context),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(
                        AppConstants.phoneMaxLength),
                  ],
                  decoration: InputDecoration(
                    hintText: AppConstants.phoneHint,
                    hintStyle: AppTextStyles.inputHint(context),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    counterText: '',
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
            ],
          ),
        ),

        // ── Error message (animated slide-in) ────────────────────────────
        AnimatedSize(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: _hasError
              ? Padding(
                  padding: EdgeInsets.only(top: 6.h, left: 4.w),
                  child: Text(
                    _displayError,
                    style: AppTextStyles.inputError(context),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
