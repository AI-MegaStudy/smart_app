import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:smart_app/core/api_service.dart';
import 'package:smart_app/main.dart';

void main() {
  tearDown(() {
    ApiService.clearAccessToken();
    ApiService.onUnauthorized = null;
    ApiService.client = http.Client();
  });

  testWidgets('Owner app login and dashboard API smoke test', (
    WidgetTester tester,
  ) async {
    ApiService.client = MockClient((request) async {
      final path = request.url.path;
      if (path == '/api/v1/auth/login') {
        return _json({
          'data': {
            'access_token': 'test-token',
            'token_type': 'bearer',
            'role': 'OWNER',
          },
          'message': 'success',
          'error': null,
        });
      }
      if (path == '/api/v1/me') {
        expect(_authHeader(request), 'Bearer test-token');
        return _json({
          'data': {'role': 'OWNER'},
          'message': 'success',
          'error': null,
        });
      }
      if (path == '/api/v1/owner/dashboard') {
        expect(_authHeader(request), 'Bearer test-token');
        return _json({
          'data': {
            'open_slots': 6,
            'new_procurements': 4,
            'quality_waiting': 7,
            'ready_to_ship': 3,
            'return_requests': 2,
          },
          'message': 'success',
          'error': null,
        });
      }
      return _json({'error': 'not found'}, statusCode: 404);
    });

    await tester.pumpWidget(const OwnerApp());

    expect(find.text('수확 운영을 시작하세요'), findsOneWidget);
    expect(find.text('로그인'), findsOneWidget);

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'owner-smoke@example.com',
    );
    await tester.enterText(
      find.byType(TextFormField).at(1),
      'SmokeTest123!',
    );
    await tester.tap(find.text('로그인'));
    await tester.pumpAndSettle();

    expect(find.text('점주 대시보드'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.menu_rounded));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.person_outline), findsOneWidget);
  });
}

String? _authHeader(http.Request request) {
  return request.headers['Authorization'] ?? request.headers['authorization'];
}

http.Response _json(Map<String, dynamic> body, {int statusCode = 200}) {
  return http.Response(
    jsonEncode(body),
    statusCode,
    headers: {'content-type': 'application/json'},
  );
}
