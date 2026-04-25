// lib/features/driver/presentation/views/driver_rejection_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/router/route_names.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../../../shared/widgets/primary_button.dart';

/// Shown when admin rejects the driver's application.
/// Displays the specific rejection reason and allows re-submission.
class DriverRejectionView extends StatelessWidget {
  const DriverRejectionView({super.key, required this.rejectionReason});

  final String rejectionReason;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: AppScaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Icon ──────────────────────────────────────────────────────
              Icon(
                Icons.cancel_outlined,
                size: 72.w,
                color: AppColors.error,
              ),

              SizedBox(height: 24.h),

              // ── Title ─────────────────────────────────────────────────────
              Text(
                AppStrings.rejectionTitle,
                style: AppTextStyles.displayMedium(context),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 20.h),

              // ── Reason label ──────────────────────────────────────────────
              Text(
                'Reason:',
                style: AppTextStyles.labelMedium(context)
                    .copyWith(fontWeight: FontWeight.w600),
              ),

              SizedBox(height: 8.h),

              // ── Rejection reason container ────────────────────────────────
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  rejectionReason.isNotEmpty
                      ? rejectionReason
                      : 'Your application did not meet our requirements.',
                  style: AppTextStyles.bodyMedium(context),
                ),
              ),

              SizedBox(height: 40.h),

              // ── CTA ───────────────────────────────────────────────────────
              PrimaryButton(
                label: AppStrings.resubmitDocuments,
                isEnabled: true,
                onPressed: () => context.go(RouteNames.driverProfile),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
