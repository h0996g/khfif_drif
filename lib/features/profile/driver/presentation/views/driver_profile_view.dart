import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../auth/presentation/views/widgets/profile/profile_field_label_widget.dart';
import '../../../../../core/router/route_names.dart';
import '../../../passenger/presentation/views/widgets/profile_phone_edit_row_widget.dart';
import '../../../passenger/presentation/views/widgets/profile_edit_shimmer_widget.dart';
import '../../../passenger/presentation/views/widgets/profile_email_edit_row_widget.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/app_scaffold.dart';
import '../../../../home/passenger/presentation/views/widgets/top_bar.dart';
import '../../../../home/driver/presentation/cubit/driver_home_cubit.dart';
import '../../../../home/driver/presentation/cubit/driver_home_state.dart';
import '../../data/driver_service_types_repository.dart';
import '../../data/driver_profile_repository.dart';
import '../cubit/driver_service_types_cubit/driver_service_types_cubit.dart';
import '../cubit/driver_profile_cubit/driver_profile_cubit.dart';
import 'widgets/driver_service_types_widget.dart';
import 'widgets/driver_female_only_widget.dart';

class DriverProfileView extends StatelessWidget {
  const DriverProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(
        children: [
          const TopBar(
            title: 'Profile',
            subtitle: 'Driver Mode',
            leadingIcon: Icons.menu_rounded,
            trailingIcon: null,
          ),
          Expanded(
            child: BlocBuilder<DriverHomeCubit, DriverHomeState>(
              builder: (context, state) {
                if (state.status == DriverHomeStatus.loading ||
                    state.status == DriverHomeStatus.initial) {
                  return const ProfileEditShimmerWidget();
                }

                if (state.status == DriverHomeStatus.failure) {
                  return Center(
                    child: Text(
                      state.errorMessage.isNotEmpty
                          ? state.errorMessage
                          : 'Failed to load profile.',
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  );
                }

                final profile = state.profile;
                if (profile == null) return const SizedBox.shrink();

                final isMale = profile.gender.toUpperCase() == 'MALE';

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 24.h),
                      const ProfileFieldLabelWidget(label: 'Full Name'),
                      SizedBox(height: 8.h),
                      _ReadOnlyField(
                        icon: Icons.person_outline_rounded,
                        value: profile.fullName,
                      ),
                      SizedBox(height: 24.h),
                      const ProfileFieldLabelWidget(label: 'Gender'),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Expanded(
                            child: _ReadOnlyGenderChip(
                              label: 'Male',
                              icon: Icons.male_rounded,
                              isSelected: isMale,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _ReadOnlyGenderChip(
                              label: 'Female',
                              icon: Icons.female_rounded,
                              isSelected: !isMale,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      const ProfileFieldLabelWidget(label: 'Phone'),
                      SizedBox(height: 8.h),
                      ProfilePhoneEditRowWidget(
                        phone: profile.phone,
                        onTap: () => context.push(
                          RouteNames.driverPhoneEdit,
                          extra: profile.phone,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      const ProfileFieldLabelWidget(
                        label: 'Email',
                        badge: 'Optional',
                      ),
                      SizedBox(height: 8.h),
                      ProfileEmailEditRowWidget(
                        email: profile.email,
                        onTap: () => context.push(
                          RouteNames.driverEmailEdit,
                          extra: profile.email ?? '',
                        ),
                      ),
                      SizedBox(height: 24.h),
                      const ProfileFieldLabelWidget(label: 'Service Types'),
                      SizedBox(height: 8.h),
                      BlocProvider(
                        create: (_) => DriverServiceTypesCubit(
                          const DriverServiceTypesRepository(),
                        )..seed(
                            context
                                    .read<DriverHomeCubit>()
                                    .state
                                    .profile
                                    ?.activeServiceTypes ??
                                {},
                          ),
                        child: const DriverServiceTypesWidget(),
                      ),
                      SizedBox(height: 24.h),
                      const ProfileFieldLabelWidget(label: 'Preferences'),
                      SizedBox(height: 8.h),
                      BlocProvider(
                        create: (_) => DriverProfileCubit(
                          const DriverProfileRepository(),
                        )..seed(
                            context
                                    .read<DriverHomeCubit>()
                                    .state
                                    .profile
                                    ?.acceptsFemaleOnly ??
                                false,
                          ),
                        child: const DriverFemaleOnlyWidget(),
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.icon,
    required this.value,
  });

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.borderDefault(context),
          width: 1.5.w,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20.w, color: AppColors.textSecondary(context)),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.inputText(context),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyGenderChip extends StatelessWidget {
  const _ReadOnlyGenderChip({
    required this.label,
    required this.icon,
    required this.isSelected,
  });

  final String label;
  final IconData icon;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.12)
            : AppColors.surface(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color:
              isSelected ? AppColors.primary : AppColors.borderDefault(context),
          width: isSelected ? 2.w : 1.5.w,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20.w,
            color: isSelected
                ? AppColors.primary
                : AppColors.textSecondary(context),
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: AppTextStyles.labelMedium(context).copyWith(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textSecondary(context),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
