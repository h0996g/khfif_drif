import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../shared/widgets/primary_button.dart';
import '../../../cubit/otp_cubit/otp_cubit.dart';
import '../../../cubit/otp_cubit/otp_state.dart';
import 'otp_blocked_banner_widget.dart';
import 'otp_error_row_widget.dart';
import 'otp_resend_row_widget.dart';
import 'otp_row_widget.dart';

class OtpVerificationFormSection extends StatefulWidget {
  const OtpVerificationFormSection({super.key});

  @override
  State<OtpVerificationFormSection> createState() =>
      _OtpVerificationFormSectionState();
}

class _OtpVerificationFormSectionState
    extends State<OtpVerificationFormSection> {
  static const int _digitCount = 6;

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_digitCount, (_) => TextEditingController());
    _focusNodes = List.generate(_digitCount, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _updateCompletionState() {
    final isComplete =
        _controllers.every((controller) => controller.text.isNotEmpty);
    if (isComplete != _isComplete) {
      setState(() => _isComplete = isComplete);
    }
  }

  void _syncDigits(List<String> digits, {required bool requestFocus}) {
    final values = digits.length == _digitCount
        ? digits
        : List<String>.filled(_digitCount, '');

    for (var i = 0; i < _digitCount; i++) {
      if (_controllers[i].text == values[i]) continue;
      _controllers[i].value = TextEditingValue(
        text: values[i],
        selection: TextSelection.collapsed(offset: values[i].length),
      );
    }

    final isComplete = values.every((digit) => digit.isNotEmpty);
    if (isComplete != _isComplete) {
      setState(() => _isComplete = isComplete);
    }

    if (requestFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _focusNodes.first.requestFocus();
        }
      });
    }
  }

  void _clearDigits() {
    for (final controller in _controllers) {
      controller.clear();
    }
    if (_isComplete) {
      setState(() => _isComplete = false);
    }
    _focusNodes.first.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<OtpCubit>();

    return BlocListener<OtpCubit, OtpState>(
      listenWhen: (previous, current) =>
          !listEquals(previous.digits, current.digits) ||
          previous.status != current.status,
      listener: (context, state) {
        _syncDigits(
          state.digits,
          requestFocus: state.status != OtpStatus.blocked &&
              state.digits.every((digit) => digit.isEmpty),
        );
      },
      child: BlocBuilder<OtpCubit, OtpState>(
        buildWhen: (previous, current) =>
            previous.status != current.status ||
            previous.errorMessage != current.errorMessage ||
            previous.secondsRemaining != current.secondsRemaining ||
            previous.resendCount != current.resendCount ||
            previous.blockSecondsRemaining != current.blockSecondsRemaining,
        builder: (context, state) {
          final isBlocked = state.status == OtpStatus.blocked;
          final isVerifying = state.status == OtpStatus.verifying;
          final hasWrongCode = state.status == OtpStatus.wrongCode;

          return Column(
            children: [
              if (isBlocked)
                OtpBlockedBannerWidget(seconds: state.blockSecondsRemaining),
              if (!isBlocked)
                OtpRowWidget(
                  controllers: _controllers,
                  focusNodes: _focusNodes,
                  hasError: hasWrongCode,
                  enabled: !isVerifying,
                  onDigitChanged: (index, value) {
                    cubit.digitChanged(index, value);
                    _updateCompletionState();
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
                  isEnabled: _isComplete && !isVerifying,
                  isLoading: isVerifying,
                  onPressed: cubit.verifyOtp,
                ),
              SizedBox(height: 28.h),
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
          );
        },
      ),
    );
  }
}
