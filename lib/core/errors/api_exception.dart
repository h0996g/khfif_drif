/// A normalised API failure carrying the machine-readable `code` from the
/// backend error envelope (`{ error: { code, message, details } }`) alongside
/// the human-readable message.
///
/// [DioClient] throws this from every request helper. `toString()` returns the
/// bare message, so the long-standing `catch (e) => e.toString()` call sites
/// keep rendering exactly what they always did; callers that need to branch on
/// a specific failure — a stale-view `409`, the wallet balance gate — can
/// pattern-match on [code] instead of sniffing message substrings.
final class ApiException implements Exception {
  const ApiException({
    required this.message,
    this.code = '',
    this.statusCode,
  });

  /// User-facing message, already localised by the backend.
  final String message;

  /// Backend error code, e.g. `TOPUP_PENDING_EXISTS`. Empty for transport-level
  /// failures (timeouts, no connectivity) that never reached the API.
  final String code;

  final int? statusCode;

  bool get isConflict => statusCode == 409;

  bool hasCode(String value) => code == value;

  @override
  String toString() => message;
}
