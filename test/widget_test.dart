// Basic smoke test for Smart Grocery POS.
//
// This just verifies the app builds and the dashboard title renders,
// without crashing on startup.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smart_grocery_pos/main.dart';

void main() {
  testWidgets('App launches and shows Dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: SmartGroceryPosApp()),
    );

    // Let async providers (DB, settings, etc.) settle.
    await tester.pumpAndSettle();

    // Dashboard should be the initial screen.
    expect(find.text('Dashboard'), findsWidgets);
  });
}
