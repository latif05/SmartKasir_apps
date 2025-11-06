// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smartkasir/src/app/app.dart';
import 'package:smartkasir/src/core/constants/app_strings.dart';
import 'package:smartkasir/src/core/di/injector.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await configureDependencies();
  });

  testWidgets('Login page renders essential fields', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: SmartKasirApp()),
    );

    await tester.pumpAndSettle();

    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.loginSubtitle), findsOneWidget);
    expect(find.text(AppStrings.usernameLabel), findsOneWidget);
    expect(find.text(AppStrings.passwordLabel), findsOneWidget);
  });
}
