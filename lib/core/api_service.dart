import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

typedef VoidCallback = void Function();

class ApiException implements Exception {
  final int? statusCode;
  final String message;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  static const String baseUrl = String.fromEnvironment(
    'SMART_APP_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api/v1',
  );
  static const Duration requestTimeout = Duration(seconds: 8);

  static http.Client client = http.Client();
  static VoidCallback? onUnauthorized;
  static String? _accessToken;

  static String? get accessToken => _accessToken;

  static void setAccessToken(String? token) {
    _accessToken = token;
  }

  static void clearAccessToken() {
    _accessToken = null;
  }

  static Future<Map<String, dynamic>> get(String path) async {
    final response = await _send(
      () => client.get(_uri(path), headers: _headers()),
    );
    return _decode(response);
  }

  static Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _send(
      () => client.post(
        _uri(path),
        headers: _headers(),
        body: jsonEncode(body ?? {}),
      ),
    );
    return _decode(response);
  }

  static Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _send(
      () => client.put(
        _uri(path),
        headers: _headers(),
        body: jsonEncode(body ?? {}),
      ),
    );
    return _decode(response);
  }

  static Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _send(
      () => client.patch(
        _uri(path),
        headers: _headers(),
        body: jsonEncode(body ?? {}),
      ),
    );
    return _decode(response);
  }

  static Future<Map<String, dynamic>> multipartPost(
    String path, {
    required String fieldName,
    required List<int> bytes,
    required String filename,
    Map<String, String>? fields,
  }) async {
    final request = http.MultipartRequest('POST', _uri(path));
    request.headers.addAll(_authHeaders());
    request.fields.addAll(fields ?? const {});
    request.files.add(
      http.MultipartFile.fromBytes(fieldName, bytes, filename: filename),
    );
    final streamed = await _sendStream(() => client.send(request));
    final response = await http.Response.fromStream(streamed);
    return _decode(response);
  }

  static Uri _uri(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$normalizedPath');
  }

  static Map<String, String> _headers() {
    return {
      'Content-Type': 'application/json',
      if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
    };
  }

  static Map<String, String> _authHeaders() {
    return {
      if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
    };
  }

  static Future<http.Response> _send(
    Future<http.Response> Function() request,
  ) async {
    try {
      return await request().timeout(requestTimeout);
    } on TimeoutException {
      throw ApiException('API 응답 시간이 초과되었습니다. 백엔드 서버 실행 상태를 확인하세요.');
    } on http.ClientException catch (error) {
      throw ApiException('API 서버에 연결할 수 없습니다: ${error.message}');
    } catch (error) {
      throw ApiException('API 요청을 완료할 수 없습니다: $error');
    }
  }

  static Future<http.StreamedResponse> _sendStream(
    Future<http.StreamedResponse> Function() request,
  ) async {
    try {
      return await request().timeout(requestTimeout);
    } on TimeoutException {
      throw ApiException('API 응답 시간이 초과되었습니다. 백엔드 서버 실행 상태를 확인하세요.');
    } on http.ClientException catch (error) {
      throw ApiException('API 서버에 연결할 수 없습니다: ${error.message}');
    } catch (error) {
      throw ApiException('API 요청을 완료할 수 없습니다: $error');
    }
  }

  static Map<String, dynamic> _decode(http.Response response) {
    final decoded = _decodeBody(response);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (response.statusCode == 401) {
        clearAccessToken();
        onUnauthorized?.call();
      }
      final error = decoded['error'];
      final detail = decoded['detail'];
      final message = error is String && error.isNotEmpty
          ? error
          : detail is String && detail.isNotEmpty
          ? detail
          : detail is List && detail.isNotEmpty
          ? detail.first.toString()
          : 'API 요청에 실패했습니다. 상태 코드: ${response.statusCode}';
      throw ApiException(message, statusCode: response.statusCode);
    }

    if (decoded.containsKey('data')) {
      final data = decoded['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      return {'value': data};
    }

    return decoded;
  }

  static Map<String, dynamic> _decodeBody(http.Response response) {
    if (response.body.isEmpty) return <String, dynamic>{};
    try {
      final value = jsonDecode(utf8.decode(response.bodyBytes));
      if (value is Map<String, dynamic>) return value;
      return {'value': value};
    } catch (_) {
      throw ApiException(
        'API 응답 형식이 올바르지 않습니다. 상태 코드: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }
}
