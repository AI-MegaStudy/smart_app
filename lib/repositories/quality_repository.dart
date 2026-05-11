import 'dart:typed_data';

import 'package:smart_app/core/api_service.dart';
import 'package:smart_app/model/procurement_record.dart';
import 'package:smart_app/model/quality_record.dart';
import 'package:smart_app/repositories/procurement_repository.dart';

class QualityRepository {
  final ProcurementRepository procurementRepository;

  QualityRepository({ProcurementRepository? procurementRepository})
    : procurementRepository =
          procurementRepository ?? ProcurementRepository();

  Future<List<ProcurementItemRecord>> fetchInspectionTargets() async {
    final procurements = await procurementRepository.fetchProcurements();
    return [
      for (final procurement in procurements)
        if (procurement.statusCode == 'APPROVED' ||
            procurement.statusCode == 'PARTIAL_APPROVED')
          ...procurement.items,
    ];
  }

  Future<List<QualityInspectionRecord>> fetchInspections() async {
    final data = await ApiService.get('/owner/quality-inspections');
    return _readList(data).map(QualityInspectionRecord.fromJson).toList();
  }

  Future<String> uploadImage({
    required Uint8List bytes,
    required String filename,
  }) async {
    final data = await ApiService.multipartPost(
      '/owner/quality-inspections/image',
      fieldName: 'file',
      bytes: bytes,
      filename: filename,
    );
    final imageUrl = data['image_url'];
    if (imageUrl is String && imageUrl.isNotEmpty) {
      return imageUrl;
    }
    throw ApiException('신선도 검사 이미지 업로드 응답에 image_url이 없습니다.');
  }

  Future<QualityInspectionRecord> analyze({
    required int procurementItemId,
    required String imageUrl,
  }) async {
    final data = await ApiService.post(
      '/owner/quality-inspections/analyze',
      body: {
        'procurement_item_id': procurementItemId,
        'image_url': imageUrl,
        'persist_image': false,
      },
    );
    return QualityInspectionRecord.fromJson(data);
  }

  Future<QualityInspectionRecord> saveInspection({
    required int procurementItemId,
    required String imageUrl,
    required String ownerConfirmedGrade,
    required String ownerDecision,
  }) async {
    final data = await ApiService.post(
      '/owner/quality-inspections',
      body: {
        'procurement_item_id': procurementItemId,
        'image_url': imageUrl,
        'owner_confirmed_grade': ownerConfirmedGrade,
        'owner_decision': ownerDecision,
      },
    );
    return QualityInspectionRecord.fromJson(data);
  }

  List<Map<String, dynamic>> _readList(Map<String, dynamic> data) {
    final rawItems = data['items'] ?? data['value'] ?? data;
    if (rawItems is List) {
      return rawItems.whereType<Map<String, dynamic>>().toList();
    }
    if (data.containsKey('quality_inspection_id')) return [data];
    return [];
  }
}
