import 'package:flutter/material.dart';
import 'package:smart_app/util/app_colors.dart';

class ReturnRequestRecord {
  final int returnRequestId;
  final int orderId;
  final String customerName;
  final String productName;
  final String reasonCode;
  final String reasonDetail;
  final String returnStatus;
  final int requestedAmount;
  final int approvedAmount;
  final String requestedAt;
  final int photoCount;

  const ReturnRequestRecord({
    required this.returnRequestId,
    required this.orderId,
    required this.customerName,
    required this.productName,
    required this.reasonCode,
    required this.reasonDetail,
    required this.returnStatus,
    required this.requestedAmount,
    required this.approvedAmount,
    required this.requestedAt,
    required this.photoCount,
  });

  factory ReturnRequestRecord.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = rawItems is List
        ? rawItems.whereType<Map<String, dynamic>>().toList()
        : const <Map<String, dynamic>>[];
    final first = items.isEmpty ? const <String, dynamic>{} : items.first;
    return ReturnRequestRecord(
      returnRequestId: _readInt(json['return_request_id']),
      orderId: _readInt(json['order_id']),
      customerName: (json['customer_name'] ?? '고객').toString(),
      productName: (first['product_name'] ?? '반품 상품').toString(),
      reasonCode: (json['reason_code'] ?? '').toString(),
      reasonDetail: (json['reason_detail'] ?? '').toString(),
      returnStatus: (json['return_status'] ?? 'REQUESTED').toString(),
      requestedAmount: _readInt(json['requested_amount']),
      approvedAmount: _readInt(json['approved_amount']),
      requestedAt: (json['requested_at'] ?? '').toString(),
      photoCount: json['evidence_image_url'] == null ? 0 : 1,
    );
  }

  bool get canDecide => returnStatus == 'REQUESTED';

  String get statusLabel {
    return switch (returnStatus) {
      'APPROVED' || 'REFUNDED' => '승인',
      'REJECTED' => '거절',
      _ => '접수',
    };
  }

  Color get color {
    return switch (returnStatus) {
      'APPROVED' || 'REFUNDED' => AppColors.mint,
      'REJECTED' => AppColors.yellow,
      _ => const Color(0xffFFE1DD),
    };
  }

  String get title => '$customerName · ${reasonLabel(reasonCode)}';

  String get subtitle => '$productName · $requestedAt';

  static String reasonLabel(String reasonCode) {
    return switch (reasonCode) {
      'QUALITY_ISSUE' => '상품 품질 문제',
      'DELIVERY_DAMAGE' => '배송 파손',
      'WRONG_ITEM' => '오배송',
      _ => reasonCode.isEmpty ? '반품 요청' : reasonCode,
    };
  }
}

int _readInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
