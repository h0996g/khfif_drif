import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:khfif_drif/core/theme/app_colors.dart';
import 'package:khfif_drif/core/theme/app_text_styles.dart';

import '../../../../data/models/passenger_ride_history_models.dart';
import '../../../../../shared/models/shared_ride_models.dart';
import '../../../../../shared/utils/date_formatter.dart';
import '../../../../../shared/utils/fare_formatter.dart';
import '../../../../../shared/utils/name_initials.dart';
import '../../../../../shared/widgets/ride_route_preview.dart';
import '../../../../../shared/widgets/service_type_chip.dart';

/// A single completed/cancelled ride in the passenger's history list.
///
/// Composes shared ride widgets ([ServiceTypeChip], [RideRoutePreview],
/// [formatFare], [initialsOf]) with history-specific chrome: a state badge,
/// the driver avatar + name + vehicle, the ride date, and an optional
/// cancellation-reason box.
class PassengerRideHistoryCard extends StatelessWidget {
  const PassengerRideHistoryCard({super.key, required this.ride});

  final PassengerRideHistoryItem ride;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderDefault(context), width: 1.w),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 16.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header: service chip + state badge · fare ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 6.w,
                  runSpacing: 4.h,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ServiceTypeChip(serviceType: ride.serviceType),
                    _StateBadge(state: ride.state),
                  ],
                ),
              ),
              SizedBox(width: 6.w),
              _FareBlock(amount: ride.finalFare),
            ],
          ),
          SizedBox(height: 14.h),

          // --- Route: pickup → dropoff ---
          RideRoutePreview(
            pickup: ride.pickupAddress,
            dropoff: ride.dropoffAddress,
          ),
          SizedBox(height: 14.h),

          // --- Footer: driver + vehicle · date ---
          Row(
            children: [
              _Avatar(name: ride.driverFullName),
              SizedBox(width: 8.w),
              Expanded(child: _DriverInfo(ride: ride)),
              if (ride.displayDate != null) ...[
                SizedBox(width: 8.w),
                Text(
                  formatRideDate(ride.displayDate!),
                  style: AppTextStyles.labelSmall(context).copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ],
          ),

          if (ride.state == RideOutcome.cancelled &&
              (ride.cancellationReason?.isNotEmpty ?? false)) ...[
            SizedBox(height: 12.h),
            _CancellationReason(reason: ride.cancellationReason!),
          ],
        ],
      ),
    );
  }
}

// ── History-specific pieces ──────────────────────────────────────────────────

class _DriverInfo extends StatelessWidget {
  const _DriverInfo({required this.ride});

  final PassengerRideHistoryItem ride;

  @override
  Widget build(BuildContext context) {
    final vehicle = [ride.vehicleModel, ride.vehiclePlate]
        .where((e) => e.isNotEmpty)
        .join(' · ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          ride.driverFullName.isEmpty ? 'Driver' : ride.driverFullName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.labelMedium(context).copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (vehicle.isNotEmpty) ...[
          SizedBox(height: 2.h),
          Text(
            vehicle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelSmall(context).copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ],
    );
  }
}

class _StateBadge extends StatelessWidget {
  const _StateBadge({required this.state});

  final RideOutcome state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: state.color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(state.icon, size: 14.w, color: state.color),
          SizedBox(width: 3.w),
          Text(
            state.label,
            style: AppTextStyles.labelSmall(context).copyWith(
              color: state.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FareBlock extends StatelessWidget {
  const _FareBlock({required this.amount});

  final int amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          formatFare(amount),
          style: AppTextStyles.headingSmall(context).copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        SizedBox(width: 3.w),
        Padding(
          padding: EdgeInsets.only(bottom: 1.h),
          child: Text(
            'DZD',
            style: AppTextStyles.labelSmall(context).copyWith(
              color: AppColors.textSecondary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28.w,
      height: 28.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Text(
        initialsOf(name),
        style: AppTextStyles.labelSmall(context).copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CancellationReason extends StatelessWidget {
  const _CancellationReason({required this.reason});

  final String reason;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 14.w, color: AppColors.error),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              reason,
              style: AppTextStyles.labelSmall(context).copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
