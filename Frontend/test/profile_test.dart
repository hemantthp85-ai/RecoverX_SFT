import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:recoverx/models/user_profile.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UserProfile Model Unit Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('UserProfile default values initialize cleanly', () {
      final profile = UserProfile.defaultProfile();
      expect(profile.fullName, equals('Alex Morgan'));
      expect(profile.notificationsEnabled, isTrue);
      expect(profile.useMetricUnits, isTrue);
      expect(profile.dataSyncEnabled, isTrue);
    });

    test('UserProfile saves and loads from SharedPreferences', () async {
      final initial = UserProfile.defaultProfile().copyWith(
        fullName: 'Jordan Reed',
        phone: '+1 555-999-0000',
        sport: 'Basketball',
        useMetricUnits: false,
      );

      await initial.saveToPrefs();
      final reloaded = await UserProfile.loadFromPrefs();

      expect(reloaded.fullName, equals('Jordan Reed'));
      expect(reloaded.phone, equals('+1 555-999-0000'));
      expect(reloaded.sport, equals('Basketball'));
      expect(reloaded.useMetricUnits, isFalse);
    });
  });
}
