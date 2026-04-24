// lib/features/auth/presentation/views/mode_selection_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/app_scaffold.dart';
import 'widgets/mode/mode_selection_options_section.dart';

/// Step 3 & 4 — Mode Selection
///
/// Newly registered users choose their path here.
class ModeSelectionView extends StatelessWidget {
  const ModeSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 60.h),
              Text(
                'How would you like\nto use the app?',
                style: AppTextStyles.displayMedium(context),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              Text(
                'Choose your path to get started',
                style: AppTextStyles.bodyMedium(context),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 48.h),
              // const Spacer(),
              const ModeSelectionOptionsSection(),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
