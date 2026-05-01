import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/utils/validators.dart';
import '../../../data/models/gender.dart';
import '../../../data/repo/auth_repository.dart';
import '../../../data/models/driver_document.dart';
import 'document_pick_result.dart';
import 'driver_document_picker_service.dart';
import 'driver_profile_state.dart';

final class DriverProfileCubit extends Cubit<DriverProfileState> {
  DriverProfileCubit(this._repository) : super(const DriverProfileState());

  final AuthRepository _repository;
  final _picker = DriverDocumentPickerService();

  // ── Step 1: Personal Info ─────────────────────────────────────────────────

  void firstNameChanged(String v) => _emitPersonal(state.personalInfo
      .copyWith(firstName: v, firstNameError: Validators.name(v.trim())));
  void lastNameChanged(String v) => _emitPersonal(state.personalInfo
      .copyWith(lastName: v, lastNameError: Validators.name(v.trim())));
  void dateOfBirthSelected(DateTime date) =>
      _emitPersonal(state.personalInfo.copyWith(dateOfBirth: date));
  void genderChanged(Gender gender) =>
      _emitPersonal(state.personalInfo.copyWith(gender: gender));

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

  void vehicleMakeChanged(String v) => _emitVehicle(state.vehicleInfo.copyWith(
      vehicleMake: v,
      vehicleMakeError: Validators.vehicleText(v, AppStrings.fieldCarMake)));
  void vehicleModelChanged(String v) => _emitVehicle(state.vehicleInfo.copyWith(
      vehicleModel: v,
      vehicleModelError: Validators.vehicleText(v, AppStrings.fieldCarModel)));
  void vehicleColorChanged(String v) => _emitVehicle(state.vehicleInfo.copyWith(
      vehicleColor: v,
      vehicleColorError: Validators.vehicleText(v, AppStrings.fieldColor)));
  void plateNumberChanged(String v) => _emitVehicle(state.vehicleInfo
      .copyWith(plateNumber: v, plateNumberError: Validators.plate(v)));
  void vehicleYearChanged(int year) =>
      _emitVehicle(state.vehicleInfo.copyWith(vehicleYear: year));

  Future<void> pickVehiclePhoto(ImageSource source) async {
    final path = await _picker.pickVehiclePhoto(source);
    if (path != null) {
      emit(state.copyWith(
        vehicleInfo: state.vehicleInfo.copyWith(vehiclePhotoPath: path),
      ));
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

  Future<void> pickDocument(DriverDocumentType type, ImageSource source) async {
    emit(_setDocument(
        type, const DriverDocument(status: UploadStatus.uploading)));

    final result = await _picker.pickDocument(type, source);

    switch (result) {
      case DocumentPickCancelled():
        emit(_setDocument(type, const DriverDocument()));
      case DocumentPickSuccess(:final path, :final name):
        emit(_setDocument(
          type,
          DriverDocument(
              filePath: path, fileName: name, status: UploadStatus.uploaded),
        ));
      case DocumentPickFailure(:final errorMessage):
        emit(_setDocument(
          type,
          DriverDocument(
              status: UploadStatus.error, errorMessage: errorMessage),
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
    if (target.index > state.currentStep.index) {
      if (target == DriverStep.vehicleInfo && !state.canProceedStep1) {
        return;
      }
      if (target == DriverStep.documents &&
          (!state.canProceedStep1 || !state.canProceedStep2)) {
        return;
      }
    }
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

  void _emitPersonal(DriverPersonalInfo info) => emit(state.copyWith(
        status: DriverRegistrationStatus.initial,
        errorMessage: '',
        personalInfo: info,
      ));

  void _emitVehicle(DriverVehicleInfo info) => emit(state.copyWith(
        status: DriverRegistrationStatus.initial,
        errorMessage: '',
        vehicleInfo: info,
      ));

  DriverProfileState _setDocument(DriverDocumentType type, DriverDocument doc) {
    return state.copyWith(
      documents: state.documents.copyWith(
        nationalIdFront:
            type == DriverDocumentType.nationalIdFront ? doc : null,
        nationalIdBack: type == DriverDocumentType.nationalIdBack ? doc : null,
        licenseFront: type == DriverDocumentType.licenseFront ? doc : null,
        licenseBack: type == DriverDocumentType.licenseBack ? doc : null,
        vehicleRegistration:
            type == DriverDocumentType.vehicleRegistration ? doc : null,
      ),
    );
  }
}
