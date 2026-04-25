// lib/features/driver/presentation/views/driver_registration_view.dart

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

/// Multi-step driver registration shell.
///
/// Manages all TextEditingControllers and FocusNodes across all 3 steps so
/// they survive step transitions (IndexedStack keeps children alive).
class DriverRegistrationView extends StatefulWidget {
  const DriverRegistrationView({super.key});

  @override
  State<DriverRegistrationView> createState() => _DriverRegistrationViewState();
}

class _DriverRegistrationViewState extends State<DriverRegistrationView> {
  // ── Step 1 controllers ────────────────────────────────────────────────────
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _noopFocus = FocusNode();

  // ── Step 2 controllers ────────────────────────────────────────────────────
  late final TextEditingController _makeController;
  late final TextEditingController _modelController;
  late final TextEditingController _colorController;
  late final TextEditingController _plateController;
  final FocusNode _makeFocus = FocusNode();
  final FocusNode _modelFocus = FocusNode();
  final FocusNode _colorFocus = FocusNode();
  final FocusNode _plateFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _makeController = TextEditingController();
    _modelController = TextEditingController();
    _colorController = TextEditingController();
    _plateController = TextEditingController();

    _firstNameFocus.addListener(() {
      if (!_firstNameFocus.hasFocus) {
        context.read<DriverProfileCubit>().firstNameFocusLost();
      }
    });
    _lastNameFocus.addListener(() {
      if (!_lastNameFocus.hasFocus) {
        context.read<DriverProfileCubit>().lastNameFocusLost();
      }
    });
    _makeFocus.addListener(() {
      if (!_makeFocus.hasFocus) {
        context.read<DriverProfileCubit>().vehicleMakeFocusLost();
      }
    });
    _modelFocus.addListener(() {
      if (!_modelFocus.hasFocus) {
        context.read<DriverProfileCubit>().vehicleModelFocusLost();
      }
    });
    _colorFocus.addListener(() {
      if (!_colorFocus.hasFocus) {
        context.read<DriverProfileCubit>().vehicleColorFocusLost();
      }
    });
    _plateFocus.addListener(() {
      if (!_plateFocus.hasFocus) {
        context.read<DriverProfileCubit>().plateNumberFocusLost();
      }
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    _plateController.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _makeFocus.dispose();
    _modelFocus.dispose();
    _colorFocus.dispose();
    _plateFocus.dispose();
    _noopFocus.dispose();
    super.dispose();
  }

  int _stepIndex(DriverStep step) {
    switch (step) {
      case DriverStep.personalInfo:
        return 0;
      case DriverStep.vehicleInfo:
        return 1;
      case DriverStep.documents:
        return 2;
    }
  }

  String _stepTitle(DriverStep step) {
    switch (step) {
      case DriverStep.personalInfo:
        return AppStrings.driverStep1Title;
      case DriverStep.vehicleInfo:
        return AppStrings.driverStep2Title;
      case DriverStep.documents:
        return AppStrings.driverStep3Title;
    }
  }

  String _stepSubtitle(DriverStep step) {
    switch (step) {
      case DriverStep.personalInfo:
        return AppStrings.driverStep1Subtitle;
      case DriverStep.vehicleInfo:
        return AppStrings.driverStep2Subtitle;
      case DriverStep.documents:
        return AppStrings.driverStep3Subtitle;
    }
  }

  String _buttonLabel(DriverStep step) {
    switch (step) {
      case DriverStep.personalInfo:
      case DriverStep.vehicleInfo:
        return 'Continue';
      case DriverStep.documents:
        return 'Submit Application';
    }
  }

  VoidCallback _buttonAction(DriverProfileCubit cubit, DriverStep step) {
    switch (step) {
      case DriverStep.personalInfo:
        return cubit.submitStep1;
      case DriverStep.vehicleInfo:
        return cubit.proceedStep2;
      case DriverStep.documents:
        return cubit.submitStep3;
    }
  }

  bool _buttonEnabled(DriverProfileState state) {
    switch (state.currentStep) {
      case DriverStep.personalInfo:
        return state.canProceedStep1;
      case DriverStep.vehicleInfo:
        return state.canProceedStep2;
      case DriverStep.documents:
        return state.canSubmitStep3;
    }
  }

  bool _buttonLoading(DriverProfileState state) {
    return state.status == DriverRegistrationStatus.submitting &&
        state.currentStep != DriverStep.vehicleInfo;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverProfileCubit, DriverProfileState>(
      listener: (context, state) {
        if (state.status == DriverRegistrationStatus.success) {
          context.go(RouteNames.driverPendingReview);
        }
      },
      builder: (context, state) {
        final cubit = context.read<DriverProfileCubit>();
        final stepIndex = _stepIndex(state.currentStep);

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (state.currentStep == DriverStep.personalInfo) {
              context.pop();
            } else {
              cubit.goBackStep();
            }
          },
          child: AppScaffold(
            body: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              behavior: HitTestBehavior.translucent,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: 32.h),

                          // ── Progress bar ─────────────────────────────────
                          ProfileStepProgressBarWidget(
                            currentStep: stepIndex + 1,
                            totalSteps: 3,
                          ),

                          SizedBox(height: 32.h),

                          // ── Step header ──────────────────────────────────
                          Text(
                            _stepTitle(state.currentStep),
                            style: AppTextStyles.displayMedium(context),
                          ),

                          SizedBox(height: 8.h),

                          Text(
                            _stepSubtitle(state.currentStep),
                            style: AppTextStyles.bodyMedium(context),
                          ),

                          SizedBox(height: 40.h),

                          // ── Step content (IndexedStack keeps alive) ──────
                          IndexedStack(
                            index: stepIndex,
                            children: [
                              DriverStep1PersonalInfo(
                                cubit: cubit,
                                state: state,
                                firstNameController: _firstNameController,
                                lastNameController: _lastNameController,
                                firstNameFocus: _firstNameFocus,
                                lastNameFocus: _lastNameFocus,
                                noopFocus: _noopFocus,
                              ),
                              DriverStep2VehicleInfo(
                                cubit: cubit,
                                state: state,
                                makeController: _makeController,
                                modelController: _modelController,
                                colorController: _colorController,
                                plateController: _plateController,
                                makeFocus: _makeFocus,
                                modelFocus: _modelFocus,
                                colorFocus: _colorFocus,
                                plateFocus: _plateFocus,
                              ),
                              DriverStep3Documents(
                                cubit: cubit,
                                state: state,
                              ),
                            ],
                          ),

                          // ── General error banner ─────────────────────────
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

                          SizedBox(height: 40.h),

                          // ── Primary action button ────────────────────────
                          PrimaryButton(
                            label: _buttonLabel(state.currentStep),
                            isEnabled: _buttonEnabled(state),
                            isLoading: _buttonLoading(state),
                            onPressed: _buttonAction(cubit, state.currentStep),
                          ),

                          SizedBox(height: 32.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
