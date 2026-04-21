// lib/features/auth/presentation/views/passenger_profile_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../cubit/passenger_profile_cubit/passenger_profile_cubit.dart';
import '../cubit/passenger_profile_cubit/passenger_profile_state.dart';
import 'widgets/profile/profile_email_field_widget.dart';
import 'widgets/profile/profile_error_banner_widget.dart';
import 'widgets/profile/profile_field_label_widget.dart';
import 'widgets/profile/profile_gender_toggle_widget.dart';
import 'widgets/profile/profile_name_field_widget.dart';
import 'widgets/profile/profile_step_progress_bar_widget.dart';

/// Step 5 — Passenger Profile Setup.
///
/// Collects Full Name (required, validated), Gender (required, toggle),
/// and Email (optional). On success navigates to the Passenger Home screen.
class PassengerProfileView extends StatefulWidget {
  const PassengerProfileView({super.key});

  @override
  State<PassengerProfileView> createState() => _PassengerProfileViewState();
}

class _PassengerProfileViewState extends State<PassengerProfileView> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();

    _nameFocus.addListener(() {
      if (!_nameFocus.hasFocus) {
        context.read<PassengerProfileCubit>().nameFocusLost();
      }
    });
    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus) {
        context.read<PassengerProfileCubit>().emailFocusLost();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PassengerProfileCubit, PassengerProfileState>(
      listener: (context, state) {
        if (state.status == ProfileStatus.success) {
          context.go(RouteNames.passengerHome);
        }
      },
      builder: (context, state) {
        final cubit = context.read<PassengerProfileCubit>();
        final isSubmitting = state.status == ProfileStatus.submitting;

        return PopScope(
          canPop: false,
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

                          // ── Progress indicator ─────────────────────────────
                          const ProfileStepProgressBarWidget(
                              currentStep: 5, totalSteps: 6),

                          SizedBox(height: 32.h),

                          // ── Header ─────────────────────────────────────────
                          Text(
                            'Complete your\nprofile',
                            style: AppTextStyles.displayMedium(context),
                          ),

                          SizedBox(height: 8.h),

                          Text(
                            'Just a few quick details to get you started',
                            style: AppTextStyles.bodyMedium(context),
                          ),

                          SizedBox(height: 40.h),

                          // ── Full Name ──────────────────────────────────────
                          const ProfileFieldLabelWidget(label: 'Full Name'),
                          SizedBox(height: 8.h),
                          ProfileNameFieldWidget(
                            controller: _nameController,
                            focusNode: _nameFocus,
                            emailFocus: _emailFocus,
                            onChanged: cubit.nameChanged,
                            error: state.nameTouched ? state.nameError : '',
                            enabled: !isSubmitting,
                          ),

                          SizedBox(height: 24.h),

                          // ── Gender ─────────────────────────────────────────
                          const ProfileFieldLabelWidget(label: 'Gender'),
                          SizedBox(height: 8.h),
                          ProfileGenderToggleWidget(
                            selected: state.gender,
                            onChanged: cubit.genderChanged,
                            enabled: !isSubmitting,
                          ),

                          SizedBox(height: 24.h),

                          // ── Email (optional) ───────────────────────────────
                          const ProfileFieldLabelWidget(
                            label: 'Email',
                            badge: 'Optional',
                          ),
                          SizedBox(height: 8.h),
                          ProfileEmailFieldWidget(
                            controller: _emailController,
                            focusNode: _emailFocus,
                            onChanged: cubit.emailChanged,
                            error: state.emailTouched ? state.emailError : '',
                            enabled: !isSubmitting,
                          ),

                          // ── General error ──────────────────────────────────
                          AnimatedSize(
                            duration: const Duration(milliseconds: 160),
                            curve: Curves.easeOut,
                            child: state.errorMessage.isNotEmpty
                                ? Padding(
                                    padding: EdgeInsets.only(top: 16.h),
                                    child: ProfileErrorBannerWidget(
                                        message: state.errorMessage),
                                  )
                                : const SizedBox.shrink(),
                          ),

                          SizedBox(height: 40.h),

                          // ── Continue button ────────────────────────────────
                          PrimaryButton(
                            label: 'Continue',
                            isEnabled: state.canSubmit,
                            isLoading: isSubmitting,
                            onPressed: cubit.submit,
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
