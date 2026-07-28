import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/router/route_names.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_toast.dart';
import '../../../../ride/driver/presentation/cubit/available_rides_cubit/available_rides_cubit.dart';
import '../../../../ride/driver/presentation/cubit/available_rides_cubit/available_rides_state.dart';
import '../../../../ride/driver/presentation/cubit/driver_availability_cubit/driver_availability_cubit.dart';
import '../../../../ride/driver/presentation/views/widgets/available_ride/broadcast_overlay.dart';
import '../../../../wallet/driver/presentation/cubit/wallet_cubit/wallet_cubit.dart';
import '../cubit/driver_home_cubit.dart';
import '../cubit/driver_home_state.dart';
import 'widgets/driver_home_drawer.dart';

class DriverHomeShell extends StatelessWidget {
  const DriverHomeShell({
    super.key,
    required this.child,
  });

  final Widget child;

  static const _hideOverlayRoutes = {
    RouteNames.availableRides,
    RouteNames.driverActiveRide,
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentPath = GoRouterState.of(context).uri.path;
    final showOverlay = !_hideOverlayRoutes.contains(currentPath);

    // Shell-scoped listener: AvailableRidesCubit already receives the
    // `offer.accepted` socket frame on every driver screen, so react here (at
    // the shell) rather than only inside AvailableRidesView — this way the
    // driver is taken to the active ride no matter which screen is showing.
    return MultiBlocListener(
      listeners: [
        BlocListener<DriverHomeCubit, DriverHomeState>(
          listenWhen: (prev, curr) =>
              prev.status != curr.status &&
              curr.status == DriverHomeStatus.success,
          listener: (context, state) {
            context
                .read<DriverAvailabilityCubit>()
                .seed(state.profile!.isOnline);
          },
        ),
        // Bidding happens from the floating BroadcastOverlay on any driver
        // screen, so every bid outcome — navigation, success, the wallet gate,
        // plain failures — is handled here rather than inside AvailableRidesView.
        BlocListener<AvailableRidesCubit, AvailableRidesState>(
          listenWhen: (prev, curr) => prev.status != curr.status,
          listener: _onRidesStateChanged,
        ),
      ],
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        ),
        child: Stack(
          children: [
            ZoomDrawer(
              style: DrawerStyle.defaultStyle,
              menuScreen: const DriverHomeDrawer(),
              mainScreen: child,
              borderRadius: 30,
              showShadow: true,
              angle: 1,
              menuBackgroundColor: AppColors.drawerBackground(context),
              moveMenuScreen: false,
              slideWidth: MediaQuery.sizeOf(context).width * 0.72,
            ),
            if (showOverlay) const BroadcastOverlay(),
          ],
        ),
      ),
    );
  }

  void _onRidesStateChanged(BuildContext context, AvailableRidesState state) {
    switch (state.status) {
      case AvailableRidesStatus.offerAccepted:
        context.go(RouteNames.driverActiveRide);
      case AvailableRidesStatus.bidSuccess:
        AppToast.success('Bid submitted');
      case AvailableRidesStatus.gatedByBalance:
        // Same handling as the go-online gate: the cached gate was stale, so
        // refetch it — that locks the availability switch and surfaces the
        // tappable top-up hint, which is where the driver fixes this.
        context.read<WalletCubit>().refreshBalance();
        AppToast.error(
          state.errorMessage.isEmpty
              ? 'Top up your wallet to bid on rides.'
              : state.errorMessage,
        );
      case AvailableRidesStatus.failure when state.rides.isNotEmpty:
        // Cards are still on screen; surface the bid/refresh error without
        // wiping them.
        AppToast.error(
          state.errorMessage.isEmpty ? 'Bid failed' : state.errorMessage,
        );
      default:
        break;
    }
  }
}
