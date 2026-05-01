// lib/features/auth/presentation/views/widgets/profile/driver/steps/driver_step3_documents.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../../../core/widgets/image_source_bottom_sheet.dart';
import '../../../../../../data/models/driver_document.dart';
import '../../../../../cubit/driver_profile_cubit/driver_profile_cubit.dart';
import '../../../../../cubit/driver_profile_cubit/driver_profile_state.dart';
import '../fields/driver_document_flip_card_widget.dart';
import '../fields/driver_document_single_card_widget.dart';

class DriverStep3Documents extends StatelessWidget {
  const DriverStep3Documents({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverProfileCubit, DriverProfileState>(
      buildWhen: (prev, curr) =>
          prev.documents != curr.documents || prev.status != curr.status,
      builder: (context, state) {
        final cubit = context.read<DriverProfileCubit>();
        final docs = state.documents;
        final isSubmitting = state.status == DriverRegistrationStatus.loading;

        Future<void> pick(DriverDocumentType type) async {
          final source = await showImageSourceSheet(context);
          if (source != null) cubit.pickDocument(type, source);
        }

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Info hint ───────────────────────────────────────────────────
              _InfoHint(),
              SizedBox(height: 24.h),

              // ── National ID ─────────────────────────────────────────────────
              DriverDocumentFlipCardWidget(
                label: 'National ID',
                frontDocument: docs.nationalIdFront,
                backDocument: docs.nationalIdBack,
                onFrontTap: () => pick(DriverDocumentType.nationalIdFront),
                onBackTap: () => pick(DriverDocumentType.nationalIdBack),
                icon: Icons.badge_outlined,
                enabled: !isSubmitting,
              ),

              SizedBox(height: 20.h),

              // ── Driver's License ────────────────────────────────────────────
              DriverDocumentFlipCardWidget(
                label: "Driver's License",
                frontDocument: docs.licenseFront,
                backDocument: docs.licenseBack,
                onFrontTap: () => pick(DriverDocumentType.licenseFront),
                onBackTap: () => pick(DriverDocumentType.licenseBack),
                icon: Icons.credit_card_outlined,
                enabled: !isSubmitting,
              ),

              SizedBox(height: 20.h),

              // ── Vehicle Registration ────────────────────────────────────────
              const _SectionLabel(text: 'Vehicle Registration'),
              SizedBox(height: 8.h),
              DriverDocumentSingleCardWidget(
                label: 'Vehicle Registration',
                badgeLabel: 'REG',
                document: docs.vehicleRegistration,
                onTap: () => pick(DriverDocumentType.vehicleRegistration),
                enabled: !isSubmitting,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

class _InfoHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              color: AppColors.primary, size: 15.w),
          SizedBox(width: 8.w),
          Text(
            'JPG, PNG or PDF • Max 5 MB per file',
            style: AppTextStyles.labelSmall(context)
                .copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.labelMedium(context)
          .copyWith(fontWeight: FontWeight.w600),
    );
  }
}
