// lib/features/auth/domain/models/vehicle_color_option.dart

import 'package:flutter/material.dart';

/// A predefined vehicle color: a display [name] (submitted to the backend as a
/// string) and its [value] swatch for the picker UI.
class VehicleColorOption {
  const VehicleColorOption({required this.name, required this.value});

  final String name;
  final Color value;

  static const List<VehicleColorOption> all = [
    VehicleColorOption(name: 'Black', value: Color(0xFF1A1A1A)),
    VehicleColorOption(name: 'White', value: Color(0xFFFFFFFF)),
    VehicleColorOption(name: 'Gray', value: Color(0xFF9E9E9E)),
    VehicleColorOption(name: 'Silver', value: Color(0xFFC0C4CC)),
    VehicleColorOption(name: 'Red', value: Color(0xFFE53935)),
    VehicleColorOption(name: 'Blue', value: Color(0xFF1E88E5)),
    VehicleColorOption(name: 'Green', value: Color(0xFF43A047)),
    VehicleColorOption(name: 'Yellow', value: Color(0xFFFDD835)),
    VehicleColorOption(name: 'Orange', value: Color(0xFFFB8C00)),
    VehicleColorOption(name: 'Brown', value: Color(0xFF6D4C41)),
    VehicleColorOption(name: 'Purple', value: Color(0xFF8E24AA)),
    VehicleColorOption(name: 'Beige', value: Color(0xFFD7CFC4)),
  ];
}
