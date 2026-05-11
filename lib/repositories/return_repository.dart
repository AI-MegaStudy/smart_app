import 'package:smart_app/core/api_service.dart';
import 'package:smart_app/model/return_record.dart';

class ReturnRepository {
  Future<List<ReturnRequestRecord>> fetchReturns() async {
    final data = await ApiService.get('/owner/returns');
    final rawItems = data['items'] ?? data['value'] ?? data;
    if (rawItems is List) {
      return rawItems
          .whereType<Map<String, dynamic>>()
          .map(ReturnRequestRecord.fromJson)
          .toList();
    }
    if (data.containsKey('return_request_id')) {
      return [ReturnRequestRecord.fromJson(data)];
    }
    return [];
  }

  Future<ReturnRequestRecord> approve({
    required ReturnRequestRecord request,
    required int approvedAmount,
  }) async {
    final data = await ApiService.patch(
      '/owner/returns/${request.returnRequestId}/decision',
      body: {
        'decision': 'APPROVED',
        'approved_amount': approvedAmount,
        'decision_reason': '반품 승인 및 환불 완료',
      },
    );
    return ReturnRequestRecord.fromJson(data);
  }

  Future<ReturnRequestRecord> reject({
    required ReturnRequestRecord request,
    required String reason,
  }) async {
    final data = await ApiService.patch(
      '/owner/returns/${request.returnRequestId}/decision',
      body: {
        'decision': 'REJECTED',
        'approved_amount': 0,
        'decision_reason': reason,
      },
    );
    return ReturnRequestRecord.fromJson(data);
  }
}
