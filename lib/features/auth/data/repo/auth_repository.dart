// lib/features/auth/data/repo/auth_repository.dart

import '../models/gender.dart';

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

  /// Saves the new passenger's basic profile information.
  ///
  /// [email] is optional (nullable).
  /// Replace the mock body with a real API call when ready.
  Future<void> savePassengerProfile({
    required String fullName,
    required Gender gender,
    String? email,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    if (fullName == "error") {
      throw 'Failed to save profile. Please try again.';
    }
    // ── Uncomment to test the error path ──────────────────────────────────
    // throw 'Failed to save profile. Please try again.';
    // ─────────────────────────────────────────────────────────────────────
  }

  /// Saves the driver's personal info (Step 1 of driver registration).
  ///
  /// Creates the account as Passenger-type first; promoted to Driver after
  /// document review and admin approval. API payload: { fullName, gender }.
  Future<void> saveDriverPersonalInfo({
    required String fullName,
    required Gender gender,
    required DateTime dateOfBirth,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 1000));

    // ── Uncomment to test the error path ──────────────────────────────────
    // throw 'Failed to save profile. Please try again.';
    // ─────────────────────────────────────────────────────────────────────
  }

  /// Submits driver vehicle info and documents for admin review (Step 3).
  ///
  /// In production this would multipart-upload file bytes. Mock simulates
  /// latency only. Account status becomes "Pending Review" after this call.
  Future<void> submitDriverDocuments({
    required String nationalIdFrontPath,
    required String nationalIdBackPath,
    required String licenseFrontPath,
    required String licenseBackPath,
    required String vehicleRegistrationPath,
    required String vehiclePhotoPath,
    required String vehicleMake,
    required String vehicleModel,
    required int vehicleYear,
    required String vehicleColor,
    required String plateNumber,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    // ── Uncomment to test the error path ──────────────────────────────────
    // throw 'Document submission failed. Please try again.';
    // ─────────────────────────────────────────────────────────────────────
  }
}
