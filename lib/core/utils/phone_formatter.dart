// lib/core/utils/phone_formatter.dart

import '../constants/app_constants.dart';

/// Utilities for formatting Algerian phone numbers.
abstract final class PhoneFormatter {
  PhoneFormatter._();

  /// Converts a local Algerian number (e.g. "0661234567") to E.164 format
  /// (e.g. "+213661234567"). The leading "0" is stripped and the country
  /// code "+213" is prepended.
  ///
  /// Assumes [localNumber] is already validated (10 digits, starts with 0).
  static String toE164(String localNumber) {
    assert(localNumber.isNotEmpty, 'localNumber must not be empty');
    final stripped = localNumber.startsWith(AppConstants.phonePrefix)
        ? localNumber.substring(1)
        : localNumber;
    return '${AppConstants.countryCode}$stripped';
  }

  /// Formats a local number for display as "06XX XXX XXX".
  /// Returns the raw number unchanged if it doesn't match the expected length.
  static String toDisplayFormat(String localNumber) {
    final digits = localNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length != AppConstants.phoneMaxLength) return localNumber;
    return '${digits.substring(0, 4)} ${digits.substring(4, 7)} ${digits.substring(7)}';
  }
}
