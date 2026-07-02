import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/router/route_names.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/app_toast.dart';
import '../../../../../shared/widgets/primary_button.dart';
import '../../data/models/driver_ride_models.dart';
import '../../../shared/widgets/ride_route_card.dart';
import '../cubit/driver_active_ride_cubit/driver_active_ride_cubit.dart';
import '../cubit/driver_active_ride_cubit/driver_active_ride_state.dart';
import 'widgets/active/active_ride_map.dart';
import 'widgets/active/cancel_ride_button.dart';
import 'widgets/active/fare_card.dart';
import 'widgets/active/floating_back_button.dart';
import 'widgets/active/passenger_info_card.dart';

class DriverActiveRideView extends StatefulWidget {
  const DriverActiveRideView({super.key});

  @override
  State<DriverActiveRideView> createState() => _DriverActiveRideViewState();
}

class _DriverActiveRideViewState extends State<DriverActiveRideView> {
  StreamSubscription<Position>? _positionSub;
  Position? _driverPosition;

  @override
  void initState() {
    super.initState();
    context.read<DriverActiveRideCubit>().loadActiveRide();
    _startLocationUpdates();
  }

  Future<void> _startLocationUpdates() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }
    _positionSub = Geolocator.getPositionStream(
      locationSettings:
          const LocationSettings(accuracy: LocationAccuracy.high),
    ).listen((pos) {
      if (mounted) setState(() => _driverPosition = pos);
    });
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: BlocConsumer<DriverActiveRideCubit, DriverActiveRideState>(
        listenWhen: (prev, curr) =>
            curr.status == DriverActiveRideStatus.cancelled ||
            curr.status == DriverActiveRideStatus.completed ||
            curr.status == DriverActiveRideStatus.actionFailure,
        listener: (context, state) {
          switch (state.status) {
            case DriverActiveRideStatus.cancelled:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ride was cancelled')),
              );
              context.go(RouteNames.driverHome);
            case DriverActiveRideStatus.completed:
              AppToast.success(
                'Ride completed — ${state.completedFare ?? 0} DZD',
              );
              context.go(RouteNames.driverHome);
            case DriverActiveRideStatus.actionFailure:
              AppToast.error(state.errorMessage);
            default:
              break;
          }
        },
        builder: (context, state) {
          if (state.status == DriverActiveRideStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == DriverActiveRideStatus.noActiveRide) {
            return Center(
              child: Text(
                'No active ride',
                style: AppTextStyles.bodyMedium(context)
                    .copyWith(color: AppColors.textSecondary(context)),
              ),
            );
          }
          if (state.status == DriverActiveRideStatus.failure) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Text(
                  state.errorMessage.isEmpty
                      ? 'Could not load ride'
                      : state.errorMessage,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium(context)
                      .copyWith(color: AppColors.textSecondary(context)),
                ),
              ),
            );
          }

          final ride = state.ride;
          if (ride == null) return const SizedBox.shrink();

          return _RideStack(
            ride: ride,
            driverPosition: _driverPosition,
            isTransitioning:
                state.status == DriverActiveRideStatus.transitioning,
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _RideStack extends StatelessWidget {
  const _RideStack({
    required this.ride,
    required this.driverPosition,
    required this.isTransitioning,
  });

  final ActiveDriverRideResponse ride;
  final Position? driverPosition;
  final bool isTransitioning;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Stack(
      children: [
        // Full-screen map with zoom controls built in
        Positioned.fill(
          child: ActiveRideMap(ride: ride, driverPosition: driverPosition),
        ),

        // Floating back button
        Positioned(
          top: topPadding + 8.h,
          left: 16.w,
          child: const FloatingBackButton(),
        ),

        // Draggable bottom sheet
        DraggableScrollableSheet(
          initialChildSize: 0.45,
          minChildSize: 0.14,
          maxChildSize: 0.88,
          snap: true,
          snapSizes: const [0.45],
          builder: (ctx, scrollController) => _SheetContent(
            scrollController: scrollController,
            ride: ride,
            isTransitioning: isTransitioning,
            bottomPadding: bottomPadding,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _SheetContent extends StatelessWidget {
  const _SheetContent({
    required this.scrollController,
    required this.ride,
    required this.isTransitioning,
    required this.bottomPadding,
  });

  final ScrollController scrollController;
  final ActiveDriverRideResponse ride;
  final bool isTransitioning;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DriverActiveRideCubit>();
    final canCancel = ride.state == ActiveDriverRideState.accepted ||
        ride.state == ActiveDriverRideState.arrived;

    final (actionLabel, onAction) = switch (ride.state) {
      ActiveDriverRideState.accepted => ('Mark Arrived', cubit.markArrived),
      ActiveDriverRideState.arrived => ('Start Ride', cubit.startRide),
      ActiveDriverRideState.inProgress => ('Complete Ride', cubit.completeRide),
      _ => ('', null as VoidCallback?),
    };

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background(context),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20.w,
            12.h,
            20.w,
            bottomPadding + 20.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: AppColors.borderDefault(context),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),

              // Peek row — always visible at collapsed state
              _PeekRow(
                fullName: ride.passengerFullName,
                rideState: ride.state,
              ),
              SizedBox(height: 16.h),

              // Full content
              PassengerInfoCard(
                fullName: ride.passengerFullName,
                phone: ride.passengerPhone,
              ),
              SizedBox(height: 12.h),

              RideRouteCard(pickup: ride.pickup, dropoff: ride.dropoff),
              SizedBox(height: 12.h),

              FareCard(finalFare: ride.finalFare),
              SizedBox(height: 16.h),

              if (actionLabel.isNotEmpty)
                PrimaryButton(
                  label: actionLabel,
                  onPressed: onAction,
                  isLoading: isTransitioning,
                  isEnabled: !isTransitioning,
                ),

              if (canCancel) ...[
                SizedBox(height: 10.h),
                CancelRideButton(
                  onCancel: () =>
                      cubit.cancelRide(CancelReason.driverVehicleIssue),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _PeekRow extends StatelessWidget {
  const _PeekRow({required this.fullName, required this.rideState});

  final String fullName;
  final ActiveDriverRideState rideState;

  @override
  Widget build(BuildContext context) {
    final (stateLabel, stateColor) = switch (rideState) {
      ActiveDriverRideState.accepted => ('On the way', AppColors.primary),
      ActiveDriverRideState.arrived => ('Arrived', Colors.orange),
      ActiveDriverRideState.inProgress => ('In ride', Colors.blue),
      _ => ('', AppColors.textSecondary(context)),
    };

    return Row(
      children: [
        CircleAvatar(
          radius: 18.r,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Icon(Icons.person_rounded,
              color: AppColors.primary, size: 20.w),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            fullName,
            style: AppTextStyles.bodyMedium(context)
                .copyWith(fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 8.w),
        if (stateLabel.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: stateColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              stateLabel,
              style: AppTextStyles.labelSmall(context).copyWith(
                color: stateColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}
