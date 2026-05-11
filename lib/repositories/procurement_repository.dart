import 'package:smart_app/core/api_service.dart';
import 'package:smart_app/model/procurement_record.dart';

class ProcurementRepository {
  Future<List<ProcurementRecord>> fetchProcurements() async {
    final data = await ApiService.get('/owner/procurements');
    return _readList(data).map(ProcurementRecord.fromJson).toList();
  }

  Future<ProcurementRecord> fetchProcurement(int procurementId) async {
    final data = await ApiService.get('/owner/procurements/$procurementId');
    return ProcurementRecord.fromJson(data);
  }

  Future<ProcurementRecord> approve(ProcurementRecord procurement) async {
    final data = await ApiService.patch(
      '/owner/procurements/${procurement.procurementId}/decision',
      body: {
        'decision': 'APPROVED',
        'items': [
          for (final item in procurement.items)
            item.toDecisionPayload(approve: true),
        ],
        'rejected_reason': null,
      },
    );
    return ProcurementRecord.fromJson(data);
  }

  Future<ProcurementRecord> reject({
    required ProcurementRecord procurement,
    required String reason,
  }) async {
    final data = await ApiService.patch(
      '/owner/procurements/${procurement.procurementId}/decision',
      body: {
        'decision': 'REJECTED',
        'items': [
          for (final item in procurement.items)
            item.toDecisionPayload(approve: false),
        ],
        'rejected_reason': reason,
      },
    );
    return ProcurementRecord.fromJson(data);
  }

  List<Map<String, dynamic>> _readList(Map<String, dynamic> data) {
    final rawItems = data['items'] ?? data['value'] ?? data;
    if (rawItems is List) {
      return rawItems.whereType<Map<String, dynamic>>().toList();
    }
    if (data.containsKey('procurement_id')) {
      return [data];
    }
    return [];
  }
}
