// lib/features/driver/presentation/views/widgets/fields/driver_date_picker_field_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../../core/constants/app_constants.dart';
import '../../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../../core/theme/app_text_styles.dart';

/// A tappable field that opens a date picker. Styled identically to the
/// text fields used throughout the driver registration flow.
class DriverDatePickerFieldWidget extends StatelessWidget {
  const DriverDatePickerFieldWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.enabled,
  });

  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final bool enabled;

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  Future<void> _openPicker(BuildContext context) async {
    final maxDate = DateTime(
      DateTime.now().year - AppConstants.driverMinAgeYears,
      DateTime.now().month,
      DateTime.now().day,
    );
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? maxDate,
      firstDate: DateTime(1940),
      lastDate: maxDate,
    );
    if (picked != null) onDateSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = selectedDate != null;

    return GestureDetector(
      onTap: enabled ? () => _openPicker(context) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 56.h,
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.borderDefault(context),
            width: 1.5.w,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Icon(
                Icons.cake_outlined,
                size: 20.w,
                color: AppColors.textSecondary(context),
              ),
              SizedBox(width: 12.w),
              Text(
                hasValue ? _formatDate(selectedDate!) : 'DD/MM/YYYY',
                style: hasValue
                    ? AppTextStyles.inputText(context)
                    : AppTextStyles.inputHint(context),
              ),
              const Spacer(),
              Icon(
                Icons.calendar_month_outlined,
                size: 18.w,
                color: AppColors.textSecondary(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
