import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/constants/app_images.dart';
import '../../../../../../../core/theme/app_colors.dart';
import '../../../../data/models/passenger_ride_models.dart';

extension _VehicleCategoryAsset on VehicleCategory {
  String get iconAsset => switch (this) {
        VehicleCategory.car => AppImages.rideCar,
        VehicleCategory.motorcycle => AppImages.rideMoto,
        VehicleCategory.van => AppImages.rideVan,
      };
}

class VehicleCategorySelector extends StatelessWidget {
  const VehicleCategorySelector({
    super.key,
    required this.serviceType,
    required this.selected,
    required this.onChanged,
  });

  final ServiceType serviceType;
  final VehicleCategory selected;
  final void Function(VehicleCategory) onChanged;

  @override
  Widget build(BuildContext context) {
    final categories = serviceType.availableCategories;
    return Row(
      children: categories.map((category) {
        final isLast = category == categories.last;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 8.w),
            child: _CategoryTile(
              category: category,
              isSelected: selected == category,
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged(category);
              },
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CategoryTile extends StatefulWidget {
  const _CategoryTile({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final VehicleCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<_CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<_CategoryTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _press;
  late final Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _press = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _press, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _press.forward();
  void _onTapUp(TapUpDetails _) {
    _press.reverse();
    widget.onTap();
  }

  void _onTapCancel() => _press.reverse();

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _pressScale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 230),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(vertical: 18.h),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.surface(context),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.borderDefault(context),
              width: isSelected ? 1.5.w : 1.w,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.22),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: AnimatedScale(
              scale: isSelected ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutBack,
              child: Image.asset(
                widget.category.iconAsset,
                height: 40.w,
                width: 40.w,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
