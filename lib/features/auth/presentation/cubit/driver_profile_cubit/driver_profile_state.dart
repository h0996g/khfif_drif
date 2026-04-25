// lib/features/driver/presentation/cubit/driver_registration_cubit/driver_registration_state.dart

import '../../../data/models/gender.dart';
import '../../../data/models/driver_document.dart';

enum DriverRegistrationStatus { idle, submitting, success, failure }

enum DriverStep { personalInfo, vehicleInfo, documents }

final class DriverProfileState {
  const DriverProfileState({
    // ── Step tracking ────────────────────────────────────────────────────────
    this.currentStep = DriverStep.personalInfo,
    this.status = DriverRegistrationStatus.idle,
    this.errorMessage = '',

    // ── Step 1: Personal Info ────────────────────────────────────────────────
    this.firstName = '',
    this.lastName = '',
    this.dateOfBirth,
    this.gender,
    this.firstNameError = '',
    this.lastNameError = '',
    this.firstNameTouched = false,
    this.lastNameTouched = false,

    // ── Step 2: Vehicle Info ─────────────────────────────────────────────────
    this.vehicleMake = '',
    this.vehicleModel = '',
    this.vehicleYear,
    this.vehicleColor = '',
    this.plateNumber = '',
    this.vehiclePhotoPath,
    this.vehicleMakeError = '',
    this.vehicleModelError = '',
    this.vehicleColorError = '',
    this.plateNumberError = '',
    this.vehicleMakeTouched = false,
    this.vehicleModelTouched = false,
    this.vehicleColorTouched = false,
    this.plateNumberTouched = false,

    // ── Step 3: Documents ────────────────────────────────────────────────────
    this.nationalIdFront = const DriverDocument(),
    this.nationalIdBack = const DriverDocument(),
    this.licenseFront = const DriverDocument(),
    this.licenseBack = const DriverDocument(),
    this.vehicleRegistration = const DriverDocument(),
  });

  final DriverStep currentStep;
  final DriverRegistrationStatus status;
  final String errorMessage;

  final String firstName;
  final String lastName;
  final DateTime? dateOfBirth;
  final Gender? gender;
  final String firstNameError;
  final String lastNameError;
  final bool firstNameTouched;
  final bool lastNameTouched;

  final String vehicleMake;
  final String vehicleModel;
  final int? vehicleYear;
  final String vehicleColor;
  final String plateNumber;
  final String? vehiclePhotoPath;
  final String vehicleMakeError;
  final String vehicleModelError;
  final String vehicleColorError;
  final String plateNumberError;
  final bool vehicleMakeTouched;
  final bool vehicleModelTouched;
  final bool vehicleColorTouched;
  final bool plateNumberTouched;

  final DriverDocument nationalIdFront;
  final DriverDocument nationalIdBack;
  final DriverDocument licenseFront;
  final DriverDocument licenseBack;
  final DriverDocument vehicleRegistration;

  // ── Step 1 derived ────────────────────────────────────────────────────────

  String get fullName => '${firstName.trim()} ${lastName.trim()}'.trim();

  bool get isFirstNameValid =>
      firstNameError.isEmpty && firstName.trim().length >= 2;
  bool get isLastNameValid =>
      lastNameError.isEmpty && lastName.trim().length >= 2;
  bool get isDobSelected => dateOfBirth != null;
  bool get isGenderSelected => gender != null;

  bool get canProceedStep1 =>
      isFirstNameValid &&
      isLastNameValid &&
      isDobSelected &&
      isGenderSelected &&
      status != DriverRegistrationStatus.submitting;

  // ── Step 2 derived ────────────────────────────────────────────────────────

  bool get isVehicleMakeValid =>
      vehicleMakeError.isEmpty && vehicleMake.trim().length >= 2;
  bool get isVehicleModelValid =>
      vehicleModelError.isEmpty && vehicleModel.trim().length >= 2;
  bool get isVehicleYearSelected => vehicleYear != null;
  bool get isVehicleColorValid =>
      vehicleColorError.isEmpty && vehicleColor.trim().length >= 2;
  bool get isPlateNumberValid =>
      plateNumberError.isEmpty && plateNumber.isNotEmpty;
  bool get isVehiclePhotoUploaded => vehiclePhotoPath != null;

  bool get canProceedStep2 =>
      isVehicleMakeValid &&
      isVehicleModelValid &&
      isVehicleYearSelected &&
      isVehicleColorValid &&
      isPlateNumberValid &&
      isVehiclePhotoUploaded &&
      status != DriverRegistrationStatus.submitting;

  // ── Step 3 derived ────────────────────────────────────────────────────────

  bool get allDocumentsUploaded =>
      nationalIdFront.isUploaded &&
      nationalIdBack.isUploaded &&
      licenseFront.isUploaded &&
      licenseBack.isUploaded &&
      vehicleRegistration.isUploaded;

  bool get canSubmitStep3 =>
      allDocumentsUploaded && status != DriverRegistrationStatus.submitting;

  // ── copyWith ──────────────────────────────────────────────────────────────

  DriverProfileState copyWith({
    DriverStep? currentStep,
    DriverRegistrationStatus? status,
    String? errorMessage,
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    Gender? gender,
    String? firstNameError,
    String? lastNameError,
    bool? firstNameTouched,
    bool? lastNameTouched,
    String? vehicleMake,
    String? vehicleModel,
    int? vehicleYear,
    String? vehicleColor,
    String? plateNumber,
    String? vehiclePhotoPath,
    String? vehicleMakeError,
    String? vehicleModelError,
    String? vehicleColorError,
    String? plateNumberError,
    bool? vehicleMakeTouched,
    bool? vehicleModelTouched,
    bool? vehicleColorTouched,
    bool? plateNumberTouched,
    DriverDocument? nationalIdFront,
    DriverDocument? nationalIdBack,
    DriverDocument? licenseFront,
    DriverDocument? licenseBack,
    DriverDocument? vehicleRegistration,
  }) {
    return DriverProfileState(
      currentStep: currentStep ?? this.currentStep,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      firstNameError: firstNameError ?? this.firstNameError,
      lastNameError: lastNameError ?? this.lastNameError,
      firstNameTouched: firstNameTouched ?? this.firstNameTouched,
      lastNameTouched: lastNameTouched ?? this.lastNameTouched,
      vehicleMake: vehicleMake ?? this.vehicleMake,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleYear: vehicleYear ?? this.vehicleYear,
      vehicleColor: vehicleColor ?? this.vehicleColor,
      plateNumber: plateNumber ?? this.plateNumber,
      vehiclePhotoPath: vehiclePhotoPath ?? this.vehiclePhotoPath,
      vehicleMakeError: vehicleMakeError ?? this.vehicleMakeError,
      vehicleModelError: vehicleModelError ?? this.vehicleModelError,
      vehicleColorError: vehicleColorError ?? this.vehicleColorError,
      plateNumberError: plateNumberError ?? this.plateNumberError,
      vehicleMakeTouched: vehicleMakeTouched ?? this.vehicleMakeTouched,
      vehicleModelTouched: vehicleModelTouched ?? this.vehicleModelTouched,
      vehicleColorTouched: vehicleColorTouched ?? this.vehicleColorTouched,
      plateNumberTouched: plateNumberTouched ?? this.plateNumberTouched,
      nationalIdFront: nationalIdFront ?? this.nationalIdFront,
      nationalIdBack: nationalIdBack ?? this.nationalIdBack,
      licenseFront: licenseFront ?? this.licenseFront,
      licenseBack: licenseBack ?? this.licenseBack,
      vehicleRegistration: vehicleRegistration ?? this.vehicleRegistration,
    );
  }
}
