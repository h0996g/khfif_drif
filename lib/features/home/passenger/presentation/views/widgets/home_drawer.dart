import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/router/route_names.dart';
import '../../../../../../core/session/auth_session.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/widgets/app_toast.dart';
import '../../../../../../shared/widgets/dashed_divider.dart';
import '../../../../../../shared/widgets/drawer_item.dart';
import '../../../../../../shared/widgets/drawer_menu_item_data.dart';
import '../../../../../auth/data/models/kyc_status.dart';
import '../../../../../auth/data/repo/auth_repository.dart';
import '../../cubit/passenger_home_cubit.dart';
import '../../cubit/passenger_home_state.dart';

const int _profileIndex = 1;
const int _ridesIndex = 2;
const int _savedPlacesIndex = 3;
const int _switchRoleIndex = 8;
const int _logoutIndex = 9;

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final menuItems = <DrawerMenuItemData>[
      const DrawerMenuItemData(Icons.home_outlined, 'Home'),
      const DrawerMenuItemData(Icons.person_outline_rounded, 'Profile'),
      const DrawerMenuItemData(Icons.directions_car_rounded, 'My Rides'),
      const DrawerMenuItemData(Icons.bookmark_border_rounded, 'Saved Places'),
      const DrawerMenuItemData(Icons.credit_card_rounded, 'Payment'),
      const DrawerMenuItemData(Icons.local_offer_outlined, 'Promotions'),
    ];

    final supportItems = <DrawerMenuItemData>[
      const DrawerMenuItemData(Icons.settings_outlined, 'Settings'),
      const DrawerMenuItemData(Icons.help_outline_rounded, 'Help & Support'),
    ];

    return BlocBuilder<PassengerHomeCubit, PassengerHomeState>(
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
                  if (AuthSession.waitingKycStatus ||
                      AuthSession.hasDriverProfile) ...[
                    SizedBox(height: 14.h),
                    DrawerItem(
                      icon: Icons.swap_horiz_rounded,
                      label: 'Go to Driver',
                      isSelected: selectedIndex == _switchRoleIndex,
                      onTap: () => _onSwitchRoleTap(context),
                    ),
                  ] else ...[
                    SizedBox(height: 14.h),
                    DrawerItem(
                      icon: Icons.drive_eta_rounded,
                      label: 'Become a Driver',
                      isSelected: selectedIndex == _switchRoleIndex,
                      onTap: () {
                        ZoomDrawer.of(context)?.close();
                        final profile =
                            context.read<PassengerHomeCubit>().state.profile;
                        context.push(
                          RouteNames.driverProfile,
                          extra: profile,
                        );
                      },
                    ),
                  ],
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

  void _onSwitchRoleTap(BuildContext context) async {
    ZoomDrawer.of(context)?.close();
    final profile = context.read<PassengerHomeCubit>().state.profile;
    if (profile?.driverKycStatus == KycStatus.approved) {
      _performSwitch(context, targetRole: 'DRIVER');
    } else {
      await AuthSession.setWaitingKycStatus(true);
      context.go(RouteNames.driverStatusReview);
    }
  }

  Future<void> _performSwitch(
    BuildContext context, {
    required String targetRole,
  }) async {
    try {
      await const AuthRepository().switchRole(targetRole);
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
      context.read<PassengerHomeCubit>().updateSelectedIndex(index);
      ZoomDrawer.of(context)?.close();
      const AuthRepository().logout();
      return;
    }

    final route = switch (index) {
      _profileIndex => RouteNames.passengerProfileEdit,
      _ridesIndex => RouteNames.passengerRideHistory,
      _savedPlacesIndex => RouteNames.savedPlaces,
      _ => RouteNames.passengerHome,
    };
    // Highlight the active item only for routes with a dedicated screen.
    final selectedIndex = switch (index) {
      _profileIndex || _ridesIndex => index,
      _ => 0,
    };

    context.read<PassengerHomeCubit>().updateSelectedIndex(selectedIndex);
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

  Widget _buildDrawerHeader(BuildContext context, PassengerHomeState state) {
    final name = state.profile?.fullName;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 70.w,
          height: 70.w,
          decoration: BoxDecoration(
            color:
                AppColors.isDark(context) ? AppColors.white : AppColors.black,
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
                child: Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
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
        ),
        SizedBox(height: 20.h),
        Text(
          name != null ? 'Hello, $name!' : 'Hello, Passenger!',
          style: AppTextStyles.headingMedium(context).copyWith(
            color: AppColors.drawerText(context),
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'Ready for your next ride?',
          style: AppTextStyles.bodySmall(context).copyWith(
            color: AppColors.drawerTextMuted(context),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
