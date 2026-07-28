import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/router/route_names.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/widgets/app_toast.dart';
import '../../../../../../shared/widgets/dashed_divider.dart';
import '../../../../../../shared/widgets/drawer_item.dart';
import '../../../../../../shared/widgets/drawer_menu_item_data.dart';
import '../../../../../auth/data/repo/auth_repository.dart';
import '../../../../../auth/data/repo/driver_repository.dart';
import '../../../../../ride/driver/presentation/cubit/driver_availability_cubit/driver_availability_cubit.dart';
import '../../../../../ride/driver/presentation/cubit/driver_availability_cubit/driver_availability_state.dart';
import '../../cubit/driver_home_cubit.dart';
import '../../cubit/driver_home_state.dart';
import '../../../../../ride/driver/presentation/views/widgets/driver_availability_toggle_widget.dart';

const int _profileIndex = 1;
const int _ridesIndex = 2;
const int _rideHistoryIndex = 3;
const int _walletIndex = 4;
const int _switchRoleIndex = 8;
const int _logoutIndex = 9;

class DriverHomeDrawer extends StatelessWidget {
  const DriverHomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final menuItems = <DrawerMenuItemData>[
      const DrawerMenuItemData(Icons.home_outlined, 'Home'),
      const DrawerMenuItemData(Icons.person_outline_rounded, 'Profile'),
      const DrawerMenuItemData(Icons.directions_car_rounded, 'Rides'),
      const DrawerMenuItemData(Icons.history_rounded, 'Ride History'),
      const DrawerMenuItemData(
          Icons.account_balance_wallet_outlined, 'Wallet'),
      const DrawerMenuItemData(Icons.motorcycle_outlined, 'Vehicle Info'),
    ];

    final supportItems = <DrawerMenuItemData>[
      const DrawerMenuItemData(Icons.settings_outlined, 'Settings'),
      const DrawerMenuItemData(Icons.help_outline_rounded, 'Help & Support'),
    ];

    return BlocBuilder<DriverHomeCubit, DriverHomeState>(
      builder: (context, state) {
        final selectedIndex = state.selectedIndex;

        return Scaffold(
          backgroundColor: AppColors.drawerBackground(context),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDrawerHeader(context, state),
                  SizedBox(height: 18.h),
                  ..._buildMenuSection(
                    menuItems,
                    selectedIndex: selectedIndex,
                    context: context,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child: const DashedDivider(),
                  ),
                  ..._buildMenuSection(
                    supportItems,
                    startIndex: menuItems.length,
                    selectedIndex: selectedIndex,
                    context: context,
                  ),
                  SizedBox(height: 14.h),
                  DrawerItem(
                    icon: Icons.swap_horiz_rounded,
                    label: 'Go to Passenger',
                    isSelected: selectedIndex == _switchRoleIndex,
                    onTap: () => _onSwitchRoleTap(context),
                  ),
                  SizedBox(height: 14.h),
                  DrawerItem(
                    icon: Icons.logout_outlined,
                    label: 'Logout',
                    color: AppColors.error,
                    isSelected: selectedIndex == _logoutIndex,
                    onTap: () => _onMenuItemTap(context, _logoutIndex),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _onSwitchRoleTap(BuildContext context) {
    ZoomDrawer.of(context)?.close();
    _performSwitch(context, targetRole: 'PASSENGER');
  }

  Future<void> _performSwitch(
    BuildContext context, {
    required String targetRole,
  }) async {
    try {
      await const DriverRepository().switchRole(targetRole);
      final destination = targetRole == 'DRIVER'
          ? RouteNames.driverHome
          : RouteNames.passengerHome;
      context.go(destination);
    } catch (e) {
      AppToast.error('Failed to switch role. Please try again.');
    }
  }

  void _onMenuItemTap(BuildContext context, int index) {
    if (index == _logoutIndex) {
      context.read<DriverHomeCubit>().updateSelectedIndex(index);
      ZoomDrawer.of(context)?.close();
      const AuthRepository().logout();
      return;
    }

    // Index → destination route. Items not in the map fall back to Home.
    final route = switch (index) {
      _profileIndex => RouteNames.driverProfileEdit,
      _ridesIndex => RouteNames.availableRides,
      _rideHistoryIndex => RouteNames.driverRideHistory,
      _walletIndex => RouteNames.driverWallet,
      _ => RouteNames.driverHome,
    };
    // Highlight the active item only for routes with a dedicated screen.
    final selectedIndex = switch (index) {
      _profileIndex || _ridesIndex || _rideHistoryIndex || _walletIndex => index,
      _ => 0,
    };

    context.read<DriverHomeCubit>().updateSelectedIndex(selectedIndex);
    ZoomDrawer.of(context)?.close();
    context.go(route);
  }

  List<Widget> _buildMenuSection(
    List<DrawerMenuItemData> items, {
    int startIndex = 0,
    required int selectedIndex,
    required BuildContext context,
  }) {
    return List.generate(items.length, (offset) {
      final index = startIndex + offset;
      final item = items[offset];

      return DrawerItem(
        icon: item.icon,
        label: item.label,
        isSelected: selectedIndex == index,
        onTap: () => _onMenuItemTap(context, index),
      );
    });
  }

  Widget _buildDrawerHeader(BuildContext context, DriverHomeState state) {
    final name = state.profile?.fullName;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocBuilder<DriverAvailabilityCubit, DriverAvailabilityState>(
          builder: (context, availState) {
            return Container(
              width: 70.w,
              height: 70.w,
              decoration: BoxDecoration(
                color: AppColors.isDark(context)
                    ? AppColors.white
                    : AppColors.black,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.28),
                    blurRadius: 24.r,
                    offset: Offset(0, 10.h),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.person_rounded,
                    color: AppColors.isDark(context)
                        ? AppColors.black
                        : AppColors.white,
                    size: 36.w,
                  ),
                  Positioned(
                    right: 9.w,
                    bottom: 9.w,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: availState.isOnline
                            ? AppColors.primary
                            : AppColors.textSecondary(context),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.drawerBackground(context),
                          width: 2.w,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        SizedBox(height: 20.h),
        Text(
          name != null ? 'Hello, $name!' : 'Hello, Driver!',
          style: AppTextStyles.headingMedium(context).copyWith(
            color: AppColors.drawerText(context),
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        SizedBox(height: 6.h),
        const DriverAvailabilityToggleWidget(),
      ],
    );
  }
}
