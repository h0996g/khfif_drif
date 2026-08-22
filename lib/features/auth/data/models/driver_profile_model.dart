import '../../../../../features/ride/shared/models/shared_ride_models.dart';
import 'kyc_status.dart';

class DriverProfileModel {
  const DriverProfileModel({
    required this.fullName,
    required this.gender,
    required this.phone,
    required this.kycStatus,
    required this.acceptsFemaleOnly,
    required this.isOnline,
    required this.activeServiceTypes,
    this.email,
  });

  final String fullName;
  final String gender;
  final String phone;
  final KycStatus kycStatus;
  final bool acceptsFemaleOnly;
  final bool isOnline;
  final Set<ServiceType> activeServiceTypes;
  final String? email;

  factory DriverProfileModel.fromJson(Map<String, dynamic> json) {
    // GET /api/me/profile nests driver fields under 'driver'; the driver
    // profile endpoints return them flat at the top level.
    final driver = json['driver'] as Map<String, dynamic>? ?? json;
    final rawTypes = driver['activeServiceTypes'] as List<dynamic>? ?? [];
    return DriverProfileModel(
      fullName: json['fullName'] as String? ?? '',
      gender: json['gender'] as String? ?? 'MALE',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String?,
      kycStatus: KycStatus.fromString(driver['kycStatus'] as String?),
      acceptsFemaleOnly: driver['acceptsFemaleOnly'] as bool? ?? false,
      isOnline: driver['isOnline'] as bool? ?? false,
      activeServiceTypes:
          rawTypes.map((e) => ServiceType.fromJson(e as String)).toSet(),
    );
  }

  DriverProfileModel copyWith({
    String? fullName,
    String? gender,
    String? phone,
    KycStatus? kycStatus,
    bool? acceptsFemaleOnly,
    bool? isOnline,
    Set<ServiceType>? activeServiceTypes,
    String? email,
  }) {
    return DriverProfileModel(
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      kycStatus: kycStatus ?? this.kycStatus,
      acceptsFemaleOnly: acceptsFemaleOnly ?? this.acceptsFemaleOnly,
      isOnline: isOnline ?? this.isOnline,
      activeServiceTypes: activeServiceTypes ?? this.activeServiceTypes,
      email: email ?? this.email,
    );
  }
}
