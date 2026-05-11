import 'package:flutter/material.dart';
import 'package:smart_app/util/app_colors.dart';

class OwnerOrderRecord {
  final String id;
  final String source;
  final String customerName;
  final String productName;
  final String statusCode;
  final String statusLabel;
  final int totalAmount;
  final String createdAt;
  final String summary;
  final Color color;

  const OwnerOrderRecord({
    required this.id,
    required this.source,
    required this.customerName,
    required this.productName,
    required this.statusCode,
    required this.statusLabel,
    required this.totalAmount,
    required this.createdAt,
    required this.summary,
    required this.color,
  });

  factory OwnerOrderRecord.fromOrderJson(Map<String, dynamic> json) {
    final items = _readItems(json['order_items']);
    final first = items.isEmpty ? const <String, dynamic>{} : items.first;
    final statusCode = (json['order_status'] ?? '').toString();
    final amount = _readInt(json['total_amount']);
    return OwnerOrderRecord(
      id: 'order-${json['order_id']}',
      source: 'order',
      customerName: (json['customer_name'] ?? json['receiver_name'] ?? '고객')
          .toString(),
      productName: (first['product_name'] ?? '주문 상품').toString(),
      statusCode: statusCode,
      statusLabel: orderStatusLabel(statusCode),
      totalAmount: amount,
      createdAt: (json['ordered_at'] ?? '').toString(),
      summary:
          '${_readInt(first['package_count'])}박스 · ${_formatAmount(amount)}원',
      color: statusColor(statusCode),
    );
  }

  factory OwnerOrderRecord.fromReservationJson(Map<String, dynamic> json) {
    final items = _readItems(json['items']);
    final first = items.isEmpty ? const <String, dynamic>{} : items.first;
    final statusCode = (json['reservation_status'] ?? '').toString();
    final amount = _readInt(json['total_amount']);
    return OwnerOrderRecord(
      id: 'reservation-${json['reservation_id']}',
      source: 'reservation',
      customerName: (json['customer_name'] ?? '고객').toString(),
      productName: (first['product_name'] ?? '예약 상품').toString(),
      statusCode: statusCode,
      statusLabel: reservationStatusLabel(statusCode),
      totalAmount: amount,
      createdAt: (json['reserved_until'] ?? '').toString(),
      summary:
          '${_readInt(first['package_count'])}박스 · ${_formatAmount(amount)}원',
      color: statusColor(statusCode),
    );
  }

  String get title => '$customerName · $productName';

  String get subtitle => '$summary · $createdAt';

  static String orderStatusLabel(String statusCode) {
    return switch (statusCode) {
      'PAYMENT_PENDING' => '결제 대기',
      'PAID' => '결제 완료',
      'PROCUREMENT_REQUESTED' => '발주 요청',
      'PROCUREMENT_APPROVED' => '발주 승인',
      'PROCUREMENT_PARTIAL_APPROVED' => '부분 승인',
      'PROCUREMENT_REJECTED' => '발주 거절',
      'QUALITY_CHECKING' => '선별 중',
      'READY_TO_SHIP' => '배송 준비',
      'SHIPPED' => '배송 중',
      'DELIVERED' => '배송 완료',
      'RETURN_REQUESTED' => '반품 요청',
      'REFUNDED' => '환불 완료',
      'CANCELED' => '취소',
      _ => '주문',
    };
  }

  static String reservationStatusLabel(String statusCode) {
    return switch (statusCode) {
      'RESERVED' => '예약 완료',
      'ORDERED' => '주문 전환',
      'EXPIRED' => '예약 만료',
      'CANCELED' => '예약 취소',
      _ => '예약',
    };
  }

  static Color statusColor(String statusCode) {
    return switch (statusCode) {
      'PAID' || 'RESERVED' || 'DELIVERED' => AppColors.blue,
      'READY_TO_SHIP' || 'SHIPPED' || 'ORDERED' => AppColors.mint,
      'CANCELED' || 'EXPIRED' || 'PROCUREMENT_REJECTED' => const Color(
        0xffFFE1DD,
      ),
      _ => AppColors.yellow,
    };
  }
}

List<Map<String, dynamic>> _readItems(dynamic value) {
  if (value is List) {
    return value.whereType<Map<String, dynamic>>().toList();
  }
  return const [];
}

int _readInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
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
