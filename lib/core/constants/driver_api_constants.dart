abstract final class DriverApiConstants {
  DriverApiConstants._();

  static const String _base = '/api/driver';

  // Registration
  static const String registration = '$_base/registration';

  // KYC
  static const String kycSubmit = '$_base/kyc/submit';
  static const String kycStatus = '$_base/kyc/status';

  // Availability
  static const String goOnline = '$_base/availability/online';
  static const String goOffline = '$_base/availability/offline';

  // Profile
  static const String profile = '$_base/profile';
  static const String serviceTypes = '$_base/profile/service-types';
}
