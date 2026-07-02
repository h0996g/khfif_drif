// lib/features/auth/presentation/views/widgets/profile/driver/fields/driver_color_picker_field_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../../../shared/widgets/bottomsheets/app_bottom_sheet.dart';
import '../../../../../../../../shared/widgets/app_text_field.dart';
import '../../../../../../domain/models/vehicle_color_option.dart';

/// Tappable field that opens a bottom sheet with a grid of color swatches.
/// The selected color's [name] is emitted via [onChanged] (a String, matching
/// the existing `vehicleColor` state).
class DriverColorPickerFieldWidget extends StatefulWidget {
  const DriverColorPickerFieldWidget({
    super.key,
    required this.selectedColor,
    required this.onChanged,
    required this.enabled,
    this.hintText = 'Select color',
  });

  final String? selectedColor;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final String hintText;

  @override
  State<DriverColorPickerFieldWidget> createState() =>
      _DriverColorPickerFieldWidgetState();
}

class _DriverColorPickerFieldWidgetState
    extends State<DriverColorPickerFieldWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.selectedColor ?? '');
  }

  @override
  void didUpdateWidget(covariant DriverColorPickerFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedColor != oldWidget.selectedColor) {
      _controller.text = widget.selectedColor ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openSheet() {
    showAppBottomSheet<void>(
      context: context,
      title: 'Select Color',
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
        itemCount: VehicleColorOption.all.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 16.h,
          crossAxisSpacing: 8.w,
          childAspectRatio: 0.82,
        ),
        itemBuilder: (context, index) {
          final option = VehicleColorOption.all[index];
          final isSelected = option.name == widget.selectedColor;
          return _ColorSwatch(
            option: option,
            isSelected: isSelected,
            onTap: () {
              Navigator.of(context).pop();
              widget.onChanged(option.name);
            },
          );
        },
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
      hintText: widget.hintText,
      prefixIcon: const Icon(Icons.color_lens_outlined),
      suffixIcon: const Icon(Icons.expand_more_rounded),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final VehicleColorOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: option.value,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : AppColors.borderDefault(context),
                width: isSelected ? 3.w : 1.w,
              ),
            ),
            alignment: Alignment.center,
            child: isSelected
                ? Icon(
                    Icons.check_rounded,
                    size: 22.w,
                    // Ensure the check is visible on light swatches.
                    color: option.value.computeLuminance() > 0.5
                        ? AppColors.black
                        : AppColors.white,
                  )
                : null,
          ),
          SizedBox(height: 6.h),
          Text(
            option.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelSmall(context).copyWith(
              color: isSelected
                  ? AppColors.text(context)
                  : AppColors.textSecondary(context),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
