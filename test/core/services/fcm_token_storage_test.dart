import 'package:MatchIn/core/cache/shared_preferences_helper.dart';
import 'package:MatchIn/core/services/shared_preferences_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferencesService preferencesService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    preferencesService = SharedPreferencesService(
      SharedPreferencesHelper(preferences: prefs),
    );
  });

  group('FCM token local storage', () {
    test('returns null before any token is saved', () {
      expect(preferencesService.getFcmToken(), isNull);
    });

    test('round-trips a saved token', () async {
      await preferencesService.saveFcmToken('fcm-token-123');
      expect(preferencesService.getFcmToken(), 'fcm-token-123');
    });

    test('overwrites a refreshed token', () async {
      await preferencesService.saveFcmToken('old-token');
      await preferencesService.saveFcmToken('new-token');
      expect(preferencesService.getFcmToken(), 'new-token');
    });
  });
}
