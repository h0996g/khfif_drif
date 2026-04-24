import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../cubit/passenger_profile_cubit/passenger_profile_cubit.dart';
import '../../../cubit/passenger_profile_cubit/passenger_profile_state.dart';
import 'profile_email_field_widget.dart';
import 'profile_error_banner_widget.dart';
import 'profile_field_label_widget.dart';
import 'profile_gender_toggle_widget.dart';
import 'profile_name_field_widget.dart';

class PassengerProfileFormSection extends StatelessWidget {
  const PassengerProfileFormSection({
    super.key,
    required this.nameController,
    required this.emailController,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PassengerProfileCubit>();

    return BlocBuilder<PassengerProfileCubit, PassengerProfileState>(
      buildWhen: (previous, current) =>
          previous.gender != current.gender ||
          previous.nameError != current.nameError ||
          previous.emailError != current.emailError ||
          previous.errorMessage != current.errorMessage ||
          previous.status != current.status,
      builder: (context, state) {
        final isSubmitting = state.status == ProfileStatus.loading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ProfileFieldLabelWidget(label: 'Full Name'),
            SizedBox(height: 8.h),
            ProfileNameFieldWidget(
              controller: nameController,
              onChanged: cubit.nameChanged,
              error: state.nameError,
              enabled: !isSubmitting,
            ),
            SizedBox(height: 24.h),
            const ProfileFieldLabelWidget(label: 'Gender'),
            SizedBox(height: 8.h),
            ProfileGenderToggleWidget(
              selected: state.gender,
              onChanged: cubit.genderChanged,
              enabled: !isSubmitting,
            ),
            SizedBox(height: 24.h),
            const ProfileFieldLabelWidget(
              label: 'Email',
              badge: 'Optional',
            ),
            SizedBox(height: 8.h),
            ProfileEmailFieldWidget(
              controller: emailController,
              onChanged: cubit.emailChanged,
              error: state.emailError,
              enabled: !isSubmitting,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              child: state.errorMessage.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.only(top: 16.h),
                      child: ProfileErrorBannerWidget(
                        message: state.errorMessage,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }
}
