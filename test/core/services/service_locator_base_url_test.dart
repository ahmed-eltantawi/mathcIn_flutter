import 'package:MatchIn/core/networking/api_end_points.dart';
import 'package:MatchIn/core/services/services_locator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await getIt.reset();
  });

  tearDown(() async {
    await getIt.reset();
  });

  group('setupServiceLocator base URL resolution', () {
    test('applies a valid cached url centrally', () async {
      SharedPreferences.setMockInitialValues({
        'apiBaseUrl': 'https://cached.example/api',
      });

      await setupServiceLocator();

      expect(
        EndPoint.baseUrl,
        'https://cached.example/api/',
      );
    });

    // --- No fallback exists: unresolved stays empty until Firestore ---
    test(
      'leaves the url unresolved without a cache',
      () async {
        SharedPreferences.setMockInitialValues({});

        await setupServiceLocator();

        expect(EndPoint.baseUrl, isEmpty);
      },
    );

    test(
      'leaves the url unresolved on an invalid cache',
      () async {
        SharedPreferences.setMockInitialValues({
          'apiBaseUrl': 'not-a-url',
        });

        await setupServiceLocator();

        expect(EndPoint.baseUrl, isEmpty);
      },
    );
  });
}
