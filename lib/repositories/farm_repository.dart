import 'package:smart_app/core/api_service.dart';
import 'package:smart_app/model/farm_record.dart';

class FarmRepository {
  Future<List<FarmRecord>> fetchMyFarms() async {
    final data = await ApiService.get('/owner/farms/me');
    final rawItems = data['items'] ?? data['value'] ?? data;
    if (rawItems is List) {
      return rawItems
          .whereType<Map<String, dynamic>>()
          .map(FarmRecord.fromJson)
          .toList();
    }
    if (data.containsKey('farm_id')) {
      return [FarmRecord.fromJson(data)];
    }
    return [];
  }

  Future<FarmRecord> fetchPrimaryFarm() async {
    final farms = await fetchMyFarms();
    if (farms.isEmpty) {
      throw ApiException('등록된 점주 농장이 없습니다.');
    }
    return farms.first;
  }

  Future<FarmRecord> updateFarm(FarmRecord farm) async {
    final data = await ApiService.put(
      '/owner/farms/${farm.farmId}',
      body: farm.toPayload(),
    );
    return FarmRecord.fromJson(data);
  }
}
