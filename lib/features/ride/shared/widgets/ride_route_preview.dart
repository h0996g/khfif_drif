import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Pickup → dropoff route preview: a green origin dot, a thin vertical
/// connector, and a red destination pin, each next to its address line.
///
/// Takes plain [String]s (the lowest common denominator across cards — the
/// active-ride model exposes nested `CoordinatePoint`s but only `.address` is
/// shown). Defaults match the ride-history card; the available-rides card
/// passes its own `_CardMetrics` values.
class RideRoutePreview extends StatelessWidget {
  const RideRoutePreview({
    super.key,
    required this.pickup,
    required this.dropoff,
    this.iconSize = 16,
    this.spacing = 8,
    this.connectorHeight = 16,
    this.connectorInset = 5.5,
    this.iconTopPadding = 2,
    this.addressStyle,
  });

  final String pickup;
  final String dropoff;
  final double iconSize;
  final double spacing;
  final double connectorHeight;
  final double connectorInset;
  final double iconTopPadding;

  /// Defaults to [AppTextStyles.bodyMedium] when `null`.
  final TextStyle? addressStyle;

  @override
  Widget build(BuildContext context) {
    final style = addressStyle ?? AppTextStyles.bodyMedium(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LocationRow(
          icon: Icons.trip_origin_rounded,
          iconColor: AppColors.primary,
          address: pickup,
          iconSize: iconSize,
          spacing: spacing,
          iconTopPadding: iconTopPadding,
          style: style,
        ),
        Padding(
          padding: EdgeInsets.only(left: connectorInset.w),
          child: Container(
            width: 1.5.w,
            height: connectorHeight.h,
            color: AppColors.textSecondary(context).withValues(alpha: 0.3),
          ),
        ),
        _LocationRow(
          icon: Icons.location_on_rounded,
          iconColor: AppColors.error,
          address: dropoff,
          iconSize: iconSize,
          spacing: spacing,
          iconTopPadding: iconTopPadding,
          style: style,
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
    required this.iconSize,
    required this.spacing,
    required this.iconTopPadding,
    required this.style,
  });

  final IconData icon;
  final Color iconColor;
  final String address;
  final double iconSize;
  final double spacing;
  final double iconTopPadding;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: iconTopPadding.h),
          child: Icon(icon, size: iconSize.w, color: iconColor),
        ),
        SizedBox(width: spacing.w),
        Expanded(
          child: Text(
            address.isEmpty ? '—' : address,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: style,
          ),
        ),
      ],
    );
  }
}
