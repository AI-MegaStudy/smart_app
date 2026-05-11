import 'package:smart_app/core/api_service.dart';
import 'package:smart_app/model/owner_profile_record.dart';

class OwnerProfileRepository {
  Future<OwnerProfileRecord> fetchProfile() async {
    final data = await ApiService.get('/owner/profile');
    return OwnerProfileRecord.fromJson(data);
  }

  Future<OwnerProfileRecord> updateProfile(OwnerProfileRecord profile) async {
    final data = await ApiService.put(
      '/owner/profile',
      body: profile.toPayload(),
    );
    return OwnerProfileRecord.fromJson(data);
  }
}
