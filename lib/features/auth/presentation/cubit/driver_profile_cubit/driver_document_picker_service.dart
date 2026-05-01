import 'dart:io';

import 'package:image_picker/image_picker.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../data/models/driver_document.dart';
import 'document_pick_result.dart';

final class DriverDocumentPickerService {
  DriverDocumentPickerService() : _imagePicker = ImagePicker();

  DriverDocumentPickerService.withPicker(this._imagePicker);

  final ImagePicker _imagePicker;

  Future<String?> pickVehiclePhoto(ImageSource source) async {
    try {
      final file = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );
      return file?.path;
    } catch (_) {
      return null;
    }
  }

  Future<DocumentPickResult> pickDocument(
      DriverDocumentType type, ImageSource source) async {
    try {
      final file = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (file == null) return const DocumentPickCancelled();

      final fileSize = await File(file.path).length();
      if (fileSize > AppConstants.maxDocumentSizeBytes) {
        return const DocumentPickFailure(errorMessage: AppStrings.fileTooLarge);
      }

      await Future<void>.delayed(const Duration(milliseconds: 800));

      return DocumentPickSuccess(path: file.path, name: file.name);
    } catch (_) {
      return const DocumentPickFailure(
          errorMessage: 'Upload failed. Tap to retry.');
    }
  }
}
