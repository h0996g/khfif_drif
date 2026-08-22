import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/widgets/app_toast.dart';
import '../../../../../home/driver/presentation/cubit/driver_home_cubit.dart';
import '../../cubit/driver_profile_cubit/driver_profile_cubit.dart';
import '../../cubit/driver_profile_cubit/driver_profile_state.dart';

class DriverFemaleOnlyWidget extends StatelessWidget {
  const DriverFemaleOnlyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Listener-only (no builder): surfaces errors and syncs the shell profile
    // without rebuilding the row.
    return BlocListener<DriverProfileCubit, DriverProfileState>(
      listenWhen: (prev, curr) =>
          (curr.status == DriverProfileStatus.failed &&
              curr.errorMessage.isNotEmpty) ||
          (prev.status != DriverProfileStatus.success &&
              curr.status == DriverProfileStatus.success &&
              curr.updatedProfile != null),
      listener: (context, state) {
        if (state.status == DriverProfileStatus.failed) {
          AppToast.error(state.errorMessage);
          return;
        }
        // Keep the shell-scoped profile in sync so re-entering the screen
        // seeds from fresh data.
        context.read<DriverHomeCubit>().updateProfile(state.updatedProfile!);
      },
      child: const _FemaleOnlyRow(),
    );
  }
}

class _FemaleOnlyRow extends StatelessWidget {
  const _FemaleOnlyRow();

  @override
  Widget build(BuildContext context) {
    final isEnabled = context.select<DriverProfileCubit, bool>(
      (cubit) => cubit.state.acceptsFemaleOnly,
    );
    final isPending = context.select<DriverProfileCubit, bool>(
      (cubit) => cubit.state.isPending,
    );

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
          Icon(
            Icons.female_rounded,
            size: 20.w,
            color: isEnabled
                ? AppColors.primary
                : AppColors.textSecondary(context),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Female passengers only',
              style: AppTextStyles.inputText(context),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          isPending
              ? SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              : Switch(
                  value: isEnabled,
                  onChanged: (value) => context
                      .read<DriverProfileCubit>()
                      .setAcceptsFemaleOnly(value),
                  activeThumbColor: AppColors.primary,
                  activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
                ),
        ],
      ),
    );
  }
}
