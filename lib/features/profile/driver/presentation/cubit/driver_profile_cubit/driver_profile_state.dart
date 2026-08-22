import 'package:equatable/equatable.dart';

import '../../../../../auth/data/models/driver_profile_model.dart';

enum DriverProfileStatus { init, loading, success, failed }

final class DriverProfileState extends Equatable {
  const DriverProfileState({
    this.status = DriverProfileStatus.init,
    this.acceptsFemaleOnly = false,
    this.updatedProfile,
    this.errorMessage = '',
  });

  final DriverProfileStatus status;
  final bool acceptsFemaleOnly;

  /// Latest server-returned profile after a successful update.
  final DriverProfileModel? updatedProfile;
  final String errorMessage;

  bool get isPending => status == DriverProfileStatus.loading;

  DriverProfileState copyWith({
    DriverProfileStatus? status,
    bool? acceptsFemaleOnly,
    DriverProfileModel? updatedProfile,
    String? errorMessage,
  }) {
    return DriverProfileState(
      status: status ?? this.status,
      acceptsFemaleOnly: acceptsFemaleOnly ?? this.acceptsFemaleOnly,
      updatedProfile: updatedProfile ?? this.updatedProfile,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, acceptsFemaleOnly, updatedProfile, errorMessage];
}
