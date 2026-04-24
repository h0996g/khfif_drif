import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pinput/pinput.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../shared/widgets/primary_button.dart';
import '../../../cubit/otp_cubit/otp_cubit.dart';
import '../../../cubit/otp_cubit/otp_state.dart';
import 'otp_blocked_banner_widget.dart';
import 'otp_error_row_widget.dart';
import 'otp_resend_row_widget.dart';

class OtpVerificationFormSection extends StatefulWidget {
  const OtpVerificationFormSection({super.key});

  @override
  State<OtpVerificationFormSection> createState() =>
      _OtpVerificationFormSectionState();
}

class _OtpVerificationFormSectionState
    extends State<OtpVerificationFormSection> {
  static const int _digitCount = 6;

  late final TextEditingController _controller;

  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncValue(String value) {
    if (_controller.text != value) {
      _controller.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }
    final isComplete = value.length == _digitCount;
    if (isComplete != _isComplete) {
      setState(() => _isComplete = isComplete);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OtpCubit>();

    final defaultTheme = PinTheme(
      width: 46.w,
      height: 56.h,
      textStyle: AppTextStyles.displaySmall(context).copyWith(
        fontWeight: FontWeight.w700,
        height: 1.0,
      ),
      decoration: BoxDecoration(
        color: AppColors.background(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.borderDefault(context),
          width: 1.5.w,
        ),
      ),
    );

    return BlocListener<OtpCubit, OtpState>(
      listenWhen: (previous, current) =>
          previous.otpValue != current.otpValue ||
          previous.status != current.status,
      listener: (context, state) => _syncValue(state.otpValue),
      child: BlocBuilder<OtpCubit, OtpState>(
        buildWhen: (previous, current) =>
            previous.status != current.status ||
            previous.errorMessage != current.errorMessage ||
            previous.secondsRemaining != current.secondsRemaining ||
            previous.resendCount != current.resendCount ||
            previous.blockSecondsRemaining != current.blockSecondsRemaining,
        builder: (context, state) {
          final isBlocked = state.status == OtpStatus.blocked;
          final isLoading = state.status == OtpStatus.loading;
          final hasWrongCode = state.status == OtpStatus.failure;

          return Column(
            children: [
              if (isBlocked)
                OtpBlockedBannerWidget(seconds: state.blockSecondsRemaining),
              if (!isBlocked)
                Pinput(
                  controller: _controller,
                  length: _digitCount,
                  autofocus: true,
                  enabled: !isLoading,
                  forceErrorState: hasWrongCode,
                  hapticFeedbackType: HapticFeedbackType.lightImpact,
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  defaultPinTheme: defaultTheme,
                  focusedPinTheme: defaultTheme.copyWith(
                    decoration: defaultTheme.decoration!.copyWith(
                      border: Border.all(
                        color: AppColors.primary,
                        width: 2.w,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  submittedPinTheme: defaultTheme.copyWith(
                    decoration: defaultTheme.decoration!.copyWith(
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        width: 1.5.w,
                      ),
                    ),
                  ),
                  errorPinTheme: defaultTheme.copyWith(
                    decoration: defaultTheme.decoration!.copyWith(
                      border: Border.all(
                        color: AppColors.error,
                        width: 1.5.w,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    cubit.otpChanged(value);
                    setState(() => _isComplete = value.length == _digitCount);
                  },
                ),
              if (!isBlocked)
                AnimatedSize(
                  duration: const Duration(milliseconds: 160),
                  curve: Curves.easeOut,
                  child: hasWrongCode && state.errorMessage.isNotEmpty
                      ? Padding(
                          padding: EdgeInsets.only(top: 12.h),
                          child: OtpErrorRowWidget(message: state.errorMessage),
                        )
                      : const SizedBox.shrink(),
                ),
              SizedBox(height: 36.h),
              if (!isBlocked)
                PrimaryButton(
                  label: 'Verify',
                  isEnabled: _isComplete && !isLoading,
                  isLoading: isLoading,
                  onPressed: cubit.verifyOtp,
                ),
              SizedBox(height: 28.h),
              if (!isBlocked)
                OtpResendRowWidget(
                  state: state,
                  onResend: () {
                    _controller.clear();
                    setState(() => _isComplete = false);
                    cubit.resendOtp();
                  },
                ),
              SizedBox(height: 24.h),
            ],
          );
        },
      ),
    );
  }
}
