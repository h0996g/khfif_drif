// lib/features/auth/data/auth_repository.dart

/// Simple mock repository for the auth feature.
///
/// No abstract interfaces, no use cases, no Either.
/// The Cubit calls this directly.
///
/// Replace the mock body with real Dio/HTTP logic when the API is ready.
final class AuthRepository {
  const AuthRepository();

  /// Sends an OTP to [phoneE164] (e.g. "+213661234567").
  ///
  /// Returns normally on success.
  /// Throws a [String] error message on failure.
  Future<void> sendOtp(String phoneE164) async {
    // Simulates network latency so the loading state is visible in the UI.
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    // ── Uncomment to test the error path ──────────────────────────────────
    // throw 'Could not send OTP. Please try again.';
    // ─────────────────────────────────────────────────────────────────────
  }

  /// Verifies the submitted [otp] code for the active session.
  ///
  /// Returns normally on correct code.
  /// Throws on wrong code so the cubit can track attempts.
  ///
  /// Replace the mock body with real API logic when ready.
  Future<void> verifyOtp(String otp) async {
    await Future<void>.delayed(const Duration(milliseconds: 1200));

    // ── Mock: treat "000000" as always-wrong, everything else succeeds ────
    if (otp == '000000') throw 'Wrong OTP';
    // ─────────────────────────────────────────────────────────────────────
  }
}
