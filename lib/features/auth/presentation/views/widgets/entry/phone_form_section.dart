// lib/features/auth/presentation/views/widgets/entry/phone_form_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../shared/widgets/primary_button.dart';
import '../../../cubit/phone_cubit/phone_cubit.dart';
import '../../../cubit/phone_cubit/phone_state.dart';
import 'phone_input_field.dart';

class PhoneFormSection extends StatefulWidget {
  const PhoneFormSection({super.key});

  @override
  State<PhoneFormSection> createState() => _PhoneFormSectionState();
}

class _PhoneFormSectionState extends State<PhoneFormSection> {
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PhoneInputField(
          controller: _phoneController,
          onChanged: context.read<PhoneCubit>().phoneChanged,
        ),
        SizedBox(height: 24.h),
        BlocBuilder<PhoneCubit, PhoneState>(
          builder: (context, state) {
            return PrimaryButton(
              label: 'Continue',
              isEnabled: state.isValid,
              isLoading: state.status == PhoneStatus.loading,
              onPressed: context.read<PhoneCubit>().sendOtp,
            );
          },
        ),
      ],
    );
  }
}
