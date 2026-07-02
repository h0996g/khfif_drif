import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:go_router/go_router.dart';
import 'package:khfif_drif/features/ride/passenger/data/models/passenger_ride_models.dart';

import '../../../../../core/router/route_names.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/top_bar.dart';
import '../cubit/passenger_home_cubit.dart';
import '../cubit/passenger_home_state.dart';
import 'widgets/home_bottom_panel.dart';
import 'widgets/home_drawer.dart';

class PassengerHomeShell extends StatelessWidget {
  const PassengerHomeShell({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: ZoomDrawer(
        style: DrawerStyle.defaultStyle,
        menuScreen: const HomeDrawer(),
        mainScreen: child,
        borderRadius: 30,
        showShadow: true,
        angle: 1,
        menuBackgroundColor: AppColors.drawerBackground(context),
        moveMenuScreen: false,
        slideWidth: MediaQuery.sizeOf(context).width * 0.72,
      ),
    );
  }
}

class PassengerHomeView extends StatelessWidget {
  const PassengerHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<PassengerHomeCubit, PassengerHomeState>(
      listenWhen: (prev, curr) =>
          prev.activeRideStatus != curr.activeRideStatus,
      listener: (context, state) {
        if (state.activeRideStatus == ActiveRideStatus.foundRequest) {
          final request = state.activeRequest!;
          context.go(
            RouteNames.waitingOffers,
            extra: WaitingOffersArgs(
              pickup: request.pickup,
              dropoff: request.dropoff,
              proposedFare: request.proposedFare,
              response: CreateRideResponse(
                rideRequestId: request.rideRequestId,
                state: request.state,
                proposedFare: request.proposedFare,
                expiresAt: request.expiresAt,
                broadcastDriverCount: request.broadcastDriverCount,
              ),
            ),
          );
          context.read<PassengerHomeCubit>().clearActiveRideStatus();
        }

        if (state.activeRideStatus == ActiveRideStatus.foundRide) {
          context.go(RouteNames.passengerActiveRide);
          context.read<PassengerHomeCubit>().clearActiveRideStatus();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        body: SafeArea(
          child: BlocBuilder<PassengerHomeCubit, PassengerHomeState>(
            buildWhen: (prev, curr) =>
                prev.activeRideStatus != curr.activeRideStatus,
            builder: (context, state) {
              if (state.activeRideStatus == ActiveRideStatus.loading) {
                return const Center(child: CircularProgressIndicator());
              }
              return const Column(
                children: [
                  TopBar(),
                  HomeBottomPanel(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
