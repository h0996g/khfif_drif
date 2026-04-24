import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:khfif_drif/features/auth/presentation/views/widgets/mode/mode_card_widget.dart';

import '../../../../../../core/router/route_names.dart';
import '../../../../../../shared/widgets/primary_button.dart';

enum UserMode { passenger, driver }

class ModeSelectionOptionsSection extends StatefulWidget {
  const ModeSelectionOptionsSection({super.key});

  @override
  State<ModeSelectionOptionsSection> createState() =>
      _ModeSelectionOptionsSectionState();
}

class _ModeSelectionOptionsSectionState
    extends State<ModeSelectionOptionsSection> {
  UserMode? _selectedMode;

  void _handleContinue() {
    if (_selectedMode == UserMode.passenger) {
      context.push(RouteNames.passengerProfile);
    } else if (_selectedMode == UserMode.driver) {
      context.push(RouteNames.driverProfile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ModeCard(
          title: 'Passenger',
          description: 'Book rides and travel comfortably',
          icon: Icons.person_outline_rounded,
          isSelected: _selectedMode == UserMode.passenger,
          onTap: () => setState(() => _selectedMode = UserMode.passenger),
        ),
        SizedBox(height: 20.h),
        ModeCard(
          title: 'Driver',
          description: 'Drive, earn, and be your own boss',
          icon: Icons.directions_car_outlined,
          isSelected: _selectedMode == UserMode.driver,
          onTap: () => setState(() => _selectedMode = UserMode.driver),
        ),
        SizedBox(height: 24.h),
        PrimaryButton(
          label: 'Continue',
          isEnabled: _selectedMode != null,
          onPressed: _handleContinue,
        ),
      ],
    );
  }
}
