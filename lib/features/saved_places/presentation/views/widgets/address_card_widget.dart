import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/router/route_names.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../shared/widgets/app_confirm_dialog.dart';
import '../../../../saved_places/data/address_model.dart';
import '../../../../saved_places/presentation/cubit/saved_places_cubit.dart';
import '../../../../saved_places/presentation/cubit/saved_places_state.dart';
import 'address_type_icon_widget.dart';

class AddressCardWidget extends StatelessWidget {
  const AddressCardWidget({super.key, required this.address});

  final AddressModel address;

  void _confirmDelete(BuildContext context) async {
    final cubit = context.read<SavedPlacesCubit>();
    await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => BlocConsumer<SavedPlacesCubit, SavedPlacesState>(
        bloc: cubit,
        listener: (context, state) {
          if (state.deleteAddressStatus == DeleteAddressStatus.success) {
            Navigator.of(context).pop(true);
          }
        },
        builder: (context, state) {
          final isLoading =
              state.deleteAddressStatus == DeleteAddressStatus.loading;

          return AppConfirmDialog(
            title: 'Delete Address',
            message: 'Are you sure you want to delete "${address.label}"?',
            confirmLabel: 'Delete',
            isDestructive: true,
            isLoading: isLoading,
            onConfirm: () => cubit.deleteAddress(address.id!),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(RouteNames.addressEdit, extra: address),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(16.r),
          border:
              Border.all(color: AppColors.borderDefault(context), width: 1.w),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 16.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Row(
          children: [
            AddressTypeIconWidget(type: address.type),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    address.label,
                    style: AppTextStyles.bodyLarge(context).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    address.address,
                    style: AppTextStyles.bodySmall(context).copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, size: 20.w),
              color: AppColors.textSecondary(context),
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ),
      ),
    );
  }
}
