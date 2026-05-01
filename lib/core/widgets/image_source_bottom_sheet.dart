import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../shared/widgets/app_option_sheet.dart';

/// Shows a styled bottom sheet to pick between [ImageSource.camera]
/// and [ImageSource.gallery]. All texts are optional and fall back to
/// sensible defaults. Returns null if dismissed.
Future<ImageSource?> showImageSourceSheet(
  BuildContext context, {
  String title = 'Upload photo',
  String cameraLabel = 'Camera',
  String? cameraSubtitle = 'Take a new photo',
  String galleryLabel = 'Gallery',
  String? gallerySubtitle = 'Pick from your library',
}) {
  return showAppOptionSheet<ImageSource>(
    context: context,
    title: title,
    options: [
      AppSheetOption(
        icon: Icons.camera_alt_rounded,
        label: cameraLabel,
        subtitle: cameraSubtitle,
        value: ImageSource.camera,
      ),
      AppSheetOption(
        icon: Icons.photo_library_rounded,
        label: galleryLabel,
        subtitle: gallerySubtitle,
        value: ImageSource.gallery,
      ),
    ],
  );
}
