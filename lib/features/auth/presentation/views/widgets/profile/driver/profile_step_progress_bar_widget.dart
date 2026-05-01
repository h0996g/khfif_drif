import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../../core/widgets/app_toast.dart';

class ProfileStepProgressBarWidget extends StatelessWidget {
  const ProfileStepProgressBarWidget({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepLabels,
    required this.completedSteps,
    required this.onStepTap,
  });

  final int currentStep;
  final int totalSteps;
  final List<String> stepLabels;

  /// 1-based indices of future steps the user is allowed to jump to.
  final Set<int> completedSteps;

  /// Called with 1-based step index when user taps a reachable step.
  final ValueChanged<int> onStepTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(totalSteps * 2 - 1, (i) {
        if (i.isOdd) return _Connector(filled: (i ~/ 2) + 1 < currentStep);
        final stepIndex = i ~/ 2 + 1;
        final isCompleted = stepIndex < currentStep;
        final isCurrent = stepIndex == currentStep;
        final isTappable =
            isCompleted || isCurrent || completedSteps.contains(stepIndex);
        final isFutureBlocked = stepIndex > currentStep && !isTappable;
        return _StepDot(
          stepIndex: stepIndex,
          label: stepLabels[i ~/ 2],
          isCompleted: isCompleted,
          isCurrent: isCurrent,
          onTap: isTappable
              ? () => onStepTap(stepIndex)
              : isFutureBlocked
                  ? () => AppToast.warning(
                        'Please complete the current step first.',
                      )
                  : null,
        );
      }),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.stepIndex,
    required this.label,
    required this.isCompleted,
    required this.isCurrent,
    required this.onTap,
  });

  final int stepIndex;
  final String label;
  final bool isCompleted;
  final bool isCurrent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color circleColor = (isCompleted || isCurrent)
        ? AppColors.primary
        : AppColors.borderDefault(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: isCurrent ? AppColors.primary : Colors.transparent,
              border: Border.all(
                color: circleColor,
                width: isCurrent ? 0 : 2,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? Icon(Icons.check_rounded,
                      size: 16.sp,
                      color: isCurrent ? Colors.white : AppColors.primary)
                  : Text(
                      '$stepIndex',
                      style: AppTextStyles.bodySmall(context).copyWith(
                        color: isCurrent
                            ? Colors.white
                            : (isCompleted
                                ? AppColors.primary
                                : AppColors.borderDefault(context)),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: AppTextStyles.bodySmall(context).copyWith(
              color: (isCompleted || isCurrent)
                  ? AppColors.primary
                  : AppColors.borderDefault(context),
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _Connector extends StatelessWidget {
  const _Connector({required this.filled});
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(bottom: 20.h),
        child: Align(
          alignment: Alignment.center,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 2.h,
            decoration: BoxDecoration(
              color:
                  filled ? AppColors.primary : AppColors.borderDefault(context),
              borderRadius: BorderRadius.circular(1.r),
            ),
          ),
        ),
      ),
    );
  }
}
