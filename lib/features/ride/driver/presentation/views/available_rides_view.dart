import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/top_bar.dart';
import '../../data/models/driver_ride_models.dart';
import '../cubit/available_rides_cubit/available_rides_cubit.dart';
import '../cubit/available_rides_cubit/available_rides_state.dart';
import 'widgets/available_ride/available_ride_card.dart';
import 'widgets/available_ride/bid_sheet.dart';

class AvailableRidesView extends StatefulWidget {
  const AvailableRidesView({super.key});

  @override
  State<AvailableRidesView> createState() => _AvailableRidesViewState();
}

class _AvailableRidesViewState extends State<AvailableRidesView> {
  @override
  void initState() {
    super.initState();
    context.read<AvailableRidesCubit>().loadAvailableRides();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const TopBar(title: 'Available Rides'),
            Expanded(
              // Bid feedback (success, wallet gate, failures) and the
              // offer-accepted navigation are owned by DriverHomeShell's
              // listener so they fire on every driver screen, not just here.
              child: BlocBuilder<AvailableRidesCubit, AvailableRidesState>(
                builder: (context, state) {
                  if (state.rides.isEmpty) {
                    if (state.status == AvailableRidesStatus.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.status == AvailableRidesStatus.failure) {
                      return _Message(
                        icon: Icons.error_outline_rounded,
                        text: state.errorMessage.isEmpty
                            ? 'Something went wrong'
                            : state.errorMessage,
                      );
                    }
                    return const _Message(
                      icon: Icons.directions_car_filled_outlined,
                      text: "You're online — waiting for ride requests…",
                    );
                  }
                  return ListView.builder(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                    itemCount: state.rides.length,
                    itemBuilder: (context, index) {
                      final ride = state.rides[index];
                      return AvailableRideCard(
                        ride: ride,
                        onBid: () => _openBidSheet(context, ride),
                        onIgnore: () => context
                            .read<AvailableRidesCubit>()
                            .ignoreRide(ride.rideRequestId),
                        onExpired: () => context
                            .read<AvailableRidesCubit>()
                            .ignoreRide(ride.rideRequestId),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openBidSheet(
    BuildContext context,
    AvailableRequestCard ride,
  ) async {
    // Capture the shell-scoped cubit before the modal swaps the context.
    final cubit = context.read<AvailableRidesCubit>();
    final fare = await showBidSheet(context, proposedFare: ride.proposedFare);
    if (fare != null) {
      cubit.submitBid(ride.rideRequestId, fare);
    }
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
