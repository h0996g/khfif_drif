import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';
import '../constants/auth_api_constants.dart';
import '../errors/api_error_model.dart';
import '../router/app_router.dart';
import '../router/route_names.dart';
import '../session/auth_session.dart';
import '../../features/auth/data/models/auth_tokens_model.dart';
import 'driver_location_streamer.dart';
import 'ride_socket_service.dart';

final class DioClient {
  DioClient._();

  static late Dio _dio;
  static Completer<String>? _refreshCompleter;

  /// Full teardown for auth revocation detected over REST (401/403 with no
  /// valid refresh, or refresh itself failing): stop location streaming and
  /// the ride socket before clearing the session, mirroring
  /// [AuthRepository.logout] — otherwise the socket keeps running with a
  /// cleared session and auto-reconnects on its own backoff schedule.
  static Future<void> _forceLogout() async {
    DriverLocationStreamer.stop();
    await RideSocketService.disconnect();
    await AuthSession.clearSession();
    AppRouter.router.go(RouteNames.phone);
  }

  static void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout:
            const Duration(milliseconds: ApiConstants.connectTimeoutMs),
        receiveTimeout:
            const Duration(milliseconds: ApiConstants.receiveTimeoutMs),
        headers: {
          Headers.contentTypeHeader: Headers.jsonContentType,
          Headers.acceptHeader: Headers.jsonContentType,
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Respect an explicitly provided Authorization header — e.g. the
          // `Authorization: null` that refreshAccessToken sets to strip the
          // stale bearer — instead of overwriting it. Other auth endpoints
          // (switch-role, logout) still receive the access token normally.
          final token = AuthSession.accessToken;
          if (token != null && !options.headers.containsKey('Authorization')) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );

    // Attach a unique Idempotency-Key to every mutating request so the server
    // can safely de-duplicate retries. Auth endpoints are excluded — the refresh
    // call is internal and must not carry a key.
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final method = options.method.toUpperCase();
          final isAuth = options.path.startsWith(AuthApiConstants.base);
          if (!isAuth &&
              (method == 'POST' || method == 'PUT' || method == 'DELETE')) {
            options.headers['Idempotency-Key'] = _uuid();
          }
          handler.next(options);
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          final isRefreshCall =
              error.requestOptions.path.startsWith(AuthApiConstants.base);

          if (error.response?.statusCode != 401 ||
              AuthSession.refreshToken == null) {
            return handler.next(error);
          }

          // A 401 on the refresh call itself (expired/invalid refresh token)
          // must not be fed back into _refreshAccessToken(): that call is the
          // very one populating _refreshCompleter, so recursing here would
          // await a completer that can only be completed by this call —
          // deadlocking every request waiting on the shared refresh.
          if (isRefreshCall) {
            await _forceLogout();
            return handler.next(error);
          }

          // All concurrent 401s join the same in-flight refresh instead of
          // each racing/failing independently — otherwise only the first
          // request to 401 benefits and the rest get force-logged-out even
          // though the refresh succeeds moments later.
          final String newAccessToken;
          try {
            newAccessToken = await refreshAccessToken();
          } catch (_) {
            // Only a failed refresh means auth is genuinely revoked — tear the
            // session down and re-login.
            await _forceLogout();
            return handler.next(error);
          }

          // Refresh succeeded. A retry that still fails (persistent 401, a 403,
          // a transient) is NOT an auth-revocation signal — surface it to the
          // caller so the Cubit maps it to a normal failure state, but keep the
          // session intact.
          final retryOptions = error.requestOptions;
          retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';
          try {
            handler.resolve(await _dio.fetch(retryOptions));
          } on DioException catch (retryError) {
            handler.next(retryError);
          }
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: false,
          responseHeader: false,
          error: true,
          logPrint: (object) => debugPrint(object.toString()),
        ),
      );
    }
  }

  /// Refreshes the access token, sharing a single in-flight request across
  /// any 401s that arrive concurrently rather than firing one refresh call
  /// per request. Public so [RideSocketService] can join the same in-flight
  /// refresh instead of racing it with its own `/api/auth/refresh` call —
  /// the backend rotates refresh tokens on use, so two concurrent refreshes
  /// with the same (now-stale) token would leave the loser force-logged-out
  /// even though the winner already renewed the session.
  static Future<String> refreshAccessToken() {
    final inFlight = _refreshCompleter;
    if (inFlight != null) return inFlight.future;

    final completer = Completer<String>();
    _refreshCompleter = completer;

    Future(() async {
      final response = await _dio.post(
        AuthApiConstants.refresh,
        data: {'refreshToken': AuthSession.refreshToken},
        options: Options(
          headers: {'Authorization': null},
        ),
      );
      final tokens = AuthTokensModel.fromJson(
        response.data as Map<String, dynamic>,
      );
      await AuthSession.setTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      return tokens.accessToken;
    }).then(completer.complete).catchError((Object e, StackTrace s) {
      completer.completeError(e, s);
    }).whenComplete(() {
      _refreshCompleter = null;
    });

    return completer.future;
  }

  static Future<Response> get({
    required String path,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw await _handleDioError(e);
    }
  }

  static Future<Response> post({
    required String path,
    required dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw await _handleDioError(e);
    }
  }

  static Future<Response> put({
    required String path,
    required dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw await _handleDioError(e);
    }
  }

  static Future<Response> delete({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw await _handleDioError(e);
    }
  }

  static Future<Response> patch({
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw await _handleDioError(e);
    }
  }

  static Future<Response> postMultipart({
    required String path,
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    try {
      return await _dio.post(
        path,
        data: formData,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw await _handleDioError(e);
    }
  }

  static final _rng = Random.secure();

  /// RFC 4122 v4 UUID — no external package required.
  static String _uuid() {
    final b = List<int>.generate(16, (_) => _rng.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40;
    b[8] = (b[8] & 0x3f) | 0x80;
    String h(int n) => n.toRadixString(16).padLeft(2, '0');
    return '${b.sublist(0, 4).map(h).join()}'
        '-${b.sublist(4, 6).map(h).join()}'
        '-${b.sublist(6, 8).map(h).join()}'
        '-${b.sublist(8, 10).map(h).join()}'
        '-${b.sublist(10, 16).map(h).join()}';
  }

  static Future<String> _handleDioError(DioException e) async {
    final data = e.response?.data;
    final apiError = ApiErrorModel.tryParse(data);
    if (apiError != null && apiError.message.isNotEmpty) {
      // Auth-revocation logout is owned solely by the 401 onError interceptor
      // (which only tears down when the refresh itself fails). Do not log out
      // here — a persistent 401/403 after a healthy refresh is surfaced as a
      // normal error, not a reason to clear the session.
      return apiError.message;
    }
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        'Request timed out. Check your connection.',
      DioExceptionType.connectionError => 'No connection. Check your network.',
      _ => 'Something went wrong. Please try again.',
    };
  }
}
