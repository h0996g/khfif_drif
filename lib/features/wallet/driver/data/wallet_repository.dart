import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as p;

import '../../../../core/constants/wallet_api_constants.dart';
import '../../../../core/models/page_response.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/image_compressor.dart';
import 'models/wallet_models.dart';

final class WalletRepository {
  const WalletRepository();

  Future<WalletBalance> getBalance() async {
    final response = await DioClient.get(path: WalletApiConstants.balance);
    return WalletBalance.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PageResponse<WalletTransaction>> getTransactions({
    int page = 0,
    int size = 20,
  }) async {
    final response = await DioClient.get(
      path: WalletApiConstants.transactions,
      queryParameters: {'page': page, 'size': size},
    );
    return PageResponse.fromJson(
      response.data as Map<String, dynamic>,
      WalletTransaction.fromJson,
    );
  }

  Future<PageResponse<TopUp>> getTopUps({
    TopUpStatus? status,
    int page = 0,
    int size = 20,
  }) async {
    final response = await DioClient.get(
      path: WalletApiConstants.topUps,
      queryParameters: {
        'page': page,
        'size': size,
        if (status != null) 'status': status.wireName,
      },
    );
    return PageResponse.fromJson(
      response.data as Map<String, dynamic>,
      TopUp.fromJson,
    );
  }

  /// The driver's single in-flight request, or `null`. The server allows only
  /// one `PENDING` top-up at a time, so the first row of the filtered page is
  /// the whole answer.
  Future<TopUp?> getPendingTopUp() async {
    final page = await getTopUps(status: TopUpStatus.pending, size: 1);
    return page.data.isEmpty ? null : page.data.first;
  }

  /// `multipart/form-data`, not JSON — the receipt file is mandatory.
  ///
  /// Images are compressed first; a PDF is uploaded untouched. The content type
  /// is set explicitly from the extension so the server's mime check accepts
  /// PDFs (Dio would otherwise default them to `application/octet-stream`).
  Future<TopUp> submitTopUp({
    required int amountDzd,
    required TopUpChannel channel,
    required String receiptPath,
  }) async {
    final uploadPath =
        _isPdf(receiptPath) ? receiptPath : await ImageCompressor.compress(receiptPath);

    final formData = FormData()
      ..fields.addAll([
        MapEntry('amountDzd', amountDzd.toString()),
        MapEntry('channel', channel.wireName),
      ])
      ..files.add(MapEntry(
        'receipt',
        await MultipartFile.fromFile(
          uploadPath,
          filename: p.basename(uploadPath),
          contentType: _contentTypeFor(uploadPath),
        ),
      ));

    final response = await DioClient.postMultipart(
      path: WalletApiConstants.topUps,
      formData: formData,
    );
    return TopUp.fromJson(response.data as Map<String, dynamic>);
  }

  /// Only valid while the request is `PENDING`; returns `204` with no body.
  Future<void> cancelTopUp(String id) async {
    await DioClient.post(
      path: WalletApiConstants.cancelTopUp(id),
      data: <String, dynamic>{},
    );
  }

  static bool _isPdf(String path) => p.extension(path).toLowerCase() == '.pdf';

  static MediaType _contentTypeFor(String path) =>
      switch (p.extension(path).toLowerCase()) {
        '.pdf' => MediaType('application', 'pdf'),
        '.png' => MediaType('image', 'png'),
        _ => MediaType('image', 'jpeg'),
      };
}

/// Guard rails the server enforces too, checked client-side so the driver gets
/// an instant answer instead of a round trip.
abstract final class TopUpReceiptRules {
  TopUpReceiptRules._();

  static const int maxSizeBytes = 5 * 1024 * 1024;
  static const List<String> allowedExtensions = ['jpg', 'jpeg', 'png', 'pdf'];

  static bool isAllowed(String path) => allowedExtensions
      .contains(p.extension(path).toLowerCase().replaceFirst('.', ''));

  static Future<bool> isWithinSizeLimit(String path) async =>
      await File(path).length() <= maxSizeBytes;
}
