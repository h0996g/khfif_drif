// lib/core/network/api_client.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../constants/api_constants.dart';

/// Factory that builds and configures a [Dio] instance for the app.
final class ApiClient {
  ApiClient._();

  static Dio create() {
    final options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout:
          const Duration(milliseconds: ApiConstants.connectTimeoutMs),
      receiveTimeout:
          const Duration(milliseconds: ApiConstants.receiveTimeoutMs),
      headers: {
        Headers.contentTypeHeader: Headers.jsonContentType,
        Headers.acceptHeader: Headers.jsonContentType,
      },
    );

    final dio = Dio(options);

    if (kDebugMode) {
      dio.interceptors.add(
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

    return dio;
  }
}
