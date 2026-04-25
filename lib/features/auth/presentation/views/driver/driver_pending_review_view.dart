// lib/features/driver/presentation/views/driver_pending_review_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/router/route_names.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../../../shared/widgets/primary_button.dart';

/// Shown after the driver successfully submits all documents.
/// Account status is now "Pending Review" — no back navigation allowed.
class DriverPendingReviewView extends StatelessWidget {
  const DriverPendingReviewView({super.key});

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
                Icons.hourglass_top_rounded,
                size: 72.w,
                color: AppColors.primary,
              ),

              SizedBox(height: 24.h),

              // ── Title ─────────────────────────────────────────────────────
              Text(
                AppStrings.pendingReviewTitle,
                style: AppTextStyles.displayMedium(context),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 12.h),

              // ── Body ──────────────────────────────────────────────────────
              Text(
                AppStrings.pendingReviewBody,
                style: AppTextStyles.bodyMedium(context),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 48.h),

              // ── CTA ───────────────────────────────────────────────────────
              PrimaryButton(
                label: AppStrings.goToHome,
                isEnabled: true,
                onPressed: () => context.go(RouteNames.passengerHome),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
