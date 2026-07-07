import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/utils/fare_formatter.dart';

/// Bottom sheet to enter a bid for a ride request. Returns the entered fare in
/// DZD, or `null` if dismissed. The input is constrained to the server's allowed
/// band (`±50%`, clamped to `[100, 50000]`) so we never round-trip a
/// `400 FARE_OUT_OF_BOUNDS` (see `swagger/epic-03-ride.md` §7).
Future<int?> showBidSheet(
  BuildContext context, {
  required int proposedFare,
}) {
  return showModalBottomSheet<int>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.5),
    isScrollControlled: true,
    builder: (_) => _BidSheet(proposedFare: proposedFare),
  );
}

class _BidSheet extends StatefulWidget {
  const _BidSheet({required this.proposedFare});

  final int proposedFare;

  @override
  State<_BidSheet> createState() => _BidSheetState();
}

class _BidSheetState extends State<_BidSheet> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.proposedFare.toString());
  late final FocusNode _focusNode = FocusNode();
  late final int _minFare = math.max(100, (widget.proposedFare * 0.5).round());
  late final int _maxFare =
      math.min(50000, (widget.proposedFare * 1.5).round());
  String _error = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_error.isNotEmpty) setState(() => _error = '');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  int? get _currentValue => int.tryParse(_controller.text.trim());

  void _setFare(int fare) {
    final clamped = fare.clamp(_minFare, _maxFare);
    _controller.text = clamped.toString();
    _controller.selection =
        TextSelection.collapsed(offset: _controller.text.length);
    setState(() => _error = '');
  }

  void _adjustByPercent(int percent) {
    final base = _currentValue ?? widget.proposedFare;
    _setFare((base * (1 + percent / 100)).round());
  }

  void _submit() {
    final fare = _currentValue;
    if (fare == null) {
      setState(() => _error = 'Enter a fare amount');
      return;
    }
    if (fare < _minFare || fare > _maxFare) {
      setState(() => _error = 'Allowed range is $_minFare – $_maxFare DZD');
      return;
    }
    Navigator.pop(context, fare);
  }

  @override
  Widget build(BuildContext context) {
    final view = View.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: view.viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background(context),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Compact content block ---
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 32.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppColors.borderDefault(context),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // Title
                  Center(
                    child: Text(
                      'Place your bid',
                      style: AppTextStyles.headingSmall(context),
                    ),
                  ),
                  SizedBox(height: 14.h),

                  // Hero editable amount
                  _HeroAmountField(
                    controller: _controller,
                    focusNode: _focusNode,
                  ),

                  // Min/Max hint, or inline error (fixed height → no jump)
                  SizedBox(
                    height: 16.h,
                    child: Center(
                      child: Text(
                        _error.isEmpty
                            ? 'Min ${formatFare(_minFare)} – Max ${formatFare(_maxFare)} DZD'
                            : _error,
                        style: AppTextStyles.labelSmall(context).copyWith(
                          color: _error.isEmpty
                              ? AppColors.textSecondary(context)
                              : AppColors.error,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Quick adjust presets
                  Row(
                    children: [
                      Expanded(
                        child: _PresetChip(
                          label: '−10%',
                          onTap: () => _adjustByPercent(-10),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: _PresetChip(
                          label: 'Match',
                          highlighted: true,
                          onTap: () => _setFare(widget.proposedFare),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: _PresetChip(
                          label: '+10%',
                          onTap: () => _adjustByPercent(10),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- Submit button pinned to the bottom edge ---
            Divider(
              height: 1,
              thickness: 1,
              color: AppColors.borderDefault(context),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                20.w,
                12.h,
                20.w,
                // Safe-area inset matters only when the keyboard is closed;
                // the outer Padding already lifts the sheet above the keyboard.
                (view.viewInsets.bottom > 0 ? 0 : view.padding.bottom) + 12.h,
              ),
              child: _SubmitButton(
                label: 'Submit bid',
                enabled: _currentValue != null && _error.isEmpty,
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Large, borderless editable amount centered in the sheet.
class _HeroAmountField extends StatelessWidget {
  const _HeroAmountField({
    required this.controller,
    required this.focusNode,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textAlign: TextAlign.center,
      showCursor: true,
      cursorColor: AppColors.primary,
      style: GoogleFonts.inter(
        fontSize: 32.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.text(context),
        height: 1.1,
      ),
      decoration: InputDecoration(
        prefixText: '   ',
        suffixText: 'DZD',
        suffixStyle: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary(context),
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
      onSubmitted: (_) => focusNode.unfocus(),
    );
  }
}

/// Tappable preset button used for quick fare adjustments.
class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.label,
    required this.onTap,
    this.highlighted = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final isFilled = highlighted;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          height: 40.h,
          decoration: BoxDecoration(
            color: isFilled
                ? AppColors.primary.withValues(alpha: 0.12)
                : AppColors.surface(context),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isFilled
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : AppColors.borderDefault(context),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.labelMedium(context).copyWith(
                fontWeight: FontWeight.w600,
                color: isFilled ? AppColors.primary : AppColors.text(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-width primary submit button.
class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.label,
    required this.onPressed,
    required this.enabled,
  });

  final String label;
  final VoidCallback onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      height: 48.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: enabled ? AppColors.primary : AppColors.buttonDisabled(context),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(12.r),
          splashColor: AppColors.white.withValues(alpha: 0.2),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.labelLarge(context).copyWith(
                color: enabled
                    ? AppColors.white
                    : AppColors.buttonDisabledText(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
