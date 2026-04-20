// lib/core/constants/app_constants.dart

abstract final class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'Khfif Drif';

  // Algeria phone
  static const String countryCode = '+213';
  static const String countryFlag = '🇩🇿';
  static const String countryIso = 'DZ';
  static const int phoneMaxLength = 10;
  static const String phonePrefix = '0';
  static const String phoneHint = '06XX XXX XXX';

  // OTP
  static const int otpLength = 6;
  static const int otpExpirySeconds = 60;

  // Design system — reference size (used by ScreenUtil)
  static const double designWidth = 375.0;
  static const double designHeight = 812.0;
}
