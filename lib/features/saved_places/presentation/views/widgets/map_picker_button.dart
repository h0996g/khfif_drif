import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';

/// Square "pick on map" button placed beside the address field.
/// Highlights once a location has been selected.
class MapPickerButton extends StatelessWidget {
  const MapPickerButton({
    super.key,
    required this.onTap,
    this.hasLocation = false,
    this.size = 56,
  });

  final VoidCallback onTap;
  final bool hasLocation;

  /// Edge length of the square button, in dp (uses `.h` scaling internally).
  final double size;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Pick on map',
      child: Material(
        color: hasLocation ? AppColors.primary : AppColors.surface(context),
        borderRadius: BorderRadius.circular(10.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10.r),
          child: Container(
            width: size.h,
            height: size.h,
            alignment: Alignment.center,
            child: Icon(
              Icons.location_on_rounded,
              color: hasLocation
                  ? AppColors.white
                  : AppColors.textSecondary(context),
            ),
          ),
        ),
      ),
    );
  }
}
