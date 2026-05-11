import 'package:flutter/material.dart';
import 'package:smart_app/util/app_colors.dart';

class ProcurementRecord {
  final int procurementId;
  final String procurementNo;
  final String customerName;
  final String statusCode;
  final String statusLabel;
  final String requestedAt;
  final int totalAmount;
  final List<ProcurementItemRecord> items;

  const ProcurementRecord({
    required this.procurementId,
    required this.procurementNo,
    required this.customerName,
    required this.statusCode,
    required this.statusLabel,
    required this.requestedAt,
    required this.totalAmount,
    required this.items,
  });

  factory ProcurementRecord.fromJson(Map<String, dynamic> json) {
    final statusCode = (json['procurement_status'] ?? '').toString();
    final rawItems = json['items'];
    return ProcurementRecord(
      procurementId: _readInt(json['procurement_id']),
      procurementNo: (json['procurement_no'] ?? '').toString(),
      customerName: (json['customer_name'] ?? '고객').toString(),
      statusCode: statusCode,
      statusLabel: statusLabelOf(statusCode),
      requestedAt: (json['requested_at'] ?? '').toString(),
      totalAmount: _readInt(json['total_amount']),
      items: rawItems is List
          ? rawItems
                .whereType<Map<String, dynamic>>()
                .map(ProcurementItemRecord.fromJson)
                .toList()
          : const [],
    );
  }

  bool get canDecide => statusCode == 'REQUESTED';

  String get title {
    final productName = items.isEmpty ? '발주 품목' : items.first.productName;
    return '$customerName · $productName';
  }

  String get subtitle {
    final count = items.fold<int>(
      0,
      (sum, item) => sum + item.requestedPackageCount,
    );
    return '$procurementNo · ${count}박스 · ${_formatAmount(totalAmount)}원 · $requestedAt';
  }

  Color get color {
    return switch (statusCode) {
      'APPROVED' => AppColors.mint,
      'PARTIAL_APPROVED' => AppColors.yellow,
      'REJECTED' => const Color(0xffFFE1DD),
      _ => AppColors.blue,
    };
  }

  static String statusLabelOf(String statusCode) {
    return switch (statusCode) {
      'REQUESTED' => '승인 대기',
      'APPROVED' => '승인',
      'PARTIAL_APPROVED' => '부분 승인',
      'REJECTED' => '거절',
      _ => '발주',
    };
  }
}

class ProcurementItemRecord {
  final int procurementItemId;
  final String productName;
  final int requestedPackageCount;
  final double requestedKg;

  const ProcurementItemRecord({
    required this.procurementItemId,
    required this.productName,
    required this.requestedPackageCount,
    required this.requestedKg,
  });

  factory ProcurementItemRecord.fromJson(Map<String, dynamic> json) {
    return ProcurementItemRecord(
      procurementItemId: _readInt(json['procurement_item_id']),
      productName: (json['product_name'] ?? '상품').toString(),
      requestedPackageCount: _readInt(json['requested_package_count']),
      requestedKg: _readDouble(json['requested_kg']),
    );
  }

  Map<String, dynamic> toDecisionPayload({required bool approve}) {
    return {
      'procurement_item_id': procurementItemId,
      'approved_package_count': approve ? requestedPackageCount : 0,
      'approved_kg': approve ? requestedKg : 0,
      'owner_memo': approve ? '정상 수량 확인' : null,
    };
  }
}

int _readInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double _readDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

String _formatAmount(int value) {
  final text = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    if (i > 0 && (text.length - i) % 3 == 0) buffer.write(',');
    buffer.write(text[i]);
  }
  return buffer.toString();
}
