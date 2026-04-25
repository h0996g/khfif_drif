// lib/features/driver/presentation/views/widgets/steps/driver_step2_vehicle_info.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../../core/constants/app_strings.dart';
import '../../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../../core/theme/app_text_styles.dart';
import '../../profile_field_label_widget.dart';
import '../../../../../cubit/driver_profile_cubit/driver_profile_cubit.dart';
import '../../../../../cubit/driver_profile_cubit/driver_profile_state.dart';
import '../fields/driver_plate_field_widget.dart';
import '../fields/driver_text_field_widget.dart';
import '../fields/driver_year_dropdown_widget.dart';

class DriverStep2VehicleInfo extends StatelessWidget {
  const DriverStep2VehicleInfo({
    super.key,
    required this.cubit,
    required this.state,
    required this.makeController,
    required this.modelController,
    required this.colorController,
    required this.plateController,
    required this.makeFocus,
    required this.modelFocus,
    required this.colorFocus,
    required this.plateFocus,
  });

  final DriverProfileCubit cubit;
  final DriverProfileState state;
  final TextEditingController makeController;
  final TextEditingController modelController;
  final TextEditingController colorController;
  final TextEditingController plateController;
  final FocusNode makeFocus;
  final FocusNode modelFocus;
  final FocusNode colorFocus;
  final FocusNode plateFocus;

  @override
  Widget build(BuildContext context) {
    final isSubmitting = state.status == DriverRegistrationStatus.submitting;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Car Make ───────────────────────────────────────────────────────
        const ProfileFieldLabelWidget(label: AppStrings.fieldCarMake),
        SizedBox(height: 8.h),
        DriverTextFieldWidget(
          controller: makeController,
          focusNode: makeFocus,
          nextFocus: modelFocus,
          hintText: 'e.g. Toyota',
          icon: Icons.directions_car_outlined,
          onChanged: cubit.vehicleMakeChanged,
          onFocusLost: cubit.vehicleMakeFocusLost,
          error: state.vehicleMakeTouched ? state.vehicleMakeError : '',
          enabled: !isSubmitting,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r"[a-zA-ZÀ-ÿ '\-]")),
          ],
        ),

        SizedBox(height: 24.h),

        // ── Model ──────────────────────────────────────────────────────────
        const ProfileFieldLabelWidget(label: AppStrings.fieldCarModel),
        SizedBox(height: 8.h),
        DriverTextFieldWidget(
          controller: modelController,
          focusNode: modelFocus,
          nextFocus: colorFocus,
          hintText: 'e.g. Corolla',
          icon: Icons.drive_eta_outlined,
          onChanged: cubit.vehicleModelChanged,
          onFocusLost: cubit.vehicleModelFocusLost,
          error: state.vehicleModelTouched ? state.vehicleModelError : '',
          enabled: !isSubmitting,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r"[a-zA-ZÀ-ÿ0-9 '\-]")),
          ],
        ),

        SizedBox(height: 24.h),

        // ── Year ───────────────────────────────────────────────────────────
        const ProfileFieldLabelWidget(label: AppStrings.fieldYear),
        SizedBox(height: 8.h),
        DriverYearDropdownWidget(
          selectedYear: state.vehicleYear,
          onChanged: cubit.vehicleYearChanged,
          enabled: !isSubmitting,
        ),

        SizedBox(height: 24.h),

        // ── Color ──────────────────────────────────────────────────────────
        const ProfileFieldLabelWidget(label: AppStrings.fieldColor),
        SizedBox(height: 8.h),
        DriverTextFieldWidget(
          controller: colorController,
          focusNode: colorFocus,
          nextFocus: plateFocus,
          hintText: 'e.g. White',
          icon: Icons.color_lens_outlined,
          onChanged: cubit.vehicleColorChanged,
          onFocusLost: cubit.vehicleColorFocusLost,
          error: state.vehicleColorTouched ? state.vehicleColorError : '',
          enabled: !isSubmitting,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r"[a-zA-ZÀ-ÿ ]")),
          ],
        ),

        SizedBox(height: 24.h),

        // ── Plate Number ───────────────────────────────────────────────────
        const ProfileFieldLabelWidget(label: AppStrings.fieldPlateNumber),
        SizedBox(height: 8.h),
        DriverPlateFieldWidget(
          controller: plateController,
          focusNode: plateFocus,
          onChanged: cubit.plateNumberChanged,
          onFocusLost: cubit.plateNumberFocusLost,
          error: state.plateNumberTouched ? state.plateNumberError : '',
          enabled: !isSubmitting,
        ),

        SizedBox(height: 24.h),

        // ── Vehicle Photo ──────────────────────────────────────────────────
        const ProfileFieldLabelWidget(label: AppStrings.fieldVehiclePhoto),
        SizedBox(height: 8.h),
        _VehiclePhotoButton(
          photoPath: state.vehiclePhotoPath,
          onTap: isSubmitting ? null : cubit.pickVehiclePhoto,
        ),
      ],
    );
  }
}

class _VehiclePhotoButton extends StatelessWidget {
  const _VehiclePhotoButton({required this.photoPath, required this.onTap});

  final String? photoPath;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoPath != null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 64.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color:
                hasPhoto ? AppColors.primary : AppColors.borderDefault(context),
            width: 1.5.w,
          ),
        ),
        child: Row(
          children: [
            Icon(
              hasPhoto
                  ? Icons.check_circle_rounded
                  : Icons.add_photo_alternate_outlined,
              size: 22.w,
              color: hasPhoto
                  ? AppColors.primary
                  : AppColors.textSecondary(context),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                hasPhoto
                    ? 'Photo selected — tap to change'
                    : 'Tap to add vehicle photo',
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: hasPhoto
                      ? AppColors.text(context)
                      : AppColors.textSecondary(context),
                ),
              ),
            ),
            if (!hasPhoto)
              Icon(
                Icons.chevron_right_rounded,
                size: 20.w,
                color: AppColors.textSecondary(context),
              ),
          ],
        ),
      ),
    );
  }
}
