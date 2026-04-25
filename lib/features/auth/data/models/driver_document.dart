// lib/features/driver/data/models/driver_document.dart

enum UploadStatus { idle, uploading, uploaded, error }

enum DriverDocumentType {
  nationalIdFront,
  nationalIdBack,
  licenseFront,
  licenseBack,
  vehicleRegistration,
}

final class DriverDocument {
  const DriverDocument({
    this.filePath,
    this.fileName,
    this.status = UploadStatus.idle,
    this.errorMessage = '',
  });

  final String? filePath;
  final String? fileName;
  final UploadStatus status;
  final String errorMessage;

  bool get isUploaded => status == UploadStatus.uploaded;

  DriverDocument copyWith({
    String? filePath,
    String? fileName,
    UploadStatus? status,
    String? errorMessage,
  }) {
    return DriverDocument(
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
