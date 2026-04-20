// lib/features/auth/presentation/views/widgets/otp_digit_field.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// A single digit box in the 6-box OTP split-input row.
///
/// Auto-advances focus to [nextFocusNode] when a digit is entered and
/// moves back to [previousFocusNode] on backspace from an empty field.
class OtpDigitField extends StatefulWidget {
  const OtpDigitField({
    super.key,
    required this.index,
    required this.controller,
    required this.focusNode,
    this.nextFocusNode,
    this.previousFocusNode,
    required this.onChanged,
    this.hasError = false,
    this.enabled = true,
  });

  final int index;
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocusNode;
  final FocusNode? previousFocusNode;
  final ValueChanged<String> onChanged;
  final bool hasError;
  final bool enabled;

  @override
  State<OtpDigitField> createState() => _OtpDigitFieldState();
}

class _OtpDigitFieldState extends State<OtpDigitField> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _isFocused = widget.focusNode.hasFocus);
    // Select all text when focused so typing a digit replaces existing one.
    if (widget.focusNode.hasFocus && widget.controller.text.isNotEmpty) {
      widget.controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: widget.controller.text.length,
      );
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  Color _borderColor(BuildContext context) {
    if (widget.hasError) return AppColors.error;
    if (_isFocused) return AppColors.primary;
    if (widget.controller.text.isNotEmpty) {
      return AppColors.primary.withValues(alpha: 0.4);
    }
    return AppColors.borderDefault(context);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 46.w,
      height: 56.h,
      decoration: BoxDecoration(
        color: widget.enabled
            ? AppColors.background(context)
            : AppColors.surface(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: _borderColor(context),
          width: _isFocused ? 2.0.w : 1.5.w,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Center(
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          enabled: widget.enabled,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: AppTextStyles.displaySmall(context).copyWith(
            fontWeight: FontWeight.w700,
            height: 1.0,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            counterText: '',
            contentPadding: EdgeInsets.zero,
            isDense: true,
          ),
          onChanged: (value) {
            if (value.isEmpty) {
              widget.onChanged('');
              // On backspace from empty cell → go back
              widget.previousFocusNode?.requestFocus();
            } else {
              widget.onChanged(value);
              // Move forward
              widget.nextFocusNode?.requestFocus();
            }
          },
        ),
      ),
    );
  }
}
