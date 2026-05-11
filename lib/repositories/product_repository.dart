import 'package:smart_app/core/api_service.dart';
import 'package:smart_app/model/product_record.dart';

class ProductRepository {
  Future<List<ProductRecord>> fetchProducts() async {
    final data = await ApiService.get('/owner/products');
    final rawItems = data['items'] ?? data['value'] ?? data;
    if (rawItems is List) {
      return rawItems
          .whereType<Map<String, dynamic>>()
          .map(ProductRecord.fromJson)
          .toList();
    }
    if (data is Map<String, dynamic> && data.containsKey('product_id')) {
      return [ProductRecord.fromJson(data)];
    }
    return [];
  }

  Future<ProductRecord> createProduct(ProductRecord product) async {
    final farmId = product.farmId ?? await _fetchFirstFarmId();
    final data = await ApiService.post(
      '/owner/products',
      body: product.toPayload(fallbackFarmId: farmId),
    );
    return ProductRecord.fromJson(data);
  }

  Future<ProductRecord> updateProduct(ProductRecord product) async {
    final productId = product.productId;
    if (productId == null) {
      throw ApiException('상품 수정에는 product_id가 필요합니다.');
    }
    final farmId = product.farmId ?? await _fetchFirstFarmId();
    final data = await ApiService.put(
      '/owner/products/$productId',
      body: product.toPayload(fallbackFarmId: farmId),
    );
    return ProductRecord.fromJson(data);
  }

  Future<ProductRecord> updateProductStatus({
    required ProductRecord product,
    required String statusCode,
  }) async {
    final productId = product.productId;
    if (productId == null) {
      throw ApiException('상품 상태 변경에는 product_id가 필요합니다.');
    }
    final data = await ApiService.patch(
      '/owner/products/$productId/status',
      body: {'product_status': statusCode},
    );
    return ProductRecord.fromJson(data);
  }

  Future<ProductRecord> uploadProductImage({
    required ProductRecord product,
    required List<int> bytes,
    required String filename,
  }) async {
    final productId = product.productId;
    if (productId == null) {
      throw ApiException('상품 이미지 업로드에는 product_id가 필요합니다.');
    }
    final data = await ApiService.multipartPost(
      '/owner/products/$productId/image',
      fieldName: 'file',
      bytes: bytes,
      filename: filename,
    );
    return ProductRecord.fromJson(data);
  }

  Future<int> _fetchFirstFarmId() async {
    final data = await ApiService.get('/owner/farms/me');
    final rawItems = data['items'] ?? data['value'] ?? data;
    if (rawItems is List && rawItems.isNotEmpty) {
      final first = rawItems.first;
      if (first is Map<String, dynamic>) {
        final id = first['farm_id'];
        if (id is int) return id;
        if (id is num) return id.toInt();
        if (id is String) {
          final parsed = int.tryParse(id);
          if (parsed != null) return parsed;
        }
      }
    }
    throw ApiException('등록된 점주 농장이 없습니다. 상품 등록 전에 농장이 필요합니다.');
  }
}
