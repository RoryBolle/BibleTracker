// Smoke test: verify the app starts and shows the AppBar title.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:bible_tracker/app.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('App starts and shows BibleTracker title',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: BibleTrackerApp()),
    );
    await tester.pump();
    expect(find.text('BibleTracker'), findsOneWidget);
  });
}

