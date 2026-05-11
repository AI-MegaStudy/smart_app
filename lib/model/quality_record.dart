import 'package:flutter/material.dart';
import 'package:smart_app/util/app_colors.dart';

class QualityInspectionRecord {
  final int? qualityInspectionId;
  final int procurementItemId;
  final String productName;
  final String? imageUrl;
  final String modelGrade;
  final double freshnessScore;
  final double colorScore;
  final double roundnessScore;
  final double bruiseProbability;
  final String modelDecision;
  final String? ownerConfirmedGrade;
  final String? ownerDecision;
  final String? inspectedAt;

  const QualityInspectionRecord({
    this.qualityInspectionId,
    required this.procurementItemId,
    required this.productName,
    this.imageUrl,
    required this.modelGrade,
    required this.freshnessScore,
    required this.colorScore,
    required this.roundnessScore,
    required this.bruiseProbability,
    required this.modelDecision,
    this.ownerConfirmedGrade,
    this.ownerDecision,
    this.inspectedAt,
  });

  factory QualityInspectionRecord.fromJson(Map<String, dynamic> json) {
    return QualityInspectionRecord(
      qualityInspectionId: _readNullableInt(json['quality_inspection_id']),
      procurementItemId: _readInt(json['procurement_item_id']),
      productName: (json['product_name'] ?? '검사 상품').toString(),
      imageUrl: json['image_url']?.toString(),
      modelGrade: (json['model_grade'] ?? '-').toString(),
      freshnessScore: _readDouble(json['freshness_score']),
      colorScore: _readDouble(json['color_score']),
      roundnessScore: _readDouble(json['roundness_score']),
      bruiseProbability: _readDouble(json['bruise_probability']),
      modelDecision: (json['model_decision'] ?? 'REVIEW').toString(),
      ownerConfirmedGrade: json['owner_confirmed_grade']?.toString(),
      ownerDecision: json['owner_decision']?.toString(),
      inspectedAt: json['inspected_at']?.toString(),
    );
  }

  String get decisionLabel {
    return switch (modelDecision) {
      'PASS' => '통과',
      'HOLD' => '보류',
      _ => '검토',
    };
  }

  Color get decisionColor {
    return switch (modelDecision) {
      'PASS' => AppColors.mint,
      'HOLD' => const Color(0xffFFE1DD),
      _ => AppColors.yellow,
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
