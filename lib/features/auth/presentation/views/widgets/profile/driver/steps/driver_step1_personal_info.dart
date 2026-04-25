import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../../core/constants/app_strings.dart';
import '../../../../../../data/models/gender.dart';
import '../../profile_field_label_widget.dart';
import '../../profile_gender_toggle_widget.dart';
import '../../profile_name_field_widget.dart';
import '../../../../../cubit/driver_profile_cubit/driver_profile_cubit.dart';
import '../../../../../cubit/driver_profile_cubit/driver_profile_state.dart';
import '../fields/driver_date_picker_field_widget.dart';

class DriverStep1PersonalInfo extends StatefulWidget {
  const DriverStep1PersonalInfo({
    super.key,
    required this.cubit,
    required this.state,
  });

  final DriverProfileCubit cubit;
  final DriverProfileState state;

  @override
  State<DriverStep1PersonalInfo> createState() =>
      _DriverStep1PersonalInfoState();
}

class _DriverStep1PersonalInfoState extends State<DriverStep1PersonalInfo> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.state.personalInfo;
    final isSubmitting =
        widget.state.status == DriverRegistrationStatus.loading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── First Name ─────────────────────────────────────────────────────
        const ProfileFieldLabelWidget(label: AppStrings.fieldFirstName),
        SizedBox(height: 8.h),
        ProfileNameFieldWidget(
          controller: _firstNameController,
          onChanged: widget.cubit.firstNameChanged,
          error: info.firstNameError,
          enabled: !isSubmitting,
        ),

        SizedBox(height: 24.h),

        // ── Last Name ──────────────────────────────────────────────────────
        const ProfileFieldLabelWidget(label: AppStrings.fieldLastName),
        SizedBox(height: 8.h),
        ProfileNameFieldWidget(
          controller: _lastNameController,
          onChanged: widget.cubit.lastNameChanged,
          error: info.lastNameError,
          enabled: !isSubmitting,
        ),

        SizedBox(height: 24.h),

        // ── Date of Birth ──────────────────────────────────────────────────
        const ProfileFieldLabelWidget(label: AppStrings.fieldDateOfBirth),
        SizedBox(height: 8.h),
        DriverDatePickerFieldWidget(
          selectedDate: info.dateOfBirth,
          onDateSelected: widget.cubit.dateOfBirthSelected,
          enabled: !isSubmitting,
        ),

        SizedBox(height: 24.h),

        // ── Gender ─────────────────────────────────────────────────────────
        const ProfileFieldLabelWidget(label: AppStrings.fieldGender),
        SizedBox(height: 8.h),
        ProfileGenderToggleWidget(
          selected: info.gender,
          onChanged: (Gender g) => widget.cubit.genderChanged(g),
          enabled: !isSubmitting,
        ),
      ],
    );
  }
}
