import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../saved_places/data/address_model.dart';

String addressTypeAssetPath(AddressType type) => switch (type) {
      AddressType.home => 'assets/icons/saved_places/maison.png',
      AddressType.work => 'assets/icons/saved_places/work-tools.png',
      AddressType.other =>
        'assets/icons/saved_places/emplacement-sur-la-carte.png',
    };

class AddressTypeIconWidget extends StatelessWidget {
  const AddressTypeIconWidget({super.key, required this.type, this.size});

  final AddressType type;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final boxSize = size ?? 46.w;
    return Container(
      width: boxSize,
      height: boxSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.background(context),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.borderDefault(context), width: 1.w),
      ),
      child: Image.asset(
        addressTypeAssetPath(type),
        width: boxSize * 0.56,
        height: boxSize * 0.56,
      ),
    );
  }
}
