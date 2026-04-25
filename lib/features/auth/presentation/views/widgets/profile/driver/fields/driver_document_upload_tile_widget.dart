// lib/features/driver/presentation/views/widgets/fields/driver_document_upload_tile_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../../core/theme/app_text_styles.dart';
import '../../../../../../data/models/driver_document.dart';

/// A single document upload row showing idle / uploading / uploaded / error
/// states with animated border transitions.
class DriverDocumentUploadTileWidget extends StatelessWidget {
  const DriverDocumentUploadTileWidget({
    super.key,
    required this.label,
    required this.document,
    required this.onTap,
    required this.enabled,
  });

  final String label;
  final DriverDocument document;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final status = document.status;

    Color borderColor;
    switch (status) {
      case UploadStatus.idle:
        borderColor = AppColors.borderDefault(context);
      case UploadStatus.uploading:
        borderColor = AppColors.primary.withValues(alpha: 0.5);
      case UploadStatus.uploaded:
        borderColor = AppColors.primary;
      case UploadStatus.error:
        borderColor = AppColors.error;
    }

    return GestureDetector(
      onTap: enabled && status != UploadStatus.uploading ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 64.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: borderColor, width: 1.5.w),
        ),
        child: Row(
          children: [
            // ── Left icon ─────────────────────────────────────────────────
            _buildLeadingIcon(context, status),
            SizedBox(width: 12.w),

            // ── Label + sub-text ──────────────────────────────────────────
            Expanded(child: _buildBody(context, status)),

            // ── Right indicator ───────────────────────────────────────────
            _buildTrailing(context, status),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(BuildContext context, UploadStatus status) {
    switch (status) {
      case UploadStatus.idle:
      case UploadStatus.uploading:
        return Icon(
          Icons.upload_file_rounded,
          size: 22.w,
          color: AppColors.textSecondary(context),
        );
      case UploadStatus.uploaded:
        return Icon(
          Icons.insert_drive_file_outlined,
          size: 22.w,
          color: AppColors.primary,
        );
      case UploadStatus.error:
        return Icon(
          Icons.error_outline_rounded,
          size: 22.w,
          color: AppColors.error,
        );
    }
  }

  Widget _buildBody(BuildContext context, UploadStatus status) {
    switch (status) {
      case UploadStatus.idle:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.labelMedium(context)),
            SizedBox(height: 2.h),
            Text(
              'Tap to upload',
              style: AppTextStyles.labelSmall(context).copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        );
      case UploadStatus.uploading:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.labelMedium(context)),
            SizedBox(height: 2.h),
            Text(
              'Uploading...',
              style: AppTextStyles.labelSmall(context).copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        );
      case UploadStatus.uploaded:
        final name = document.fileName ?? '';
        final displayName =
            name.length > 28 ? '${name.substring(0, 25)}...' : name;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.labelMedium(context)),
            SizedBox(height: 2.h),
            Text(
              displayName,
              style: AppTextStyles.labelSmall(context).copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ],
        );
      case UploadStatus.error:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.labelMedium(context)),
            SizedBox(height: 2.h),
            Text(
              document.errorMessage.isNotEmpty
                  ? document.errorMessage
                  : 'Upload failed. Tap to retry.',
              style: AppTextStyles.labelSmall(context).copyWith(
                color: AppColors.error,
              ),
            ),
          ],
        );
    }
  }

  Widget _buildTrailing(BuildContext context, UploadStatus status) {
    switch (status) {
      case UploadStatus.idle:
        return Icon(
          Icons.chevron_right_rounded,
          size: 20.w,
          color: AppColors.textSecondary(context),
        );
      case UploadStatus.uploading:
        return SizedBox(
          width: 18.w,
          height: 18.w,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        );
      case UploadStatus.uploaded:
        return Icon(
          Icons.check_circle_rounded,
          size: 22.w,
          color: AppColors.primary,
        );
      case UploadStatus.error:
        return Icon(
          Icons.refresh_rounded,
          size: 20.w,
          color: AppColors.error,
        );
    }
  }
}
