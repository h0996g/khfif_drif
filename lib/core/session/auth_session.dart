import '../constants/cache_keys.dart';

import '../router/route_names.dart';
import '../storage/secure_storage_helper.dart';

final class AuthSession {
  AuthSession._();

  static String? _accessToken;
  static String? _refreshToken;
  static bool? _isNewUser;
  static bool? _waitingKycStatus;
  static bool? _hasDriverProfile;
  static String? _lastRole;

  static String? get accessToken => _accessToken;
  static String? get refreshToken => _refreshToken;
  static bool get isLoggedIn => _accessToken != null;
  static bool get isNewUser => _isNewUser ?? false;
  static bool get waitingKycStatus => _waitingKycStatus ?? false;
  static bool get hasDriverProfile => _hasDriverProfile ?? false;
  static String? get lastRole => _lastRole;

  static const String roleDriver = 'DRIVER';
  static const String rolePassenger = 'PASSENGER';

  /// Loads persisted session from secure storage. Call once at startup.
  static Future<void> loadSession() async {
    _accessToken = await SecureStorageHelper.read(
      key: CacheKeys.secureStorageKeys.accessTokenKey,
    );
    _refreshToken = await SecureStorageHelper.read(
      key: CacheKeys.secureStorageKeys.refreshTokenKey,
    );

    final isNewUserStr = await SecureStorageHelper.read(
      key: CacheKeys.secureStorageKeys.isNewUserKey,
    );
    _isNewUser = isNewUserStr == 'true';

    final isWaitingKycStr = await SecureStorageHelper.read(
      key: CacheKeys.secureStorageKeys.isWaitingKyc,
    );
    _waitingKycStatus = isWaitingKycStr == 'true';

    final hasDriverProfileStr = await SecureStorageHelper.read(
      key: CacheKeys.secureStorageKeys.hasDriverProfile,
    );
    _hasDriverProfile = hasDriverProfileStr == 'true';

    _lastRole = await SecureStorageHelper.read(
      key: CacheKeys.secureStorageKeys.lastRoleKey,
    );
  }

  /// Saves tokens, decodes the JWT payload, and persists the role.
  static Future<void> setTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    await SecureStorageHelper.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  static Future<void> setIsNewUser(bool value) async {
    _isNewUser = value;
    await SecureStorageHelper.write(
      key: CacheKeys.secureStorageKeys.isNewUserKey,
      value: value.toString(),
    );
  }

  static Future<void> setAccessToken(String accessToken) async {
    _accessToken = accessToken;
    await SecureStorageHelper.write(
      key: CacheKeys.secureStorageKeys.accessTokenKey,
      value: accessToken,
    );
  }

  static Future<void> setWaitingKycStatus(bool value) async {
    _waitingKycStatus = value;
    await SecureStorageHelper.write(
      key: CacheKeys.secureStorageKeys.isWaitingKyc,
      value: value.toString(),
    );
  }

  static Future<void> setHasDriverProfile(bool value) async {
    _hasDriverProfile = value;
    await SecureStorageHelper.write(
      key: CacheKeys.secureStorageKeys.hasDriverProfile,
      value: value.toString(),
    );
  }

  static Future<void> setLastRole(String role) async {
    _lastRole = role;
    await SecureStorageHelper.write(
      key: CacheKeys.secureStorageKeys.lastRoleKey,
      value: role,
    );
  }

  static Future<void> clearIsNewUser() async {
    _isNewUser = false;
    await SecureStorageHelper.remove(
      key: CacheKeys.secureStorageKeys.isNewUserKey,
    );
  }

  /// Clears all session state from memory and secure storage.
  static Future<void> clearSession() async {
    _accessToken = null;
    _refreshToken = null;
    _isNewUser = null;
    _waitingKycStatus = null;
    _hasDriverProfile = null;
    _lastRole = null;
    await SecureStorageHelper.remove(
      key: CacheKeys.secureStorageKeys.accessTokenKey,
    );
    await SecureStorageHelper.remove(
      key: CacheKeys.secureStorageKeys.refreshTokenKey,
    );
    await SecureStorageHelper.remove(
      key: CacheKeys.secureStorageKeys.isNewUserKey,
    );
    await SecureStorageHelper.remove(
      key: CacheKeys.secureStorageKeys.isWaitingKyc,
    );
    await SecureStorageHelper.remove(
      key: CacheKeys.secureStorageKeys.hasDriverProfile,
    );
    await SecureStorageHelper.remove(
      key: CacheKeys.secureStorageKeys.lastRoleKey,
    );
  }

  static String resolveInitialRoute() {
    if (!isLoggedIn) return RouteNames.phone;
    // A submitted or approved driver application means onboarding is done, even
    // if the isNewUser flag was never cleared (sessions from older builds).
    if (isNewUser && !waitingKycStatus && !hasDriverProfile) {
      return RouteNames.modeSelection;
    }
    if (_lastRole == roleDriver) return RouteNames.driverHome;
    return RouteNames.passengerHome;
  }
}
