// lib/features/driver/presentation/views/widgets/fields/driver_year_dropdown_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../../core/constants/app_constants.dart';
import '../../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../../core/theme/app_text_styles.dart';

/// Tappable field that opens a bottom sheet with a scrollable year list
/// (current year down to [AppConstants.vehicleYearFirst]).
class DriverYearDropdownWidget extends StatelessWidget {
  const DriverYearDropdownWidget({
    super.key,
    required this.selectedYear,
    required this.onChanged,
    required this.enabled,
  });

  final int? selectedYear;
  final ValueChanged<int> onChanged;
  final bool enabled;

  void _openSheet(BuildContext context) {
    final currentYear = DateTime.now().year;
    final years = List.generate(
      currentYear - AppConstants.vehicleYearFirst + 1,
      (i) => currentYear - i,
    );

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 8.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.borderDefault(ctx),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 12.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  'Select Year',
                  style: AppTextStyles.headingSmall(ctx),
                ),
              ),
              SizedBox(height: 8.h),
              SizedBox(
                height: 300.h,
                child: ListView.builder(
                  itemCount: years.length,
                  itemBuilder: (_, index) {
                    final year = years[index];
                    final isSelected = year == selectedYear;
                    return ListTile(
                      title: Text(
                        year.toString(),
                        style: AppTextStyles.bodyMedium(ctx).copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.text(ctx),
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_rounded,
                              color: AppColors.primary, size: 20.w)
                          : null,
                      onTap: () {
                        Navigator.of(ctx).pop();
                        onChanged(year);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = selectedYear != null;

    return GestureDetector(
      onTap: enabled ? () => _openSheet(context) : null,
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
                Icons.calendar_today_outlined,
                size: 20.w,
                color: AppColors.textSecondary(context),
              ),
              SizedBox(width: 12.w),
              Text(
                hasValue ? selectedYear.toString() : 'Select year',
                style: hasValue
                    ? AppTextStyles.inputText(context)
                    : AppTextStyles.inputHint(context),
              ),
              const Spacer(),
              Icon(
                Icons.expand_more_rounded,
                size: 20.w,
                color: AppColors.textSecondary(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
