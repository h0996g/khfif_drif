final class DriverProfileUpdateRequest {
  const DriverProfileUpdateRequest({required this.acceptsFemaleOnly});

  final bool acceptsFemaleOnly;

  Map<String, dynamic> toJson() => {'acceptsFemaleOnly': acceptsFemaleOnly};
}
