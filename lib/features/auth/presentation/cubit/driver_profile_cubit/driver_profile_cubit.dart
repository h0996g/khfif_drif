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
    final error = Validators.name(value.trim());
    emit(state.copyWith(
      firstName: value,
      firstNameError: error,
      firstNameTouched: true,
      status: DriverRegistrationStatus.idle,
      errorMessage: '',
    ));
  }

  void firstNameFocusLost() {
    if (!state.firstNameTouched) return;
    emit(state.copyWith(
        firstNameError: Validators.name(state.firstName.trim())));
  }

  void lastNameChanged(String value) {
    final error = Validators.name(value.trim());
    emit(state.copyWith(
      lastName: value,
      lastNameError: error,
      lastNameTouched: true,
      status: DriverRegistrationStatus.idle,
      errorMessage: '',
    ));
  }

  void lastNameFocusLost() {
    if (!state.lastNameTouched) return;
    emit(state.copyWith(lastNameError: Validators.name(state.lastName.trim())));
  }

  void dateOfBirthSelected(DateTime date) {
    emit(state.copyWith(
      dateOfBirth: date,
      status: DriverRegistrationStatus.idle,
      errorMessage: '',
    ));
  }

  void genderChanged(Gender gender) {
    emit(state.copyWith(
      gender: gender,
      status: DriverRegistrationStatus.idle,
      errorMessage: '',
    ));
  }

  Future<void> submitStep1() async {
    if (!state.canProceedStep1) return;
    emit(state.copyWith(
      status: DriverRegistrationStatus.submitting,
      errorMessage: '',
    ));
    try {
      await _repository.saveDriverPersonalInfo(
        fullName: state.fullName,
        gender: state.gender!,
        dateOfBirth: state.dateOfBirth!,
      );
      emit(state.copyWith(
        status: DriverRegistrationStatus.idle,
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
      vehicleMake: value,
      vehicleMakeError: Validators.vehicleText(value, AppStrings.fieldCarMake),
      vehicleMakeTouched: true,
      status: DriverRegistrationStatus.idle,
      errorMessage: '',
    ));
  }

  void vehicleMakeFocusLost() {
    if (!state.vehicleMakeTouched) return;
    emit(state.copyWith(
      vehicleMakeError:
          Validators.vehicleText(state.vehicleMake, AppStrings.fieldCarMake),
    ));
  }

  void vehicleModelChanged(String value) {
    emit(state.copyWith(
      vehicleModel: value,
      vehicleModelError:
          Validators.vehicleText(value, AppStrings.fieldCarModel),
      vehicleModelTouched: true,
      status: DriverRegistrationStatus.idle,
      errorMessage: '',
    ));
  }

  void vehicleModelFocusLost() {
    if (!state.vehicleModelTouched) return;
    emit(state.copyWith(
      vehicleModelError:
          Validators.vehicleText(state.vehicleModel, AppStrings.fieldCarModel),
    ));
  }

  void vehicleYearChanged(int year) {
    emit(state.copyWith(vehicleYear: year));
  }

  void vehicleColorChanged(String value) {
    emit(state.copyWith(
      vehicleColor: value,
      vehicleColorError: Validators.vehicleText(value, AppStrings.fieldColor),
      vehicleColorTouched: true,
      status: DriverRegistrationStatus.idle,
      errorMessage: '',
    ));
  }

  void vehicleColorFocusLost() {
    if (!state.vehicleColorTouched) return;
    emit(state.copyWith(
      vehicleColorError:
          Validators.vehicleText(state.vehicleColor, AppStrings.fieldColor),
    ));
  }

  void plateNumberChanged(String value) {
    emit(state.copyWith(
      plateNumber: value,
      plateNumberError: Validators.plate(value),
      plateNumberTouched: true,
      status: DriverRegistrationStatus.idle,
      errorMessage: '',
    ));
  }

  void plateNumberFocusLost() {
    if (!state.plateNumberTouched) return;
    emit(state.copyWith(plateNumberError: Validators.plate(state.plateNumber)));
  }

  Future<void> pickVehiclePhoto() async {
    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (file != null) {
        emit(state.copyWith(vehiclePhotoPath: file.path));
      }
    } catch (_) {
      // User cancelled or permission denied — no state change needed
    }
  }

  void proceedStep2() {
    if (!state.canProceedStep2) return;
    emit(state.copyWith(
      currentStep: DriverStep.documents,
      status: DriverRegistrationStatus.idle,
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
        // User cancelled — revert to idle
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

      // Simulate upload latency
      await Future<void>.delayed(const Duration(milliseconds: 800));

      emit(_setDocument(
        type,
        DriverDocument(
          filePath: path,
          fileName: name,
          status: UploadStatus.uploaded,
        ),
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
      status: DriverRegistrationStatus.submitting,
      errorMessage: '',
    ));
    try {
      await _repository.submitDriverDocuments(
        nationalIdFrontPath: state.nationalIdFront.filePath!,
        nationalIdBackPath: state.nationalIdBack.filePath!,
        licenseFrontPath: state.licenseFront.filePath!,
        licenseBackPath: state.licenseBack.filePath!,
        vehicleRegistrationPath: state.vehicleRegistration.filePath!,
        vehiclePhotoPath: state.vehiclePhotoPath!,
        vehicleMake: state.vehicleMake.trim(),
        vehicleModel: state.vehicleModel.trim(),
        vehicleYear: state.vehicleYear!,
        vehicleColor: state.vehicleColor.trim(),
        plateNumber: state.plateNumber,
      );
      emit(state.copyWith(status: DriverRegistrationStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: DriverRegistrationStatus.failure,
        errorMessage: e is String ? e : 'Submission failed. Please try again.',
      ));
    }
  }

  // ── Back navigation ───────────────────────────────────────────────────────

  void goBackStep() {
    switch (state.currentStep) {
      case DriverStep.vehicleInfo:
        emit(state.copyWith(
          currentStep: DriverStep.personalInfo,
          status: DriverRegistrationStatus.idle,
          errorMessage: '',
        ));
      case DriverStep.documents:
        emit(state.copyWith(
          currentStep: DriverStep.vehicleInfo,
          status: DriverRegistrationStatus.idle,
          errorMessage: '',
        ));
      case DriverStep.personalInfo:
        // Handled by the view via context.pop()
        break;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  DriverProfileState _setDocument(DriverDocumentType type, DriverDocument doc) {
    return state.copyWith(
      nationalIdFront: type == DriverDocumentType.nationalIdFront ? doc : null,
      nationalIdBack: type == DriverDocumentType.nationalIdBack ? doc : null,
      licenseFront: type == DriverDocumentType.licenseFront ? doc : null,
      licenseBack: type == DriverDocumentType.licenseBack ? doc : null,
      vehicleRegistration:
          type == DriverDocumentType.vehicleRegistration ? doc : null,
    );
  }
}
