import 'package:flutter/material.dart';
import 'package:smart_app/util/app_colors.dart';

class ProductRecord {
  final int? productId;
  final int? farmId;
  final String name;
  final String fruitType;
  final String variety;
  final String packageUnit;
  final double packageUnitKg;
  final int price;
  final int stockKg;
  final String status;
  final String statusCode;
  final Color color;
  final String? imageUrl;
  final String? description;

  const ProductRecord(
    this.name,
    this.packageUnit,
    this.price,
    this.stockKg,
    this.status,
    this.color, {
    this.productId,
    this.farmId,
    String? fruitType,
    String? variety,
    double? packageUnitKg,
    String? statusCode,
    this.imageUrl,
    this.description,
  }) : fruitType = fruitType ?? 'apple',
       variety = variety ?? name,
       packageUnitKg = packageUnitKg ?? 0,
       statusCode = statusCode ?? 'ACTIVE';

  factory ProductRecord.fromJson(Map<String, dynamic> json) {
    final statusCode = (json['product_status'] ?? 'ACTIVE').toString();
    final packageKg = _readDouble(json['package_unit_kg']);
    final name = (json['product_name'] ?? json['variety'] ?? '').toString();
    return ProductRecord(
      name,
      '${_formatKg(packageKg)}kg 박스',
      _readInt(json['base_price']),
      _readInt(json['open_slot_count']),
      statusLabel(statusCode),
      statusColor(statusCode),
      productId: _readNullableInt(json['product_id']),
      farmId: _readNullableInt(json['farm_id']),
      fruitType: (json['fruit_type'] ?? 'apple').toString(),
      variety: (json['variety'] ?? name).toString(),
      packageUnitKg: packageKg,
      statusCode: statusCode,
      imageUrl: json['image_url']?.toString(),
      description: json['product_description']?.toString(),
    );
  }

  ProductRecord copyWith({
    int? productId,
    int? farmId,
    String? name,
    String? fruitType,
    String? variety,
    String? packageUnit,
    double? packageUnitKg,
    int? price,
    int? stockKg,
    String? status,
    String? statusCode,
    Color? color,
    String? imageUrl,
    String? description,
  }) {
    final nextStatusCode = statusCode ?? this.statusCode;
    return ProductRecord(
      name ?? this.name,
      packageUnit ?? this.packageUnit,
      price ?? this.price,
      stockKg ?? this.stockKg,
      status ?? statusLabel(nextStatusCode),
      color ?? statusColor(nextStatusCode),
      productId: productId ?? this.productId,
      farmId: farmId ?? this.farmId,
      fruitType: fruitType ?? this.fruitType,
      variety: variety ?? this.variety,
      packageUnitKg: packageUnitKg ?? this.packageUnitKg,
      statusCode: nextStatusCode,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toPayload({required int fallbackFarmId}) {
    return {
      'farm_id': farmId ?? fallbackFarmId,
      'product_name': name,
      'fruit_type': fruitType,
      'variety': variety.isEmpty ? name : variety,
      'package_unit_kg': packageUnitKg > 0
          ? packageUnitKg
          : _readDouble(packageUnit),
      'base_price': price,
      'image_url': imageUrl,
      'product_description': description,
      'product_status': statusCode,
    };
  }

  String get priceLabel {
    final text = price.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      if (i > 0 && (text.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(text[i]);
    }
    return '$buffer원';
  }

  static String statusLabel(String statusCode) {
    return switch (statusCode) {
      'ACTIVE' => '판매 중',
      'HIDDEN' => '준비 중',
      'SOLD_OUT' => '판매 중지',
      _ => '준비 중',
    };
  }

  static String statusCodeFromLabel(String label) {
    return switch (label) {
      '판매 중' => 'ACTIVE',
      '준비 중' => 'HIDDEN',
      '판매 중지' => 'SOLD_OUT',
      _ => 'HIDDEN',
    };
  }

  static Color statusColor(String statusCode) {
    return switch (statusCode) {
      'ACTIVE' => AppColors.mint,
      'HIDDEN' => AppColors.yellow,
      _ => const Color(0xffFFE1DD),
    };
  }

  static int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static int? _readNullableInt(dynamic value) {
    if (value == null) return null;
    return _readInt(value);
  }

  static double _readDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    }
    return 0;
  }

  static String _formatKg(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toString();
  }
}
