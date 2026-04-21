// lib/core/utils/validators.dart

import '../constants/app_strings.dart';
import '../constants/validation_patterns.dart';

/// Stateless validator helpers used in form fields and cubits.
abstract final class Validators {
  Validators._();

  /// Returns `null` if [value] is a valid Algerian mobile number,
  /// otherwise returns an error message string.
  static String? dzPhone(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.phoneEmpty;
    }
    if (!ValidationPatterns.dzPhone.hasMatch(value)) {
      return AppStrings.phoneInvalid;
    }
    return null;
  }
}
