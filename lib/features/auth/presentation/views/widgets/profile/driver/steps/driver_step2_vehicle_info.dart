import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../../core/constants/app_strings.dart';
import '../../../../../../../../core/widgets/image_source_bottom_sheet.dart';

import '../../../../../../data/models/driver_document.dart';
import '../../profile_field_label_widget.dart';
import '../../../../../cubit/driver_profile_cubit/driver_profile_cubit.dart';
import '../../../../../cubit/driver_profile_cubit/driver_profile_state.dart';
import '../fields/driver_document_single_card_widget.dart';
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

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
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
              DriverDocumentSingleCardWidget(
                label: AppStrings.fieldVehiclePhoto,
                badgeLabel: 'PHOTO',
                document: DriverDocument(
                  status: vehicle.vehiclePhotoPath != null
                      ? UploadStatus.uploaded
                      : UploadStatus.idle,
                  filePath: vehicle.vehiclePhotoPath,
                ),
                onTap: () async {
                  final source = await showImageSourceSheet(context);
                  if (source != null) cubit.pickVehiclePhoto(source);
                },
                enabled: !isSubmitting,
              ),

              SizedBox(height: 12.h),
            ],
          ),
        );
      },
    );
  }
}
