import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/passenger_ride_models.dart';

class RideSummaryCard extends StatelessWidget {
  const RideSummaryCard({super.key, required this.args});

  final WaitingOffersArgs args;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (args.pickup != null)
            _LocationRow(
              icon: Icons.trip_origin_rounded,
              iconColor: AppColors.primary,
              address: args.pickup!.address,
            )
          else
            const _NoLocationRow(
              icon: Icons.trip_origin_rounded,
              iconColor: AppColors.primary,
            ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.only(left: 8.w),
            child: SizedBox(
              height: 14.h,
              child: VerticalDivider(
                color: AppColors.borderDefault(context),
                thickness: 1.5,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          if (args.dropoff != null)
            _LocationRow(
              icon: Icons.location_on_rounded,
              iconColor: const Color(0xFFEF4444),
              address: args.dropoff!.address,
            )
          else
            const _NoLocationRow(
              icon: Icons.location_on_rounded,
              iconColor: Color(0xFFEF4444),
            ),
          SizedBox(height: 14.h),
          Divider(color: AppColors.borderDefault(context), height: 1),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(Icons.attach_money_rounded,
                  size: 16.w, color: AppColors.textSecondary(context)),
              SizedBox(width: 4.w),
              Text(
                'Proposed fare: ',
                style: AppTextStyles.bodySmall(context).copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
              Text(
                '${args.proposedFare} DZD',
                style: AppTextStyles.bodySmall(context).copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NoLocationRow extends StatelessWidget {
  const _NoLocationRow({required this.icon, required this.iconColor});

  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16.w, color: iconColor.withValues(alpha: 0.4)),
        SizedBox(width: 8.w),
        Text(
          '—',
          style: AppTextStyles.bodySmall(context).copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    );
  }
}

class _LocationRow extends StatelessWidget {
  const _LocationRow({
    required this.icon,
    required this.iconColor,
    required this.address,
  });

  final IconData icon;
  final Color iconColor;
  final String address;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16.w, color: iconColor),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            address,
            style: AppTextStyles.bodySmall(context),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
