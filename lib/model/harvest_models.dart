class MLPredictionRecord {
  final int predictionId;
  final int farmId;
  final int productId;
  final String predictedHarvestStart;
  final String predictedHarvestEnd;
  final double unitYieldKg10a;
  final double estimatedYieldKg;
  final double suggestedReservableMinKg;
  final double suggestedReservableMaxKg;
  final int recommendedPrice;
  final double confidence;
  final double safetyFactor;
  final String warningMessage;
  final String? modelVersion;

  const MLPredictionRecord({
    required this.predictionId,
    required this.farmId,
    required this.productId,
    required this.predictedHarvestStart,
    required this.predictedHarvestEnd,
    required this.unitYieldKg10a,
    required this.estimatedYieldKg,
    required this.suggestedReservableMinKg,
    required this.suggestedReservableMaxKg,
    required this.recommendedPrice,
    required this.confidence,
    required this.safetyFactor,
    required this.warningMessage,
    this.modelVersion,
  });

  factory MLPredictionRecord.fromJson(Map<String, dynamic> json) {
    return MLPredictionRecord(
      predictionId: _readInt(json['prediction_id']),
      farmId: _readInt(json['farm_id']),
      productId: _readInt(json['product_id']),
      predictedHarvestStart: (json['predicted_harvest_start'] ?? '')
          .toString(),
      predictedHarvestEnd: (json['predicted_harvest_end'] ?? '').toString(),
      unitYieldKg10a: _readDouble(json['unit_yield_kg_10a']),
      estimatedYieldKg: _readDouble(json['estimated_yield_kg']),
      suggestedReservableMinKg: _readDouble(
        json['suggested_reservable_min_kg'],
      ),
      suggestedReservableMaxKg: _readDouble(
        json['suggested_reservable_max_kg'],
      ),
      recommendedPrice: _readInt(json['recommended_price']),
      confidence: _readDouble(json['confidence']),
      safetyFactor: _readDouble(json['safety_factor']),
      warningMessage: (json['warning_message'] ?? '').toString(),
      modelVersion: json['model_version']?.toString(),
    );
  }
}

class HarvestSlotRecord {
  final int slotId;
  final int farmId;
  final int productId;
  final String productName;
  final int? predictionId;
  final String confirmedHarvestStart;
  final String confirmedHarvestEnd;
  final double confirmedReservableKg;
  final double availableKg;
  final int confirmedPrice;
  final String customerNotice;
  final String slotStatus;

  const HarvestSlotRecord({
    required this.slotId,
    required this.farmId,
    required this.productId,
    required this.productName,
    this.predictionId,
    required this.confirmedHarvestStart,
    required this.confirmedHarvestEnd,
    required this.confirmedReservableKg,
    required this.availableKg,
    required this.confirmedPrice,
    required this.customerNotice,
    required this.slotStatus,
  });

  factory HarvestSlotRecord.fromJson(Map<String, dynamic> json) {
    return HarvestSlotRecord(
      slotId: _readInt(json['slot_id']),
      farmId: _readInt(json['farm_id']),
      productId: _readInt(json['product_id']),
      productName: (json['product_name'] ?? '').toString(),
      predictionId: _readNullableInt(json['prediction_id']),
      confirmedHarvestStart: (json['confirmed_harvest_start'] ?? '')
          .toString(),
      confirmedHarvestEnd: (json['confirmed_harvest_end'] ?? '').toString(),
      confirmedReservableKg: _readDouble(json['confirmed_reservable_kg']),
      availableKg: _readDouble(json['available_kg']),
      confirmedPrice: _readInt(json['confirmed_price']),
      customerNotice: (json['customer_notice'] ?? '').toString(),
      slotStatus: (json['slot_status'] ?? 'DRAFT').toString(),
    );
  }

  HarvestSlotRecord copyWith({
    String? confirmedHarvestStart,
    String? confirmedHarvestEnd,
    double? confirmedReservableKg,
    int? confirmedPrice,
    String? customerNotice,
    String? slotStatus,
  }) {
    return HarvestSlotRecord(
      slotId: slotId,
      farmId: farmId,
      productId: productId,
      productName: productName,
      predictionId: predictionId,
      confirmedHarvestStart:
          confirmedHarvestStart ?? this.confirmedHarvestStart,
      confirmedHarvestEnd: confirmedHarvestEnd ?? this.confirmedHarvestEnd,
      confirmedReservableKg:
          confirmedReservableKg ?? this.confirmedReservableKg,
      availableKg: availableKg,
      confirmedPrice: confirmedPrice ?? this.confirmedPrice,
      customerNotice: customerNotice ?? this.customerNotice,
      slotStatus: slotStatus ?? this.slotStatus,
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      'farm_id': farmId,
      'product_id': productId,
      'prediction_id': predictionId,
      'confirmed_harvest_start': confirmedHarvestStart,
      'confirmed_harvest_end': confirmedHarvestEnd,
      'confirmed_reservable_kg': confirmedReservableKg,
      'confirmed_price': confirmedPrice,
      'customer_notice': customerNotice,
      'slot_status': slotStatus,
    };
  }
}

int _readInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

int? _readNullableInt(dynamic value) {
  if (value == null) return null;
  return _readInt(value);
}

double _readDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}
