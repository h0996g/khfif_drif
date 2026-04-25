import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/router/route_names.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../../../shared/widgets/primary_button.dart';
import '../widgets/profile/passenger/profile_error_banner_widget.dart';
import '../widgets/profile/driver/profile_step_progress_bar_widget.dart';
import '../../cubit/driver_profile_cubit/driver_profile_cubit.dart';
import '../../cubit/driver_profile_cubit/driver_profile_state.dart';
import '../widgets/profile/driver/steps/driver_step1_personal_info.dart';
import '../widgets/profile/driver/steps/driver_step2_vehicle_info.dart';
import '../widgets/profile/driver/steps/driver_step3_documents.dart';

class DriverRegistrationView extends StatelessWidget {
  const DriverRegistrationView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverProfileCubit, DriverProfileState>(
      listenWhen: (prev, curr) =>
          curr.status == DriverRegistrationStatus.success,
      listener: (context, state) => context.go(RouteNames.driverPendingReview),
      builder: (context, state) {
        final cubit = context.read<DriverProfileCubit>();

        return AppScaffold(
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 32.h),
                ProfileStepProgressBarWidget(
                  currentStep: state.currentStep.index + 1,
                  totalSteps: 3,
                  stepLabels: const ['Personal', 'Vehicle', 'Documents'],
                  onStepTap: cubit.goToStep,
                ),
                SizedBox(height: 32.h),
                _StepHeader(step: state.currentStep),
                SizedBox(height: 40.h),
                Expanded(child: _StepContent(cubit: cubit, state: state)),
                _ErrorBanner(message: state.errorMessage),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
              child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: _ActionButton(cubit: cubit, state: state),
          )),
        );
      },
    );
  }
}

// ── Private components ────────────────────────────────────────────────────────

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.step});
  final DriverStep step;

  static const _titles = {
    DriverStep.personalInfo: AppStrings.driverStep1Title,
    DriverStep.vehicleInfo: AppStrings.driverStep2Title,
    DriverStep.documents: AppStrings.driverStep3Title,
  };

  static const _subtitles = {
    DriverStep.personalInfo: AppStrings.driverStep1Subtitle,
    DriverStep.vehicleInfo: AppStrings.driverStep2Subtitle,
    DriverStep.documents: AppStrings.driverStep3Subtitle,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_titles[step]!, style: AppTextStyles.displayMedium(context)),
        SizedBox(height: 8.h),
        Text(_subtitles[step]!, style: AppTextStyles.bodyMedium(context)),
      ],
    );
  }
}

class _StepContent extends StatelessWidget {
  const _StepContent({required this.cubit, required this.state});
  final DriverProfileCubit cubit;
  final DriverProfileState state;

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: state.currentStep.index,
      children: [
        DriverStep1PersonalInfo(cubit: cubit, state: state),
        DriverStep2VehicleInfo(cubit: cubit, state: state),
        DriverStep3Documents(cubit: cubit, state: state),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      child: message.isNotEmpty
          ? Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: ProfileErrorBannerWidget(message: message),
            )
          : const SizedBox.shrink(),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.cubit, required this.state});
  final DriverProfileCubit cubit;
  final DriverProfileState state;

  static const _labels = {
    DriverStep.personalInfo: 'Continue',
    DriverStep.vehicleInfo: 'Continue',
    DriverStep.documents: 'Submit Application',
  };

  VoidCallback get _action => switch (state.currentStep) {
        DriverStep.personalInfo => cubit.submitStep1,
        DriverStep.vehicleInfo => cubit.proceedStep2,
        DriverStep.documents => cubit.submitStep3,
      };

  bool get _enabled => switch (state.currentStep) {
        DriverStep.personalInfo => state.canProceedStep1,
        DriverStep.vehicleInfo => state.canProceedStep2,
        DriverStep.documents => state.canSubmitStep3,
      };

  bool get _loading =>
      state.status == DriverRegistrationStatus.loading &&
      state.currentStep != DriverStep.vehicleInfo;

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      label: _labels[state.currentStep]!,
      isEnabled: _enabled,
      isLoading: _loading,
      onPressed: _action,
    );
  }
}
