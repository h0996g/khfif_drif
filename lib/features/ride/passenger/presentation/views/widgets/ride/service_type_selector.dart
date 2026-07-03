import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/passenger_ride_models.dart';

class ServiceTypeSelector extends StatelessWidget {
  const ServiceTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final ServiceType selected;
  final void Function(ServiceType) onChanged;

  @override
  Widget build(BuildContext context) {
    const types = ServiceType.values;
    final selectedIndex = types.indexOf(selected);

    return LayoutBuilder(
      builder: (context, constraints) {
        final segmentWidth = constraints.maxWidth / types.length;

        return Container(
          height: 52.h,
          padding: EdgeInsets.all(4.r),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: AppColors.borderDefault(context)),
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                alignment: Alignment(
                  types.length == 1
                      ? 0
                      : -1 + (2 * selectedIndex) / (types.length - 1),
                  0,
                ),
                child: Container(
                  width: segmentWidth - 4.w,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.32),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: types.map((type) {
                  final isSelected = type == selected;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onChanged(type);
                      },
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: AppTextStyles.labelMedium(context).copyWith(
                            color: isSelected
                                ? AppColors.white
                                : AppColors.textSecondary(context),
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                          child: Text(type.label),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}
