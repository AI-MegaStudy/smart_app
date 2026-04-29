import 'package:flutter_test/flutter_test.dart';
import 'package:smart_app/main.dart';

void main() {
  testWidgets('Owner app main shell smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const OwnerApp());

    expect(find.text('점주 대시보드'), findsOneWidget);
    expect(find.text('대시보드'), findsOneWidget);
    expect(find.text('상품'), findsOneWidget);
    expect(find.text('주문'), findsOneWidget);
    expect(find.text('배송'), findsOneWidget);
  });
}
