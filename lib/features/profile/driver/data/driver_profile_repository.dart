import '../../../auth/data/models/driver_profile_model.dart';
import '../../../../core/constants/driver_api_constants.dart';
import '../../../../core/network/dio_client.dart';
import 'models/driver_profile_models.dart';

final class DriverProfileRepository {
  const DriverProfileRepository();

  /// Updates editable profile fields and returns the full updated profile.
  Future<DriverProfileModel> updateProfile({
    required bool acceptsFemaleOnly,
  }) async {
    final response = await DioClient.put(
      path: DriverApiConstants.profile,
      data: DriverProfileUpdateRequest(
        acceptsFemaleOnly: acceptsFemaleOnly,
      ).toJson(),
    );
    return DriverProfileModel.fromJson(response.data as Map<String, dynamic>);
  }
}
