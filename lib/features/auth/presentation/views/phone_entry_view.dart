// lib/features/auth/presentation/views/phone_entry_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_logo_widget.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../cubit/phone_cubit/phone_cubit.dart';
import '../cubit/phone_cubit/phone_state.dart';
import 'widgets/entry/phone_input_field.dart';

/// The first screen users see — they enter their Algerian mobile number here.
class PhoneEntryView extends StatefulWidget {
  const PhoneEntryView({super.key});

  @override
  State<PhoneEntryView> createState() => _PhoneEntryViewState();
}

class _PhoneEntryViewState extends State<PhoneEntryView> {
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PhoneCubit, PhoneState>(
      listener: (BuildContext context, PhoneState state) {
        switch (state.status) {
          case PhoneStatus.success:
            context.go(RouteNames.otp, extra: state.phoneNumber);
          case PhoneStatus.failure:
          case PhoneStatus.initial:
          case PhoneStatus.loading:
            break;
        }
      },
      builder: (BuildContext context, PhoneState state) {
        final phoneCubit = context.read<PhoneCubit>();

        final bool isLoading = state.status == PhoneStatus.loading;
        final bool hasError = state.status == PhoneStatus.failure &&
            state.errorMessage.isNotEmpty;

        return AppScaffold(
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.translucent,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 80.h),
                  const AppLogoWidget(),
                  SizedBox(height: 48.h),
                  Text(
                    'Enter your phone number',
                    style: AppTextStyles.displayMedium(context),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "We'll send you a verification code",
                    style: AppTextStyles.bodyMedium(context),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32.h),
                  PhoneInputField(
                    controller: _phoneController,
                    onChanged: phoneCubit.phoneChanged,
                    errorMessage: hasError ? state.errorMessage : null,
                  ),
                  SizedBox(height: 24.h),
                  PrimaryButton(
                    label: 'Continue',
                    isEnabled: state.isValid,
                    isLoading: isLoading,
                    onPressed: phoneCubit.sendOtp,
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'By continuing you agree to our Terms & Privacy',
                    style: AppTextStyles.labelSmall(context),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
