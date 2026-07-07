// lib/features/auth/data/repo/auth_repository.dart

import '../../../../core/constants/auth_api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/driver_location_streamer.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/session/auth_session.dart';
import '../models/auth_tokens_model.dart';

final class AuthRepository {
  const AuthRepository();

  /// Sends an OTP to [phoneE164] (e.g. "+213661234567").
  Future<void> sendOtp(String phoneE164) => DioClient.post(
        path: AuthApiConstants.otpRequest,
        data: {'phone': phoneE164},
      );

  /// Verifies [otp] for [phoneE164], persists the access token, and returns
  /// the parsed tokens (including [AuthTokensModel.isNewUser]).
  Future<AuthTokensModel> verifyOtp(String phoneE164, String otp) async {
    final response = await DioClient.post(
      path: AuthApiConstants.otpVerify,
      data: {'phone': phoneE164, 'code': otp},
    );
    final tokens =
        AuthTokensModel.fromJson(response.data as Map<String, dynamic>);
    await AuthSession.setTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    await AuthSession.setIsNewUser(tokens.isNewUser);
    return tokens;
  }

  Future<void> switchRole(String targetRole) async {
    final response = await DioClient.post(
      path: AuthApiConstants.switchRole,
      data: {'targetRole': targetRole},
    );
    final data = response.data as Map<String, dynamic>;

    await AuthSession.setAccessToken(data['accessToken'] as String);
  }

  /// Calls the logout endpoint, clears all local tokens, and navigates to the
  /// phone entry screen. Errors from the API are silently ignored so that the
  /// user is always logged out locally even if the network call fails.
  Future<void> logout() async {
    try {
      await DioClient.post(
        path: AuthApiConstants.logout,
        data: {},
      );
    } catch (_) {}
    await DriverLocationStreamer.stopAndDisconnect();
    await AuthSession.clearSession();
    AppRouter.router.go(RouteNames.phone);
  }
}
