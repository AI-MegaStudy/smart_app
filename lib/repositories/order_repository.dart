import 'package:smart_app/core/api_service.dart';
import 'package:smart_app/model/owner_order_record.dart';

class OrderRepository {
  Future<List<OwnerOrderRecord>> fetchOwnerReservations() async {
    final data = await ApiService.get('/owner/reservations');
    return _readList(data).map(OwnerOrderRecord.fromReservationJson).toList();
  }

  Future<List<OwnerOrderRecord>> fetchOwnerOrders() async {
    final data = await ApiService.get('/owner/orders');
    return _readList(data).map(OwnerOrderRecord.fromOrderJson).toList();
  }

  Future<List<OwnerOrderRecord>> fetchOwnerOrderStatus() async {
    final reservations = await fetchOwnerReservations();
    final orders = await fetchOwnerOrders();
    return [...reservations, ...orders]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<Map<String, dynamic>> _readList(Map<String, dynamic> data) {
    final rawItems = data['items'] ?? data['value'] ?? data;
    if (rawItems is List) {
      return rawItems.whereType<Map<String, dynamic>>().toList();
    }
    if (data.containsKey('order_id') || data.containsKey('reservation_id')) {
      return [data];
    }
    return [];
  }
}
