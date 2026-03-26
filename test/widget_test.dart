import 'package:flutter_test/flutter_test.dart';

import 'package:vaaya/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BanjaraVivahApp());
    expect(find.byType(BanjaraVivahApp), findsOneWidget);
  });
}
