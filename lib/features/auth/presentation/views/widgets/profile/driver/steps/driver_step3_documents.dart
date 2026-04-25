import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../../core/constants/app_strings.dart';
import '../../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../data/models/driver_document.dart';
import '../../../../../cubit/driver_profile_cubit/driver_profile_cubit.dart';
import '../../../../../cubit/driver_profile_cubit/driver_profile_state.dart';
import '../fields/driver_document_upload_tile_widget.dart';

class DriverStep3Documents extends StatelessWidget {
  const DriverStep3Documents({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverProfileCubit, DriverProfileState>(
      buildWhen: (prev, curr) =>
          prev.documents != curr.documents ||
          prev.status != curr.status,
      builder: (context, state) {
        final cubit = context.read<DriverProfileCubit>();
        final docs = state.documents;
        final isSubmitting = state.status == DriverRegistrationStatus.loading;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Info banner ────────────────────────────────────────────────────
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        color: AppColors.primary, size: 16.w),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'JPG, PNG or PDF • Max 5 MB per file',
                        style: AppTextStyles.bodySmall(context).copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // ── National ID ────────────────────────────────────────────────────
              Text(
                'National ID',
                style: AppTextStyles.labelMedium(context)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8.h),
              DriverDocumentUploadTileWidget(
                label: AppStrings.docNationalIdFront,
                document: docs.nationalIdFront,
                onTap: () =>
                    cubit.pickDocument(DriverDocumentType.nationalIdFront),
                enabled: !isSubmitting,
              ),
              SizedBox(height: 8.h),
              DriverDocumentUploadTileWidget(
                label: AppStrings.docNationalIdBack,
                document: docs.nationalIdBack,
                onTap: () =>
                    cubit.pickDocument(DriverDocumentType.nationalIdBack),
                enabled: !isSubmitting,
              ),

              SizedBox(height: 20.h),

              // ── Driver's License ───────────────────────────────────────────────
              Text(
                "Driver's License",
                style: AppTextStyles.labelMedium(context)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8.h),
              DriverDocumentUploadTileWidget(
                label: AppStrings.docLicenseFront,
                document: docs.licenseFront,
                onTap: () =>
                    cubit.pickDocument(DriverDocumentType.licenseFront),
                enabled: !isSubmitting,
              ),
              SizedBox(height: 8.h),
              DriverDocumentUploadTileWidget(
                label: AppStrings.docLicenseBack,
                document: docs.licenseBack,
                onTap: () =>
                    cubit.pickDocument(DriverDocumentType.licenseBack),
                enabled: !isSubmitting,
              ),

              SizedBox(height: 20.h),

              // ── Vehicle Registration ───────────────────────────────────────────
              Text(
                'Vehicle Registration',
                style: AppTextStyles.labelMedium(context)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8.h),
              DriverDocumentUploadTileWidget(
                label: AppStrings.docVehicleRegistration,
                document: docs.vehicleRegistration,
                onTap: () =>
                    cubit.pickDocument(DriverDocumentType.vehicleRegistration),
                enabled: !isSubmitting,
              ),
            ],
          ),
        );
      },
    );
  }
}
