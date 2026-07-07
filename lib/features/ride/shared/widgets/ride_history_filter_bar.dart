import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/shared_ride_models.dart';

/// Ride-history filter row-pair docked under the top bar: a service-type
/// segment (All/Ride/Delivery) and a status segment (All/Completed/
/// Cancelled). Selecting a segment applies instantly via [onChanged] — there
/// is no separate "apply" step, matching how the rest of the ride history
/// screen already refetches live from the server.
///
/// Status is intentionally limited to `All/Completed/Cancelled`: both
/// `GET /api/passenger/rides` and `GET /api/driver/rides` only ever return
/// completed and cancelled rides (see `swagger/*.json`), so the other
/// `RideOutcome` values would never match anything here.
class RideHistoryFilterBar extends StatelessWidget {
  const RideHistoryFilterBar({
    super.key,
    required this.filter,
    required this.onChanged,
  });

  static const List<RideOutcome?> _statusValues = [
    null,
    RideOutcome.completed,
    RideOutcome.cancelled,
  ];
  static const List<String> _statusLabels = ['All', 'Completed', 'Cancelled'];

  static const List<ServiceType?> _serviceTypeValues = [
    null,
    ServiceType.ride,
    ServiceType.delivery,
  ];
  static const List<String> _serviceTypeLabels = ['All', 'Ride', 'Delivery'];

  final RideHistoryFilter filter;
  final ValueChanged<RideHistoryFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SlidingSegmentedControl<ServiceType?>(
            values: _serviceTypeValues,
            labels: _serviceTypeLabels,
            selected: filter.serviceType,
            onChanged: (value) =>
                onChanged(filter.copyWith(serviceType: () => value)),
          ),
          SizedBox(height: 8.h),
          _SlidingSegmentedControl<RideOutcome?>(
            values: _statusValues,
            labels: _statusLabels,
            selected: filter.state,
            onChanged: (value) =>
                onChanged(filter.copyWith(state: () => value)),
          ),
        ],
      ),
    );
  }
}

/// Fixed-width sliding-pill segmented control shared by both filter rows.
/// Mirrors the visual language of `ServiceTypeSelector` (`AnimatedAlign`
/// highlight + `AnimatedDefaultTextStyle` label + selection haptics) so the
/// two segmented rows read as one system.
class _SlidingSegmentedControl<T> extends StatelessWidget {
  const _SlidingSegmentedControl({
    required this.values,
    required this.labels,
    required this.selected,
    required this.onChanged,
  }) : assert(values.length == labels.length);

  final List<T> values;
  final List<String> labels;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final selectedIndex = values.indexOf(selected);

    return LayoutBuilder(
      builder: (context, constraints) {
        final segmentWidth = constraints.maxWidth / values.length;

        return Container(
          height: 40.h,
          padding: EdgeInsets.all(3.r),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.borderDefault(context)),
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                alignment: Alignment(
                  values.length == 1
                      ? 0
                      : -1 + (2 * selectedIndex) / (values.length - 1),
                  0,
                ),
                child: Container(
                  width: segmentWidth - 3.w,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(11.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < values.length; i++)
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (i == selectedIndex) return;
                          HapticFeedback.selectionClick();
                          onChanged(values[i]);
                        },
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 180),
                            style: AppTextStyles.labelSmall(context).copyWith(
                              color: i == selectedIndex
                                  ? AppColors.white
                                  : AppColors.textSecondary(context),
                              fontWeight: i == selectedIndex
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                            child: Text(
                              labels[i],
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
