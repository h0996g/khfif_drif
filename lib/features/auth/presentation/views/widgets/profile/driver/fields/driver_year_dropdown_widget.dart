// lib/features/auth/presentation/views/widgets/profile/driver/fields/driver_year_dropdown_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../../core/constants/app_constants.dart';
import '../../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../../../shared/widgets/bottomsheets/app_bottom_sheet.dart';
import '../../../../../../../../shared/widgets/app_text_field.dart';

/// Tappable field that opens a beautiful bottom sheet with a scrollable year list
/// (current year down to [AppConstants.vehicleYearFirst]).
class DriverYearDropdownWidget extends StatefulWidget {
  const DriverYearDropdownWidget({
    super.key,
    required this.selectedYear,
    required this.onChanged,
    required this.enabled,
  });

  final int? selectedYear;
  final ValueChanged<int> onChanged;
  final bool enabled;

  @override
  State<DriverYearDropdownWidget> createState() =>
      _DriverYearDropdownWidgetState();
}

class _DriverYearDropdownWidgetState extends State<DriverYearDropdownWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _getText());
  }

  @override
  void didUpdateWidget(covariant DriverYearDropdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedYear != oldWidget.selectedYear) {
      _controller.text = _getText();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getText() {
    if (widget.selectedYear == null) return '';
    return widget.selectedYear.toString();
  }

  void _openSheet() {
    final currentYear = DateTime.now().year;
    final years = List.generate(
      currentYear - AppConstants.vehicleYearFirst + 1,
      (i) => currentYear - i,
    );

    showAppBottomSheet<void>(
      context: context,
      title: 'Select Year',
      child: SizedBox(
        height: MediaQuery.of(context).size.height / 3,
        child: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 4.h),
          itemCount: years.length,
          itemBuilder: (_, index) {
            final year = years[index];
            final isSelected = year == widget.selectedYear;
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 4.h),
              child: InkWell(
                borderRadius: BorderRadius.circular(16.r),
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onChanged(year);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.text(context).withValues(alpha: 0.05)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Center(
                    child: Text(
                      year.toString(),
                      style: AppTextStyles.bodyLarge(context).copyWith(
                        color: isSelected
                            ? AppColors.text(context)
                            : AppColors.textSecondary(context),
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: _controller,
      readOnly: true,
      onTap: widget.enabled ? _openSheet : null,
      enabled: widget.enabled,
      hintText: 'Select year',
      prefixIcon: const Icon(Icons.calendar_month_outlined),
      suffixIcon: const Icon(Icons.expand_more_rounded),
    );
  }
}
