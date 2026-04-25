// lib/features/driver/presentation/views/widgets/fields/driver_plate_field_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'driver_text_field_widget.dart';

/// Plate number field with [AlgerianPlateFormatter] that auto-inserts hyphens
/// as the user types, producing the format NNNNN-NNN-NN.
class DriverPlateFieldWidget extends StatelessWidget {
  const DriverPlateFieldWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onFocusLost,
    required this.error,
    required this.enabled,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onFocusLost;
  final String error;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return DriverTextFieldWidget(
      controller: controller,
      focusNode: focusNode,
      hintText: 'e.g. 12345-123-12',
      icon: Icons.pin_outlined,
      onChanged: onChanged,
      onFocusLost: onFocusLost,
      error: error,
      enabled: enabled,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      textCapitalization: TextCapitalization.none,
      inputFormatters: [AlgerianPlateFormatter()],
    );
  }
}

/// Formats input as NNNNN-NNN-NN, inserting hyphens automatically.
/// Only digits are accepted; the formatter limits to 10 digits total.
class AlgerianPlateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits =
        newValue.text.replaceAll(RegExp(r'\D'), '');
    final capped =
        digits.length > 10 ? digits.substring(0, 10) : digits;

    final buffer = StringBuffer();
    for (int i = 0; i < capped.length; i++) {
      if (i == 5 || i == 8) buffer.write('-');
      buffer.write(capped[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
