import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recoverx/screens/auth/login_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget createLoginWidget() {
    return const MaterialApp(
      home: LoginScreen(),
    );
  }

  group('LoginScreen Client Validation Tests', () {
    testWidgets('Renders LoginScreen branding and form fields', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginWidget());

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign In to Your Account'), findsOneWidget);
      expect(find.text('SIGN IN'), findsOneWidget);
    });

    testWidgets('Displays validation errors when submitting empty fields', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginWidget());

      await tester.tap(find.text('SIGN IN'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('Displays validation error for invalid email format', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginWidget());

      await tester.enterText(find.byType(TextFormField).first, 'invalidemail');
      await tester.enterText(find.byType(TextFormField).last, 'password123');

      await tester.tap(find.text('SIGN IN'));
      await tester.pumpAndSettle();

      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('Toggles password visibility on eye icon click', (WidgetTester tester) async {
      await tester.pumpWidget(createLoginWidget());

      final visibilityIcon = find.byIcon(Icons.visibility_off_outlined);
      expect(visibilityIcon, findsOneWidget);

      await tester.tap(visibilityIcon);
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });
  });
}
