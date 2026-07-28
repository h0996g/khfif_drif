import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../core/router/route_names.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../core/widgets/app_toast.dart';
import '../../../../../../features/ride/driver/presentation/cubit/driver_availability_cubit/driver_availability_cubit.dart';
import '../../../../../../features/ride/driver/presentation/cubit/driver_availability_cubit/driver_availability_state.dart';
import '../../../../../wallet/driver/presentation/cubit/wallet_cubit/wallet_cubit.dart';
import '../../../../../wallet/driver/presentation/cubit/wallet_cubit/wallet_state.dart';

/// Online/offline switch, gated by the wallet balance.
///
/// The gate is read proactively from `GET /wallet` (`belowGate`) so the switch
/// is already inert before the driver taps it, rather than only reacting to the
/// `403 INSUFFICIENT_WALLET_BALANCE`. Going **offline** is never blocked, and a
/// balance that drops mid-shift does not force the driver offline.
class DriverAvailabilityToggleWidget extends StatelessWidget {
  const DriverAvailabilityToggleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletCubit, WalletState>(
      buildWhen: (prev, curr) => prev.belowGate != curr.belowGate,
      builder: (context, walletState) {
        return BlocConsumer<DriverAvailabilityCubit, DriverAvailabilityState>(
          listenWhen: (prev, curr) =>
              prev.status != curr.status &&
              curr.status == DriverAvailabilityStatus.failed,
          listener: (context, state) {
            if (state.gatedByBalance) {
              // The cached gate was stale — refetch so the switch locks itself.
              context.read<WalletCubit>().refreshBalance();
              AppToast.error('Top up your wallet to go online.');
            } else if (state.errorMessage.isNotEmpty) {
              AppToast.error(state.errorMessage);
            }
          },
          builder: (context, state) {
            final isOnline = state.isOnline;
            final isLoading =
                state.status == DriverAvailabilityStatus.loading;
            // Only blocks going online — an already-online driver can always
            // switch off.
            final isGated = walletState.belowGate && !isOnline;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        isOnline ? 'Online' : 'Offline',
                        key: ValueKey(isOnline),
                        style: AppTextStyles.labelMedium(context).copyWith(
                          color: isOnline
                              ? AppColors.primary
                              : AppColors.textSecondary(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (isLoading)
                      SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    else
                      Switch(
                        value: isOnline,
                        onChanged: isGated
                            ? null
                            : (_) =>
                                context.read<DriverAvailabilityCubit>().toggle(),
                        activeThumbColor: AppColors.primary,
                        activeTrackColor:
                            AppColors.primary.withValues(alpha: 0.4),
                      ),
                  ],
                ),
                if (isGated) ...[
                  SizedBox(height: 6.h),
                  _TopUpHint(
                    onTap: () => context.go(RouteNames.driverWallet),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }
}

class _TopUpHint extends StatelessWidget {
  const _TopUpHint({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 14.w, color: AppColors.error),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              'Top up your wallet to go online',
              style: AppTextStyles.bodySmall(context).copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
