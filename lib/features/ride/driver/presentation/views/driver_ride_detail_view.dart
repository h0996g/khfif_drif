import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/app_slim_app_bar.dart';
import '../../data/models/driver_ride_detail_models.dart';
import '../../../shared/models/shared_ride_models.dart';
import '../../../shared/utils/date_formatter.dart';
import '../../../shared/widgets/ride_route_preview.dart';
import '../../../shared/widgets/service_type_chip.dart';
import '../cubit/driver_ride_detail_cubit/driver_ride_detail_cubit.dart';
import '../cubit/driver_ride_detail_cubit/driver_ride_detail_state.dart';
import 'widgets/active/fare_card.dart';
import 'widgets/active/passenger_info_card.dart';

/// Full detail for a single past ride, reached by tapping a history card.
class DriverRideDetailView extends StatelessWidget {
  const DriverRideDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppSlimAppBar(
        title: 'Ride Details',
        onLeadingTap: () => context.pop(),
      ),
      body: SafeArea(
        child: BlocBuilder<DriverRideDetailCubit, DriverRideDetailState>(
          builder: (context, state) {
            if (state.status == DriverRideDetailStatus.initial ||
                state.status == DriverRideDetailStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            final ride = state.ride;
            if (state.status == DriverRideDetailStatus.failure ||
                ride == null) {
              return _Message(
                icon: Icons.error_outline_rounded,
                text: state.errorMessage.isEmpty
                    ? 'Failed to load ride details.'
                    : state.errorMessage,
              );
            }

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _StatusHeader(ride: ride),
                  SizedBox(height: 12.h),
                  PassengerInfoCard(
                    fullName: ride.passengerFullName.isEmpty
                        ? 'Passenger'
                        : ride.passengerFullName,
                    phone:
                        ride.passengerPhone.isEmpty ? '—' : ride.passengerPhone,
                  ),
                  SizedBox(height: 12.h),
                  _RouteCard(ride: ride),
                  SizedBox(height: 12.h),
                  FareCard(finalFare: ride.finalFare),
                  if (ride.distanceMeters != null ||
                      ride.durationSeconds != null) ...[
                    SizedBox(height: 12.h),
                    _TripFacts(ride: ride),
                  ],
                  SizedBox(height: 12.h),
                  _Timeline(ride: ride),
                  if (ride.state == RideOutcome.cancelled &&
                      (ride.cancellationReason?.isNotEmpty ?? false)) ...[
                    SizedBox(height: 12.h),
                    _CancellationReason(reason: ride.cancellationReason!),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Detail-specific pieces ───────────────────────────────────────────────────

class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.ride});

  final DriverRideDetail ride;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderDefault(context), width: 1.w),
      ),
      child: Row(
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
          if (ride.displayDate != null) ...[
            SizedBox(width: 6.w),
            Text(
              formatRideDate(ride.displayDate!),
              style: AppTextStyles.labelSmall(context).copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ],
      ),
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

class _RouteCard extends StatelessWidget {
  const _RouteCard({required this.ride});

  final DriverRideDetail ride;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderDefault(context), width: 1.w),
      ),
      child: RideRoutePreview(
        pickup: ride.pickupAddress,
        dropoff: ride.dropoffAddress,
      ),
    );
  }
}

class _TripFacts extends StatelessWidget {
  const _TripFacts({required this.ride});

  final DriverRideDetail ride;

  String get _distance => ride.distanceMeters == null
      ? '—'
      : '${(ride.distanceMeters! / 1000).toStringAsFixed(1)} km';

  String get _duration => ride.durationSeconds == null
      ? '—'
      : '${(ride.durationSeconds! / 60).round()} min';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderDefault(context), width: 1.w),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Fact(
              icon: Icons.route_rounded,
              label: 'Distance',
              value: _distance,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _Fact(
              icon: Icons.timer_outlined,
              label: 'Duration',
              value: _duration,
            ),
          ),
        ],
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20.w, color: AppColors.primary),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelSmall(context).copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: AppTextStyles.bodyMedium(context).copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.ride});

  final DriverRideDetail ride;

  @override
  Widget build(BuildContext context) {
    final events = <({String label, IconData icon, String at})>[
      if (ride.acceptedAt != null)
        (
          label: 'Accepted',
          icon: Icons.handshake_outlined,
          at: ride.acceptedAt!,
        ),
      if (ride.arrivedAt != null)
        (label: 'Arrived', icon: Icons.flag_outlined, at: ride.arrivedAt!),
      if (ride.startedAt != null)
        (label: 'Started', icon: Icons.local_taxi_rounded, at: ride.startedAt!),
      if (ride.completedAt != null)
        (
          label: 'Completed',
          icon: Icons.check_circle_rounded,
          at: ride.completedAt!,
        ),
      if (ride.cancelledAt != null)
        (label: 'Cancelled', icon: Icons.cancel_rounded, at: ride.cancelledAt!),
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderDefault(context), width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Timeline',
            style: AppTextStyles.labelMedium(context).copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10.h),
          for (final (index, event) in events.indexed) ...[
            _TimelineRow(event: event),
            if (index != events.length - 1) SizedBox(height: 10.h),
          ],
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.event});

  final ({String label, IconData icon, String at}) event;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(event.icon, size: 18.w, color: AppColors.textSecondary(context)),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            event.label,
            style: AppTextStyles.bodyMedium(context),
          ),
        ),
        Text(
          formatRideDateTime(event.at),
          style: AppTextStyles.labelSmall(context).copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
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

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48.w, color: AppColors.textSecondary(context)),
            SizedBox(height: 12.h),
            Text(
              text,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
