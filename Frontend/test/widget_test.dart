import 'package:flutter_test/flutter_test.dart';
import 'package:recoverx/main.dart';

void main() {
  testWidgets('RecoverX smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RecoverXApp());
    expect(find.text('RecoverX'), findsWidgets);
    await tester.pump(const Duration(seconds: 5));
  });
}
