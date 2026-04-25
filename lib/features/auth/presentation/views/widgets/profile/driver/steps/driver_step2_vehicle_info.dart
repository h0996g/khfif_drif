import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

class DriverStep2VehicleInfo extends StatefulWidget {
  const DriverStep2VehicleInfo({super.key});

  @override
  State<DriverStep2VehicleInfo> createState() => _DriverStep2VehicleInfoState();
}

class _DriverStep2VehicleInfoState extends State<DriverStep2VehicleInfo> {
  late final TextEditingController _makeController = TextEditingController();
  late final TextEditingController _modelController = TextEditingController();
  late final TextEditingController _colorController = TextEditingController();
  late final TextEditingController _plateController = TextEditingController();

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverProfileCubit, DriverProfileState>(
      buildWhen: (prev, curr) => prev.vehicleInfo != curr.vehicleInfo,
      builder: (context, state) {
        final cubit = context.read<DriverProfileCubit>();
        final vehicle = state.vehicleInfo;
        final isSubmitting = state.status == DriverRegistrationStatus.loading;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Car Make ───────────────────────────────────────────────────────
              const ProfileFieldLabelWidget(label: AppStrings.fieldCarMake),
              SizedBox(height: 8.h),
              DriverTextFieldWidget(
                controller: _makeController,
                hintText: 'e.g. Toyota',
                icon: Icons.directions_car_outlined,
                onChanged: cubit.vehicleMakeChanged,
                error: vehicle.vehicleMakeError,
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
                controller: _modelController,
                hintText: 'e.g. Corolla',
                icon: Icons.drive_eta_outlined,
                onChanged: cubit.vehicleModelChanged,
                error: vehicle.vehicleModelError,
                enabled: !isSubmitting,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r"[a-zA-ZÀ-ÿ0-9 '\-]")),
                ],
              ),

              SizedBox(height: 24.h),

              // ── Year ───────────────────────────────────────────────────────────
              const ProfileFieldLabelWidget(label: AppStrings.fieldYear),
              SizedBox(height: 8.h),
              DriverYearDropdownWidget(
                selectedYear: vehicle.vehicleYear,
                onChanged: cubit.vehicleYearChanged,
                enabled: !isSubmitting,
              ),

              SizedBox(height: 24.h),

              // ── Color ──────────────────────────────────────────────────────────
              const ProfileFieldLabelWidget(label: AppStrings.fieldColor),
              SizedBox(height: 8.h),
              DriverTextFieldWidget(
                controller: _colorController,
                hintText: 'e.g. White',
                icon: Icons.color_lens_outlined,
                onChanged: cubit.vehicleColorChanged,
                error: vehicle.vehicleColorError,
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
                controller: _plateController,
                onChanged: cubit.plateNumberChanged,
                error: vehicle.plateNumberError,
                enabled: !isSubmitting,
              ),

              SizedBox(height: 24.h),

              // ── Vehicle Photo ──────────────────────────────────────────────────
              const ProfileFieldLabelWidget(
                  label: AppStrings.fieldVehiclePhoto),
              SizedBox(height: 8.h),
              _VehiclePhotoButton(
                photoPath: vehicle.vehiclePhotoPath,
                onTap: isSubmitting ? null : cubit.pickVehiclePhoto,
              ),
            ],
          ),
        );
      },
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
