class FarmRecord {
  final int farmId;
  final String farmName;
  final String farmRegion;
  final String farmAddress;
  final String? farmImageUrl;
  final String? farmDescription;
  final String? deliveryPolicy;
  final String? returnPolicy;

  const FarmRecord({
    required this.farmId,
    required this.farmName,
    required this.farmRegion,
    required this.farmAddress,
    this.farmImageUrl,
    this.farmDescription,
    this.deliveryPolicy,
    this.returnPolicy,
  });

  factory FarmRecord.fromJson(Map<String, dynamic> json) {
    return FarmRecord(
      farmId: _readInt(json['farm_id']),
      farmName: (json['farm_name'] ?? '').toString(),
      farmRegion: (json['farm_region'] ?? '').toString(),
      farmAddress: (json['farm_address'] ?? '').toString(),
      farmImageUrl: json['farm_image_url']?.toString(),
      farmDescription: json['farm_description']?.toString(),
      deliveryPolicy: json['delivery_policy']?.toString(),
      returnPolicy: json['return_policy']?.toString(),
    );
  }

  FarmRecord copyWith({
    String? farmName,
    String? farmRegion,
    String? farmAddress,
    String? farmImageUrl,
    String? farmDescription,
    String? deliveryPolicy,
    String? returnPolicy,
  }) {
    return FarmRecord(
      farmId: farmId,
      farmName: farmName ?? this.farmName,
      farmRegion: farmRegion ?? this.farmRegion,
      farmAddress: farmAddress ?? this.farmAddress,
      farmImageUrl: farmImageUrl ?? this.farmImageUrl,
      farmDescription: farmDescription ?? this.farmDescription,
      deliveryPolicy: deliveryPolicy ?? this.deliveryPolicy,
      returnPolicy: returnPolicy ?? this.returnPolicy,
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      'farm_name': farmName,
      'farm_region': farmRegion,
      'farm_address': farmAddress,
      'farm_image_url': farmImageUrl,
      'farm_description': farmDescription,
      'delivery_policy': deliveryPolicy,
      'return_policy': returnPolicy,
    };
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
