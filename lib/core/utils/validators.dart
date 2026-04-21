// lib/core/utils/validators.dart

import '../constants/app_strings.dart';
import '../constants/validation_patterns.dart';

/// Stateless validator helpers used in form fields and cubits.
abstract final class Validators {
  Validators._();

  static final _namePattern =
      RegExp(r"^[a-zA-ZÀ-ÿ]+([ '-][a-zA-ZÀ-ÿ]+)*$");
  static final _emailPattern =
      RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');

  /// Returns `null` if valid, otherwise an error message.
  static String? dzPhone(String? value) {
    if (value == null || value.isEmpty) return AppStrings.phoneEmpty;
    if (!ValidationPatterns.dzPhone.hasMatch(value)) return AppStrings.phoneInvalid;
    return null;
  }

  /// Returns an error message string, or empty string if valid.
  /// Empty [value] is treated as an error (field is required).
  static String name(String value) {
    if (value.isEmpty) return 'Full name is required';
    if (value.length < 2) return 'Name must be at least 2 characters';
    if (!_namePattern.hasMatch(value)) return 'Name must contain letters only';
    return '';
  }

  /// Returns an error message string, or empty string if valid.
  /// Empty [value] is always valid (email is optional).
  static String email(String value) {
    if (value.isEmpty) return '';
    if (!_emailPattern.hasMatch(value)) return 'Enter a valid email address';
    return '';
  }

  /// Returns an inline error for partial phone input (instant UX feedback).
  /// Returns `null` when there is no error to show yet.
  static String? dzPhonePartial(String value) {
    if (value.isEmpty) return null;
    if (!value.startsWith('0')) return 'Number must start with 0';
    if (value.length >= 2 && !RegExp(r'^0[567]').hasMatch(value)) {
      return 'Number must start with 05, 06, or 07';
    }
    return null;
  }
}
