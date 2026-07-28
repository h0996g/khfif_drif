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
import '../../../../ride/driver/data/models/ride_socket_event.dart';
import '../../../passenger/data/models/passenger_ride_models.dart';
import '../cubit/passenger_active_ride_cubit/passenger_active_ride_cubit.dart';
import '../cubit/passenger_active_ride_cubit/passenger_active_ride_state.dart';
import 'widgets/active_ride/cancel_ride_button.dart';
import 'widgets/active_ride/driver_card.dart';
import 'widgets/active_ride/fare_card.dart';
import 'widgets/active_ride/live_map_card.dart';
import 'widgets/active_ride/state_badge.dart';

class PassengerActiveRideView extends StatefulWidget {
  const PassengerActiveRideView({super.key});

  @override
  State<PassengerActiveRideView> createState() =>
      _PassengerActiveRideViewState();
}

class _PassengerActiveRideViewState extends State<PassengerActiveRideView> {
  StreamSubscription<Position>? _positionSub;
  Position? _ownPosition;

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
  }

  Future<void> _startLocationUpdates() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    ).listen((pos) {
      if (mounted) setState(() => _ownPosition = pos);
    });
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PassengerActiveRideCubit, PassengerActiveRideState>(
      listenWhen: (prev, curr) =>
          curr.status == PassengerActiveRideStatus.completed ||
          curr.status == PassengerActiveRideStatus.cancelled ||
          curr.status == PassengerActiveRideStatus.actionFailure,
      listener: (context, state) {
        switch (state.status) {
          case PassengerActiveRideStatus.actionFailure:
            AppToast.error(state.errorMessage);
          case PassengerActiveRideStatus.completed:
            AppToast.success('Ride completed!');
            context.go(RouteNames.passengerHome);
          case PassengerActiveRideStatus.cancelled:
            AppToast.warning('Ride was cancelled');
            context.go(RouteNames.passengerHome);
          default:
            break;
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background(context),
          body: switch (state.status) {
            PassengerActiveRideStatus.loading => const Center(
                child: CircularProgressIndicator(),
              ),
            PassengerActiveRideStatus.failure => Center(
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
              ),
            _ => state.ride == null
                ? const SizedBox.shrink()
                : _RideBody(state: state, ownPosition: _ownPosition),
          },
        );
      },
    );
  }
}

class _RideBody extends StatelessWidget {
  const _RideBody({required this.state, required this.ownPosition});

  final PassengerActiveRideState state;
  final Position? ownPosition;

  @override
  Widget build(BuildContext context) {
    final ride = state.ride!;
    final rideState = state.rideState;
    final canCancel =
        rideState == RideState.accepted || rideState == RideState.arrived;
    final double? driverLat = state.driverLat ?? ride.driver.currentLat;
    final double? driverLng = state.driverLng ?? ride.driver.currentLng;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Stack(
      children: [
        // Full-screen live map
        Positioned.fill(
          child: LiveMapCard(
            driverLat: driverLat,
            driverLng: driverLng,
            ownPosition: ownPosition,
            pickup: ride.pickup,
            dropoff: ride.dropoff,
            driverLabel:
                ride.driver.fullName.split(' ').firstOrNull ?? 'Driver',
          ),
        ),

        // Floating status badge
        Positioned(
          top: topPadding + 12.h,
          left: 16.w,
          right: 16.w,
          child: RideStateBadge(rideState: rideState),
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
            rideState: rideState,
            canCancel: canCancel,
            bottomPadding: bottomPadding,
          ),
        ),
      ],
    );
  }
}

class _SheetContent extends StatelessWidget {
  const _SheetContent({
    required this.scrollController,
    required this.ride,
    required this.rideState,
    required this.canCancel,
    required this.bottomPadding,
  });

  final ScrollController scrollController;
  final ActiveRideSummary ride;
  final RideState? rideState;
  final bool canCancel;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
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

              // Peek row — visible even when collapsed
              _PeekRow(driver: ride.driver, finalFare: ride.finalFare),
              SizedBox(height: 16.h),

              // Full content
              DriverCard(driver: ride.driver),
              SizedBox(height: 12.h),
              FareCard(finalFare: ride.finalFare),

              if (canCancel) ...[
                SizedBox(height: 10.h),
                CancelRideButton(
                  onCancel: (reason) => context
                      .read<PassengerActiveRideCubit>()
                      .cancelRide(reason),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PeekRow extends StatelessWidget {
  const _PeekRow({required this.driver, required this.finalFare});

  final DriverInRide driver;
  final int finalFare;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18.r,
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child:
              Icon(Icons.person_rounded, color: AppColors.primary, size: 20.w),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                driver.fullName,
                style: AppTextStyles.bodyMedium(context)
                    .copyWith(fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                driver.vehicleModel,
                style: AppTextStyles.bodySmall(context).copyWith(
                  color: AppColors.textSecondary(context),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            '$finalFare DZD',
            style: AppTextStyles.labelSmall(context).copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
