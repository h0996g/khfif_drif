import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  const DriverStep1PersonalInfo({super.key});

  @override
  State<DriverStep1PersonalInfo> createState() =>
      _DriverStep1PersonalInfoState();
}

class _DriverStep1PersonalInfoState extends State<DriverStep1PersonalInfo> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverProfileCubit, DriverProfileState>(
      buildWhen: (prev, curr) => prev.personalInfo != curr.personalInfo,
      builder: (context, state) {
        final cubit = context.read<DriverProfileCubit>();
        final info = state.personalInfo;
        final isSubmitting = state.status == DriverRegistrationStatus.loading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── First Name ─────────────────────────────────────────────────────
            const ProfileFieldLabelWidget(label: AppStrings.fieldFirstName),
            SizedBox(height: 8.h),
            ProfileNameFieldWidget(
              controller: _firstNameController,
              onChanged: cubit.firstNameChanged,
              error: info.firstNameError,
              enabled: !isSubmitting,
            ),

            SizedBox(height: 24.h),

            // ── Last Name ──────────────────────────────────────────────────────
            const ProfileFieldLabelWidget(label: AppStrings.fieldLastName),
            SizedBox(height: 8.h),
            ProfileNameFieldWidget(
              controller: _lastNameController,
              onChanged: cubit.lastNameChanged,
              error: info.lastNameError,
              enabled: !isSubmitting,
            ),

            SizedBox(height: 24.h),

            // ── Date of Birth ──────────────────────────────────────────────────
            const ProfileFieldLabelWidget(label: AppStrings.fieldDateOfBirth),
            SizedBox(height: 8.h),
            DriverDatePickerFieldWidget(
              selectedDate: info.dateOfBirth,
              onDateSelected: cubit.dateOfBirthSelected,
              enabled: !isSubmitting,
            ),

            SizedBox(height: 24.h),

            // ── Gender ─────────────────────────────────────────────────────────
            const ProfileFieldLabelWidget(label: AppStrings.fieldGender),
            SizedBox(height: 8.h),
            ProfileGenderToggleWidget(
              selected: info.gender,
              onChanged: (Gender g) => cubit.genderChanged(g),
              enabled: !isSubmitting,
            ),
          ],
        );
      },
    );
  }
}
