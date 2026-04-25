// lib/features/driver/presentation/views/widgets/steps/driver_step1_personal_info.dart

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

class DriverStep1PersonalInfo extends StatelessWidget {
  const DriverStep1PersonalInfo({
    super.key,
    required this.cubit,
    required this.state,
    required this.firstNameController,
    required this.lastNameController,
    required this.firstNameFocus,
    required this.lastNameFocus,
    required this.noopFocus,
  });

  final DriverProfileCubit cubit;
  final DriverProfileState state;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final FocusNode firstNameFocus;
  final FocusNode lastNameFocus;
  final FocusNode noopFocus;

  @override
  Widget build(BuildContext context) {
    final isSubmitting = state.status == DriverRegistrationStatus.submitting;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── First Name ─────────────────────────────────────────────────────
        const ProfileFieldLabelWidget(label: AppStrings.fieldFirstName),
        SizedBox(height: 8.h),
        ProfileNameFieldWidget(
          controller: firstNameController,
          onChanged: cubit.firstNameChanged,
          error: state.firstNameTouched ? state.firstNameError : '',
          enabled: !isSubmitting,
        ),

        SizedBox(height: 24.h),

        // ── Last Name ──────────────────────────────────────────────────────
        const ProfileFieldLabelWidget(label: AppStrings.fieldLastName),
        SizedBox(height: 8.h),
        ProfileNameFieldWidget(
          controller: lastNameController,
          onChanged: cubit.lastNameChanged,
          error: state.lastNameTouched ? state.lastNameError : '',
          enabled: !isSubmitting,
        ),

        SizedBox(height: 24.h),

        // ── Date of Birth ──────────────────────────────────────────────────
        const ProfileFieldLabelWidget(label: AppStrings.fieldDateOfBirth),
        SizedBox(height: 8.h),
        DriverDatePickerFieldWidget(
          selectedDate: state.dateOfBirth,
          onDateSelected: cubit.dateOfBirthSelected,
          enabled: !isSubmitting,
        ),

        SizedBox(height: 24.h),

        // ── Gender ─────────────────────────────────────────────────────────
        const ProfileFieldLabelWidget(label: AppStrings.fieldGender),
        SizedBox(height: 8.h),
        ProfileGenderToggleWidget(
          selected: state.gender,
          onChanged: (Gender g) => cubit.genderChanged(g),
          enabled: !isSubmitting,
        ),
      ],
    );
  }
}
