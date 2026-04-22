// lib/features/auth/presentation/views/otp_verification_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_logo_widget.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../cubit/otp_cubit/otp_cubit.dart';
import '../cubit/otp_cubit/otp_state.dart';
import 'widgets/otp/change_number_bar_widget.dart';
import 'widgets/otp/otp_verification_form_section.dart';

/// Step 2 — OTP Verification screen.
///
/// Receives the phone number via GoRouter's [extra] field and displays
/// the last 4 digits in a confirmation label.
class OtpVerificationView extends StatelessWidget {
  const OtpVerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final lastFourDigits = context.read<OtpCubit>().state.lastFourDigits;

    return BlocListener<OtpCubit, OtpState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == OtpStatus.verified,
      listener: (context, state) {
        if (state.status == OtpStatus.verified) {
          // TODO(Story-7): branch on user type returned by API —
          //   new user      → location permission screen
          //   existing user → passenger home or mode selection
          context.go(RouteNames.modeSelection);
        }
      },
      child: AppScaffold(
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 56.h),
                ChangeNumberBarWidget(
                  onChangeTap: () => context.go(RouteNames.phone),
                ),
                SizedBox(height: 40.h),
                const AppLogoWidget(),
                SizedBox(height: 32.h),
                Text(
                  'Verify your number',
                  style: AppTextStyles.displayMedium(context),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppTextStyles.bodyMedium(context),
                    children: [
                      const TextSpan(text: 'Code sent to '),
                      TextSpan(
                        text: '••••$lastFourDigits',
                        style: AppTextStyles.bodyMedium(context).copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.text(context),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.h),
                const OtpVerificationFormSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
