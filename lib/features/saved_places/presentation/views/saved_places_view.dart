import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import '../../../home/passenger/presentation/views/widgets/top_bar.dart';
import '../cubit/saved_places_cubit.dart';
import '../cubit/saved_places_state.dart';
import 'widgets/address_card_widget.dart';

class SavedPlacesView extends StatelessWidget {
  const SavedPlacesView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(
        children: [
          TopBar(
            title: 'Saved Places',
            subtitle: null,
            leadingIcon: Icons.arrow_back_ios_new_rounded,
            trailingIcon: null,
            onLeadingTap: () => context.go(RouteNames.passengerHome),
          ),
          Expanded(
            child: BlocConsumer<SavedPlacesCubit, SavedPlacesState>(
              listenWhen: (prev, curr) =>
                  prev.deleteAddressStatus != curr.deleteAddressStatus,
              listener: (context, state) {
                if (state.deleteAddressStatus == DeleteAddressStatus.success) {
                  AppToast.success('Address deleted');
                } else if (state.deleteAddressStatus ==
                    DeleteAddressStatus.failure) {
                  AppToast.error(state.errorMessage);
                }
              },
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.getAddressesStatus == GetAddressesStatus.failure) {
                  return Center(
                    child: Text(
                      state.errorMessage,
                      style: AppTextStyles.bodyMedium(context),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return Column(
                  children: [
                    Expanded(
                      child: state.isEmpty
                          ? Center(
                              child: Text(
                                'No saved places yet',
                                style:
                                    AppTextStyles.bodyMedium(context).copyWith(
                                  color: AppColors.textSecondary(context),
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24.w, vertical: 16.h),
                              itemCount: state.addresses.length,
                              separatorBuilder: (_, __) =>
                                  SizedBox(height: 12.h),
                              itemBuilder: (context, index) =>
                                  AddressCardWidget(
                                      address: state.addresses[index]),
                            ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 24.w, vertical: 16.h),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48.h,
                        child: OutlinedButton.icon(
                          onPressed: () => context.push(RouteNames.addressForm),
                          icon: const Icon(Icons.add_location_alt_outlined),
                          label: const Text('Add New Place'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
