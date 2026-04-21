// lib/features/auth/presentation/views/widgets/otp_row_widget.dart

import 'package:flutter/material.dart';

import '../../../cubit/otp_cubit/otp_cubit.dart';
import 'otp_digit_field.dart';

/// 6-box OTP digit row.
class OtpRowWidget extends StatelessWidget {
  const OtpRowWidget({
    super.key,
    required this.controllers,
    required this.focusNodes,
    required this.cubit,
    required this.hasError,
    required this.enabled,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final OtpCubit cubit;
  final bool hasError;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        controllers.length,
        (i) => OtpDigitField(
          index: i,
          controller: controllers[i],
          focusNode: focusNodes[i],
          nextFocusNode: i < controllers.length - 1 ? focusNodes[i + 1] : null,
          previousFocusNode: i > 0 ? focusNodes[i - 1] : null,
          hasError: hasError,
          enabled: enabled,
          onChanged: (value) => cubit.digitChanged(i, value),
        ),
      ),
    );
  }
}
