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
import '../../../../shared/widgets/primary_button.dart';
import '../cubit/otp_cubit/otp_cubit.dart';
import '../cubit/otp_cubit/otp_state.dart';
import 'widgets/otp/change_number_bar_widget.dart';
import 'widgets/otp/otp_blocked_banner_widget.dart';
import 'widgets/otp/otp_error_row_widget.dart';
import 'widgets/otp/otp_resend_row_widget.dart';
import 'widgets/otp/otp_row_widget.dart';

/// Step 2 — OTP Verification screen.
///
/// Receives the phone number via GoRouter's [extra] field and displays
/// the last 4 digits in a confirmation label.
class OtpVerificationView extends StatefulWidget {
  const OtpVerificationView({super.key});

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  static const int _digitCount = 6;

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_digitCount, (_) => TextEditingController());
    _focusNodes = List.generate(_digitCount, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  /// Clears all digit controllers and puts focus on first box.
  void _clearDigits() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes.first.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OtpCubit, OtpState>(
      listener: (context, state) {
        if (state.status == OtpStatus.verified) {
          // Design-only: always navigate to LocationPermission (Step 3).
          // When the API is wired up, check user type and branch accordingly:
          //   new user        → Step 3 (Location Permission)
          //   existing user   → passenger home or Mode Selection (Step 7)
          context.go(RouteNames.modeSelection);
        }
      },
      builder: (context, state) {
        final cubit = context.read<OtpCubit>();
        final bool isBlocked = state.status == OtpStatus.blocked;
        final bool isVerifying = state.status == OtpStatus.verifying;
        final bool hasWrongCode = state.status == OtpStatus.wrongCode;

        return AppScaffold(
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

                  // ── Back / Change Number ─────────────────────────────────
                  ChangeNumberBarWidget(
                    onChangeTap: () => context.go(RouteNames.phone),
                  ),

                  SizedBox(height: 40.h),

                  // ── App Logo ─────────────────────────────────────────────
                  const AppLogoWidget(),

                  SizedBox(height: 32.h),

                  // ── Heading ──────────────────────────────────────────────
                  Text(
                    'Verify your number',
                    style: AppTextStyles.displayMedium(context),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 8.h),

                  // ── Subtitle with masked phone ───────────────────────────
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: AppTextStyles.bodyMedium(context),
                      children: [
                        const TextSpan(text: 'Code sent to '),
                        TextSpan(
                          text: '••••${state.lastFourDigits}',
                          style: AppTextStyles.bodyMedium(context).copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.text(context),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // ── Blocked banner ───────────────────────────────────────
                  if (isBlocked)
                    OtpBlockedBannerWidget(
                        seconds: state.blockSecondsRemaining),

                  // ── OTP digit row ────────────────────────────────────────
                  if (!isBlocked)
                    OtpRowWidget(
                      controllers: _controllers,
                      focusNodes: _focusNodes,
                      cubit: cubit,
                      hasError: hasWrongCode,
                      enabled: !isVerifying,
                    ),

                  // ── Inline error (wrong code) ────────────────────────────
                  if (!isBlocked)
                    AnimatedSize(
                      duration: const Duration(milliseconds: 160),
                      curve: Curves.easeOut,
                      child: hasWrongCode && state.errorMessage.isNotEmpty
                          ? Padding(
                              padding: EdgeInsets.only(top: 12.h),
                              child: OtpErrorRowWidget(
                                  message: state.errorMessage),
                            )
                          : const SizedBox.shrink(),
                    ),

                  SizedBox(height: 36.h),

                  // ── Verify button ────────────────────────────────────────
                  if (!isBlocked)
                    PrimaryButton(
                      label: 'Verify',
                      isEnabled: state.isComplete && !isVerifying && !isBlocked,
                      isLoading: isVerifying,
                      onPressed: cubit.verifyOtp,
                    ),

                  SizedBox(height: 28.h),

                  // ── Resend row ───────────────────────────────────────────
                  if (!isBlocked)
                    OtpResendRowWidget(
                      state: state,
                      onResend: () {
                        _clearDigits();
                        cubit.resendOtp();
                      },
                    ),

                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
