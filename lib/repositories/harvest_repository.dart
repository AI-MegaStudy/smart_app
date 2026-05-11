import 'package:smart_app/core/api_service.dart';
import 'package:smart_app/model/harvest_models.dart';
import 'package:smart_app/model/product_record.dart';

class HarvestRepository {
  Future<List<MLPredictionRecord>> fetchPredictions() async {
    final data = await ApiService.get('/owner/ml/predictions');
    return _readList(data).map(MLPredictionRecord.fromJson).toList();
  }

  Future<MLPredictionRecord> createPrediction(
    ProductRecord product, {
    required double pastYieldKg,
    required int marketPrice,
    required String variety,
    required double marAvgTemp,
    required double augSunshine,
    required double octRainfall,
    required double augHumidity,
  }) async {
    final farmId = product.farmId;
    final productId = product.productId;
    if (farmId == null || productId == null) {
      throw ApiException('수확 예측에는 farm_id와 product_id가 있는 상품이 필요합니다.');
    }
    final data = await ApiService.post(
      '/owner/ml/predictions',
      body: {
        'farm_id': farmId,
        'product_id': productId,
        'features': {
          'past_yield_kg': pastYieldKg,
          'market_price': marketPrice,
          'variety': variety,
          'mar_avg_temp': marAvgTemp,
          'aug_sunshine': augSunshine,
          'oct_rainfall': octRainfall,
          'aug_humidity': augHumidity,
        },
      },
    );
    return MLPredictionRecord.fromJson(data);
  }

  Future<List<HarvestSlotRecord>> fetchSlots() async {
    final data = await ApiService.get('/owner/harvest-slots');
    return _readList(data).map(HarvestSlotRecord.fromJson).toList();
  }

  Future<HarvestSlotRecord> createDraftSlot({
    required ProductRecord product,
    required MLPredictionRecord prediction,
  }) async {
    final farmId = product.farmId;
    final productId = product.productId;
    if (farmId == null || productId == null) {
      throw ApiException('수확 슬롯 생성에는 farm_id와 product_id가 있는 상품이 필요합니다.');
    }
    final reservableKg = prediction.suggestedReservableMinKg;
    final data = await ApiService.post(
      '/owner/harvest-slots',
      body: {
        'farm_id': farmId,
        'product_id': productId,
        'prediction_id': prediction.predictionId,
        'confirmed_harvest_start': prediction.predictedHarvestStart,
        'confirmed_harvest_end': prediction.predictedHarvestEnd,
        'confirmed_reservable_kg': reservableKg,
        'confirmed_price': prediction.recommendedPrice,
        'customer_notice': 'ML 예측 기반 수확 슬롯 초안입니다.',
        'slot_status': 'DRAFT',
      },
    );
    return HarvestSlotRecord.fromJson(data);
  }

  Future<HarvestSlotRecord> updateSlot(HarvestSlotRecord slot) async {
    final data = await ApiService.put(
      '/owner/harvest-slots/${slot.slotId}',
      body: slot.toPayload(),
    );
    return HarvestSlotRecord.fromJson(data);
  }

  Future<HarvestSlotRecord> updateSlotStatus({
    required HarvestSlotRecord slot,
    required String status,
  }) async {
    final data = await ApiService.patch(
      '/owner/harvest-slots/${slot.slotId}/status',
      body: {'slot_status': status},
    );
    return HarvestSlotRecord.fromJson(data);
  }

  List<Map<String, dynamic>> _readList(Map<String, dynamic> data) {
    final rawItems = data['items'] ?? data['value'] ?? data;
    if (rawItems is List) {
      return rawItems.whereType<Map<String, dynamic>>().toList();
    }
    if (data.containsKey('slot_id') || data.containsKey('prediction_id')) {
      return [data];
    }
    return [];
  }
}
