import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/router/route_names.dart';
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
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 32.h),
                ProfileStepProgressBarWidget(
                  currentStep: state.currentStep.index + 1,
                  totalSteps: 3,
                  stepLabels: const ['Personal', 'Vehicle', 'Documents'],
                  completedSteps: {
                    if (state.canProceedStep1) 2,
                    if (state.canProceedStep2) 3,
                  },
                  onStepTap: cubit.goToStep,
                ),
                SizedBox(height: 20.h),
                const Expanded(
                  child: SingleChildScrollView(
                      physics: ClampingScrollPhysics(), child: _StepContent()),
                ),
                _ErrorBanner(message: state.errorMessage),
              ],
            ),
          ),
          bottomNavigationBar: _ActionButton(cubit: cubit, state: state),
        );
      },
    );
  }
}

// ── Private components ────────────────────────────────────────────────────────

class _StepContent extends StatelessWidget {
  const _StepContent();

  @override
  Widget build(BuildContext context) {
    final step = context.select<DriverProfileCubit, DriverStep>(
      (c) => c.state.currentStep,
    );
    return IndexedStack(
      index: step.index,
      children: const [
        DriverStep1PersonalInfo(),
        DriverStep2VehicleInfo(),
        DriverStep3Documents(),
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
