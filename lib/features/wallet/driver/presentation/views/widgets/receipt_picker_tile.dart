import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path/path.dart' as p;

import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_text_styles.dart';

/// Attach-a-receipt tile: empty prompt before a pick, thumbnail + name after.
///
/// The receipt is mandatory server-side, which is why this is a first-class
/// tile rather than an optional afterthought on the form.
class ReceiptPickerTile extends StatelessWidget {
  const ReceiptPickerTile({
    super.key,
    required this.path,
    required this.name,
    required this.onPick,
    required this.onClear,
    this.error = '',
  });

  final String path;
  final String name;
  final VoidCallback onPick;
  final VoidCallback onClear;
  final String error;

  bool get _hasReceipt => path.isNotEmpty;
  bool get _isPdf => p.extension(path).toLowerCase() == '.pdf';

  @override
  Widget build(BuildContext context) {
    final borderColor = error.isNotEmpty
        ? AppColors.error
        : (_hasReceipt ? AppColors.primary : AppColors.borderDefault(context));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onPick,
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.surface(context),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: borderColor, width: 1.w),
            ),
            child: Row(
              children: [
                _Thumbnail(path: path, isPdf: _isPdf, hasReceipt: _hasReceipt),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _hasReceipt ? name : 'Attach receipt',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.labelMedium(context)
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        _hasReceipt
                            ? 'Tap to replace'
                            : 'JPG, PNG or PDF · up to 5 MB',
                        style: AppTextStyles.bodySmall(context)
                            .copyWith(color: AppColors.textSecondary(context)),
                      ),
                    ],
                  ),
                ),
                if (_hasReceipt)
                  IconButton(
                    onPressed: onClear,
                    icon: Icon(Icons.close_rounded,
                        size: 20.w, color: AppColors.textSecondary(context)),
                  )
                else
                  Icon(Icons.add_rounded,
                      size: 22.w, color: AppColors.primary),
              ],
            ),
          ),
        ),
        if (error.isNotEmpty) ...[
          SizedBox(height: 6.h),
          Text(
            error,
            style: AppTextStyles.inputError(context),
          ),
        ],
      ],
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.path,
    required this.isPdf,
    required this.hasReceipt,
  });

  final String path;
  final bool isPdf;
  final bool hasReceipt;

  @override
  Widget build(BuildContext context) {
    final size = 48.w;
    final placeholder = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Icon(
        isPdf ? Icons.picture_as_pdf_rounded : Icons.receipt_long_rounded,
        size: 22.w,
        color: AppColors.primary,
      ),
    );

    if (!hasReceipt || isPdf) return placeholder;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10.r),
      child: Image.file(
        File(path),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => placeholder,
      ),
    );
  }
}
