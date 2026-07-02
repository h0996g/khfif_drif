// lib/features/auth/presentation/views/widgets/profile/driver/fields/driver_category_dropdown_widget.dart

import 'package:flutter/material.dart';

import '../../../../../../../../shared/widgets/bottomsheets/app_option_sheet.dart';
import '../../../../../../../../shared/widgets/app_text_field.dart';
import '../../../../../cubit/driver_profile_cubit/driver_profile_state.dart';

class DriverCategoryDropdownWidget extends StatefulWidget {
  const DriverCategoryDropdownWidget({
    super.key,
    required this.selectedCategory,
    required this.onChanged,
    required this.enabled,
  });

  final VehicleCategory? selectedCategory;
  final ValueChanged<VehicleCategory> onChanged;
  final bool enabled;

  @override
  State<DriverCategoryDropdownWidget> createState() =>
      _DriverCategoryDropdownWidgetState();
}

class _DriverCategoryDropdownWidgetState
    extends State<DriverCategoryDropdownWidget> {
  late final TextEditingController _controller;

  static const _options = VehicleCategory.values;
  static const _labels = {
    VehicleCategory.car: 'Car',
    VehicleCategory.motorcycle: 'Motorcycle',
    VehicleCategory.van: 'Van',
  };

  static const _icons = {
    VehicleCategory.car: Icons.directions_car_rounded,
    VehicleCategory.motorcycle: Icons.two_wheeler_rounded,
    VehicleCategory.van: Icons.airport_shuttle_rounded,
  };

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _getText());
  }

  @override
  void didUpdateWidget(covariant DriverCategoryDropdownWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCategory != oldWidget.selectedCategory) {
      _controller.text = _getText();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getText() {
    if (widget.selectedCategory == null) return '';
    return _labels[widget.selectedCategory!] ?? '';
  }

  void _openSheet() async {
    final selected = await showAppOptionSheet<VehicleCategory>(
      context: context,
      title: 'Select Vehicle Type',
      options: [
        for (final cat in _options)
          AppSheetOption(
            icon: _icons[cat]!,
            label: _labels[cat]!,
            value: cat,
          ),
      ],
    );
    if (selected != null) widget.onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: _controller,
      readOnly: true,
      onTap: widget.enabled ? _openSheet : null,
      enabled: widget.enabled,
      hintText: 'Select type',
      prefixIcon: const Icon(Icons.directions_car_outlined),
      suffixIcon: const Icon(Icons.expand_more_rounded),
    );
  }
}
