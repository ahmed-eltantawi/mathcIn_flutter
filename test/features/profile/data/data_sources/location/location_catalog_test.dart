import 'package:MatchIn/features/profile/data/data_sources/location/location_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const catalog = LocationCatalog();

  group('LocationCatalog countries', () {
    test('contains Egypt and a full country list', () {
      final countries = catalog.countries(arabic: false);

      // countrify 2.5.0 ships 195 countries (README's 250 includes
      // territories covered elsewhere in its geo dataset).
      expect(countries.length, greaterThanOrEqualTo(190));
      expect(countries['Egypt'], 'Egypt');
    });

    test('localizes display labels to Arabic without changing keys', () {
      final countries = catalog.countries(arabic: true);

      expect(countries['Egypt'], 'مصر');
      expect(countries.keys, contains('Egypt'));
    });
  });

  group('LocationCatalog callingCodes', () {
    test('exposes Egypt dial code separately from location', () {
      final codes = catalog.callingCodes(arabic: false);

      expect(codes['+20'], contains('Egypt'));
      expect(codes['+20'], contains('+20'));
    });
  });

  group('LocationCatalog states', () {
    test('lists Egyptian governorates including Cairo', () async {
      final states = await catalog.statesForCountry('Egypt');

      expect(states, contains('Cairo'));
      expect(states['Cairo'], 'Cairo');
    });

    test('matches country names case-insensitively', () async {
      final states = await catalog.statesForCountry('  egypt ');

      expect(states, contains('Cairo'));
    });

    test('returns empty options for unknown countries', () async {
      expect(await catalog.statesForCountry('Atlantis'), isEmpty);
      expect(await catalog.statesForCountry(''), isEmpty);
    });
  });

  group('LocationCatalog cities', () {
    test('lists cities for Cairo governorate', () async {
      final cities = await catalog.citiesForState('Egypt', 'Cairo');

      expect(cities, isNotEmpty);
    });

    test('returns empty options for unknown state or country', () async {
      expect(await catalog.citiesForState('Egypt', 'Atlantis'), isEmpty);
      expect(await catalog.citiesForState('Atlantis', 'Cairo'), isEmpty);
      expect(await catalog.citiesForState('Egypt', ''), isEmpty);
    });
  });

  group('LocationCatalog resolveStateName', () {
    test('resolves the parent state of a known city', () async {
      expect(await catalog.resolveStateName('Egypt', 'Bulaq'), 'Cairo');
    });

    test('returns null for unknown cities or countries', () async {
      expect(await catalog.resolveStateName('Egypt', 'Atlantis'), isNull);
      expect(await catalog.resolveStateName('Atlantis', 'Cairo'), isNull);
      expect(await catalog.resolveStateName('Egypt', ''), isNull);
    });
  });
}
