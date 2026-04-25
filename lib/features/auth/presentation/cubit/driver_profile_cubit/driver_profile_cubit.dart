import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/utils/validators.dart';
import '../../../data/models/gender.dart';
import '../../../data/repo/auth_repository.dart';
import '../../../data/models/driver_document.dart';
import 'driver_profile_state.dart';

final class DriverProfileCubit extends Cubit<DriverProfileState> {
  DriverProfileCubit(this._repository) : super(const DriverProfileState());

  final AuthRepository _repository;
  final _imagePicker = ImagePicker();

  // ── Step 1: Personal Info ─────────────────────────────────────────────────

  void firstNameChanged(String value) {
    emit(state.copyWith(
      status: DriverRegistrationStatus.initial,
      errorMessage: '',
      personalInfo: state.personalInfo.copyWith(
        firstName: value,
        firstNameError: Validators.name(value.trim()),
      ),
    ));
  }

  void lastNameChanged(String value) {
    emit(state.copyWith(
      status: DriverRegistrationStatus.initial,
      errorMessage: '',
      personalInfo: state.personalInfo.copyWith(
        lastName: value,
        lastNameError: Validators.name(value.trim()),
      ),
    ));
  }

  void dateOfBirthSelected(DateTime date) {
    emit(state.copyWith(
      status: DriverRegistrationStatus.initial,
      errorMessage: '',
      personalInfo: state.personalInfo.copyWith(dateOfBirth: date),
    ));
  }

  void genderChanged(Gender gender) {
    emit(state.copyWith(
      status: DriverRegistrationStatus.initial,
      errorMessage: '',
      personalInfo: state.personalInfo.copyWith(gender: gender),
    ));
  }

  Future<void> submitStep1() async {
    if (!state.canProceedStep1) return;
    emit(state.copyWith(
      status: DriverRegistrationStatus.loading,
      errorMessage: '',
    ));
    try {
      await _repository.saveDriverPersonalInfo(
        fullName: state.personalInfo.fullName,
        gender: state.personalInfo.gender!,
        dateOfBirth: state.personalInfo.dateOfBirth!,
      );
      emit(state.copyWith(
        status: DriverRegistrationStatus.initial,
        currentStep: DriverStep.vehicleInfo,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DriverRegistrationStatus.failure,
        errorMessage:
            e is String ? e : 'Something went wrong. Please try again.',
      ));
    }
  }

  // ── Step 2: Vehicle Info ──────────────────────────────────────────────────

  void vehicleMakeChanged(String value) {
    emit(state.copyWith(
      status: DriverRegistrationStatus.initial,
      errorMessage: '',
      vehicleInfo: state.vehicleInfo.copyWith(
        vehicleMake: value,
        vehicleMakeError: Validators.vehicleText(value, AppStrings.fieldCarMake),
      ),
    ));
  }

  void vehicleModelChanged(String value) {
    emit(state.copyWith(
      status: DriverRegistrationStatus.initial,
      errorMessage: '',
      vehicleInfo: state.vehicleInfo.copyWith(
        vehicleModel: value,
        vehicleModelError:
            Validators.vehicleText(value, AppStrings.fieldCarModel),
      ),
    ));
  }

  void vehicleYearChanged(int year) {
    emit(state.copyWith(
      vehicleInfo: state.vehicleInfo.copyWith(vehicleYear: year),
    ));
  }

  void vehicleColorChanged(String value) {
    emit(state.copyWith(
      status: DriverRegistrationStatus.initial,
      errorMessage: '',
      vehicleInfo: state.vehicleInfo.copyWith(
        vehicleColor: value,
        vehicleColorError: Validators.vehicleText(value, AppStrings.fieldColor),
      ),
    ));
  }

  void plateNumberChanged(String value) {
    emit(state.copyWith(
      status: DriverRegistrationStatus.initial,
      errorMessage: '',
      vehicleInfo: state.vehicleInfo.copyWith(
        plateNumber: value,
        plateNumberError: Validators.plate(value),
      ),
    ));
  }

  Future<void> pickVehiclePhoto() async {
    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file != null) {
        emit(state.copyWith(
          vehicleInfo: state.vehicleInfo.copyWith(vehiclePhotoPath: file.path),
        ));
      }
    } catch (_) {
      // User cancelled or permission denied — no state change needed
    }
  }

  void proceedStep2() {
    if (!state.canProceedStep2) return;
    emit(state.copyWith(
      currentStep: DriverStep.documents,
      status: DriverRegistrationStatus.initial,
      errorMessage: '',
    ));
  }

  // ── Step 3: Documents ─────────────────────────────────────────────────────

  Future<void> pickDocument(DriverDocumentType type) async {
    emit(_setDocument(
        type, const DriverDocument(status: UploadStatus.uploading)));

    try {
      String? path;
      String? name;

      if (type == DriverDocumentType.vehicleRegistration) {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        );
        if (result != null && result.files.isNotEmpty) {
          path = result.files.first.path;
          name = result.files.first.name;
        }
      } else {
        final file = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
        );
        path = file?.path;
        name = file?.name;
      }

      if (path == null) {
        emit(_setDocument(type, const DriverDocument()));
        return;
      }

      final fileSize = await File(path).length();
      if (fileSize > AppConstants.maxDocumentSizeBytes) {
        emit(_setDocument(
          type,
          const DriverDocument(
            status: UploadStatus.error,
            errorMessage: AppStrings.fileTooLarge,
          ),
        ));
        return;
      }

      await Future<void>.delayed(const Duration(milliseconds: 800));

      emit(_setDocument(
        type,
        DriverDocument(filePath: path, fileName: name, status: UploadStatus.uploaded),
      ));
    } catch (_) {
      emit(_setDocument(
        type,
        const DriverDocument(
          status: UploadStatus.error,
          errorMessage: 'Upload failed. Tap to retry.',
        ),
      ));
    }
  }

  Future<void> submitStep3() async {
    if (!state.canSubmitStep3) return;
    emit(state.copyWith(
      status: DriverRegistrationStatus.loading,
      errorMessage: '',
    ));
    try {
      final v = state.vehicleInfo;
      final d = state.documents;
      await _repository.submitDriverDocuments(
        nationalIdFrontPath: d.nationalIdFront.filePath!,
        nationalIdBackPath: d.nationalIdBack.filePath!,
        licenseFrontPath: d.licenseFront.filePath!,
        licenseBackPath: d.licenseBack.filePath!,
        vehicleRegistrationPath: d.vehicleRegistration.filePath!,
        vehiclePhotoPath: v.vehiclePhotoPath!,
        vehicleMake: v.vehicleMake.trim(),
        vehicleModel: v.vehicleModel.trim(),
        vehicleYear: v.vehicleYear!,
        vehicleColor: v.vehicleColor.trim(),
        plateNumber: v.plateNumber,
      );
      emit(state.copyWith(status: DriverRegistrationStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: DriverRegistrationStatus.failure,
        errorMessage: e is String ? e : 'Submission failed. Please try again.',
      ));
    }
  }

  // ── Step navigation ───────────────────────────────────────────────────────

  void goToStep(int oneBased) {
    final target = DriverStep.values[oneBased - 1];
    if (target == state.currentStep) return;
    emit(state.copyWith(
      currentStep: target,
      status: DriverRegistrationStatus.initial,
      errorMessage: '',
    ));
  }

  void goBackStep() {
    switch (state.currentStep) {
      case DriverStep.vehicleInfo:
        emit(state.copyWith(
          currentStep: DriverStep.personalInfo,
          status: DriverRegistrationStatus.initial,
          errorMessage: '',
        ));
      case DriverStep.documents:
        emit(state.copyWith(
          currentStep: DriverStep.vehicleInfo,
          status: DriverRegistrationStatus.initial,
          errorMessage: '',
        ));
      case DriverStep.personalInfo:
        break;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  DriverProfileState _setDocument(DriverDocumentType type, DriverDocument doc) {
    return state.copyWith(
      documents: state.documents.copyWith(
        nationalIdFront: type == DriverDocumentType.nationalIdFront ? doc : null,
        nationalIdBack: type == DriverDocumentType.nationalIdBack ? doc : null,
        licenseFront: type == DriverDocumentType.licenseFront ? doc : null,
        licenseBack: type == DriverDocumentType.licenseBack ? doc : null,
        vehicleRegistration:
            type == DriverDocumentType.vehicleRegistration ? doc : null,
      ),
    );
  }
}
