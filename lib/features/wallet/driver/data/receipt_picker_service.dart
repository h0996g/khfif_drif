import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import 'wallet_repository.dart';

/// Where the driver takes the top-up receipt from.
enum ReceiptSource { camera, gallery, file }

/// Outcome of a receipt pick. [ReceiptPickCancelled] is the user backing out —
/// never an error to surface.
sealed class ReceiptPickResult {
  const ReceiptPickResult();
}

final class ReceiptPickSuccess extends ReceiptPickResult {
  const ReceiptPickSuccess({required this.path, required this.name});

  final String path;
  final String name;
}

final class ReceiptPickCancelled extends ReceiptPickResult {
  const ReceiptPickCancelled();
}

final class ReceiptPickFailure extends ReceiptPickResult {
  const ReceiptPickFailure(this.message);

  final String message;
}

/// Picks the receipt that must accompany every top-up.
///
/// Unlike the KYC document picker this also accepts a **PDF** (bank-transfer
/// slips usually are one), so the file branch goes through `file_picker` while
/// camera/gallery stay on `image_picker`. Both the extension and the 5 MB cap
/// are validated here so the driver gets an instant answer instead of a
/// `TOPUP_RECEIPT_REQUIRED` round trip.
final class ReceiptPickerService {
  ReceiptPickerService() : _imagePicker = ImagePicker();

  ReceiptPickerService.withPicker(this._imagePicker);

  final ImagePicker _imagePicker;

  Future<ReceiptPickResult> pick(ReceiptSource source) async {
    try {
      final picked = source == ReceiptSource.file
          ? await _pickFile()
          : await _pickImage(source);
      if (picked == null) return const ReceiptPickCancelled();

      if (!TopUpReceiptRules.isAllowed(picked.path)) {
        return const ReceiptPickFailure(
            'Receipt must be a JPG, PNG or PDF file.');
      }
      if (!await TopUpReceiptRules.isWithinSizeLimit(picked.path)) {
        return const ReceiptPickFailure('Receipt must be 5 MB or smaller.');
      }
      return ReceiptPickSuccess(path: picked.path, name: picked.name);
    } catch (_) {
      return const ReceiptPickFailure('Could not read that file. Try again.');
    }
  }

  Future<({String path, String name})?> _pickImage(ReceiptSource source) async {
    final file = await _imagePicker.pickImage(
      source: source == ReceiptSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      imageQuality: 85,
    );
    return file == null ? null : (path: file.path, name: file.name);
  }

  Future<({String path, String name})?> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: TopUpReceiptRules.allowedExtensions,
    );
    final file = result?.files.singleOrNull;
    final path = file?.path;
    return path == null ? null : (path: path, name: file!.name);
  }
}
