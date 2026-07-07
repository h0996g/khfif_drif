import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../models/shared_ride_models.dart';

/// Colored pill surfacing whether a request is a Ride or a Delivery, so drivers
/// can tell the two apart at a glance without reading the addresses.
///
/// Defaults (`iconSize: 14`, `hPad: 8`, `vPad: 4`) match the available-rides
/// list density; pass tighter values for the compact floating overlay.
class ServiceTypeChip extends StatelessWidget {
  const ServiceTypeChip({
    super.key,
    required this.serviceType,
    this.iconSize = 14,
    this.hPad = 8,
    this.vPad = 4,
  });

  static const Color _deliveryColor = Color(0xFF3B82F6);

  final ServiceType serviceType;
  final double iconSize;
  final double hPad;
  final double vPad;

  @override
  Widget build(BuildContext context) {
    final color = serviceType == ServiceType.delivery
        ? _deliveryColor
        : AppColors.primary;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad.w, vertical: vPad.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(serviceType.icon, size: iconSize.w, color: color),
          SizedBox(width: 3.w),
          Text(
            serviceType.label,
            style: AppTextStyles.labelSmall(context).copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
