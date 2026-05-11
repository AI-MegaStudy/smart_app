import 'package:smart_app/core/api_service.dart';
import 'package:smart_app/model/shipment_record.dart';

class ShipmentRepository {
  Future<List<ShipmentTargetRecord>> fetchShipmentTargets() async {
    final data = await ApiService.get('/owner/orders');
    final rawItems = data['items'] ?? data['value'] ?? data;
    if (rawItems is! List) return [];
    return rawItems
        .whereType<Map<String, dynamic>>()
        .map(ShipmentTargetRecord.fromOrderJson)
        .where((item) => item.canShip)
        .toList();
  }

  Future<ShipmentApiRecord> createShipment({
    required int orderId,
    required String carrierName,
    required String trackingNo,
    required int shippedPackageCount,
    required double shippedKg,
  }) async {
    final data = await ApiService.post(
      '/owner/shipments',
      body: {
        'order_id': orderId,
        'carrier_name': carrierName,
        'tracking_no': trackingNo,
        'shipped_package_count': shippedPackageCount,
        'shipped_kg': shippedKg,
      },
    );
    return ShipmentApiRecord.fromJson(data);
  }

  Future<ShipmentApiRecord> updateStatus({
    required int shipmentId,
    required String shipmentStatus,
  }) async {
    final data = await ApiService.patch(
      '/owner/shipments/$shipmentId/status',
      body: {'shipment_status': shipmentStatus},
    );
    return ShipmentApiRecord.fromJson(data);
  }
}
