import 'package:flutter/material.dart';
import 'package:smart_app/util/app_colors.dart';

class ShipmentTargetRecord {
  final int orderId;
  final String customerName;
  final String productName;
  final int packageCount;
  final double orderedKg;
  final String orderStatus;
  final String? shipmentStatus;

  const ShipmentTargetRecord({
    required this.orderId,
    required this.customerName,
    required this.productName,
    required this.packageCount,
    required this.orderedKg,
    required this.orderStatus,
    this.shipmentStatus,
  });

  factory ShipmentTargetRecord.fromOrderJson(Map<String, dynamic> json) {
    final rawItems = json['order_items'];
    final items = rawItems is List
        ? rawItems.whereType<Map<String, dynamic>>().toList()
        : const <Map<String, dynamic>>[];
    final first = items.isEmpty ? const <String, dynamic>{} : items.first;
    return ShipmentTargetRecord(
      orderId: _readInt(json['order_id']),
      customerName: (json['customer_name'] ?? json['receiver_name'] ?? '고객')
          .toString(),
      productName: (first['product_name'] ?? '주문 상품').toString(),
      packageCount: _readInt(first['package_count']),
      orderedKg: _readDouble(first['ordered_kg']),
      orderStatus: (json['order_status'] ?? '').toString(),
      shipmentStatus: json['shipment_status']?.toString(),
    );
  }

  bool get canShip =>
      shipmentStatus == null &&
      (orderStatus == 'PROCUREMENT_APPROVED' ||
          orderStatus == 'PROCUREMENT_PARTIAL_APPROVED' ||
          orderStatus == 'READY_TO_SHIP');

  String get label => '$customerName · $productName · ${packageCount}박스';
}

class ShipmentApiRecord {
  final int shipmentId;
  final int orderId;
  final String carrierName;
  final String trackingNo;
  final int shippedPackageCount;
  final double shippedKg;
  final String shipmentStatus;

  const ShipmentApiRecord({
    required this.shipmentId,
    required this.orderId,
    required this.carrierName,
    required this.trackingNo,
    required this.shippedPackageCount,
    required this.shippedKg,
    required this.shipmentStatus,
  });

  factory ShipmentApiRecord.fromJson(Map<String, dynamic> json) {
    return ShipmentApiRecord(
      shipmentId: _readInt(json['shipment_id']),
      orderId: _readInt(json['order_id']),
      carrierName: (json['carrier_name'] ?? '').toString(),
      trackingNo: (json['tracking_no'] ?? '').toString(),
      shippedPackageCount: _readInt(json['shipped_package_count']),
      shippedKg: _readDouble(json['shipped_kg']),
      shipmentStatus: (json['shipment_status'] ?? 'SHIPPED').toString(),
    );
  }

  String get statusLabel {
    return switch (shipmentStatus) {
      'READY' => '배송 대기',
      'DELIVERED' => '배송 완료',
      _ => '배송 중',
    };
  }

  Color get color {
    return switch (shipmentStatus) {
      'READY' => AppColors.yellow,
      'DELIVERED' => AppColors.blue,
      _ => AppColors.mint,
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
