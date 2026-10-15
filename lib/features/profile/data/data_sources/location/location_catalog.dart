import 'package:countrify/countrify.dart';

/// Local geographic reference data for the Edit Profile location and
/// phone calling-code selectors.
///
/// Backed by the `countrify` package (ISO countries, per-country states,
/// per-state cities, CLDR country-name translations, calling codes).
/// No networking is involved: countries are compile-time data, states
/// and cities decode lazily from bundled per-country/per-state files.
///
/// Machine values sent to the backend are always the English dataset
/// names (matching existing stored values such as `Egypt`/`Cairo`);
/// map values are display labels localized to Arabic/English where the
/// dataset provides translations.
class LocationCatalog {
  const LocationCatalog();

  /// Machine (English) country name → display label.
  Map<String, String> countries({required bool arabic}) {
    final entries = CountryUtils.getAllCountries().map(
      (country) => MapEntry(
        country.name,
        arabic
            ? CountryUtils.getCountryNameInLanguage(country, 'ar')
            : country.name,
      ),
    );
    return Map<String, String>.fromEntries(entries);
  }

  /// Dial code (`+20`) → display label (`Egypt (+20)`).
  ///
  /// Keyed by dial code and kept separate from the Profile location
  /// selection. Phone belongs to the User object and is never submitted
  /// through PATCH /candidate/profile.
  Map<String, String> callingCodes({required bool arabic}) {
    final codes = <String, String>{};
    for (final country in CountryUtils.getAllCountries()) {
      if (country.callingCodes.isEmpty) continue;
      final label = arabic
          ? CountryUtils.getCountryNameInLanguage(country, 'ar')
          : country.name;
      for (final code in country.callingCodes) {
        codes.putIfAbsent('+$code', () => '$label (+$code)');
      }
    }
    return codes;
  }

  /// Machine state name → display label for [countryName].
  ///
  /// Returns an empty map when the country is unknown to the dataset.
  /// Unknown existing backend values keep displaying through the
  /// dropdown's current-value injection and are never altered here.
  Future<Map<String, String>> statesForCountry(String countryName) async {
    final country = _countryByName(countryName);
    if (country == null) return const {};
    final states = await GeoRepository.instance.statesOf(country.alpha2Code);
    return {for (final state in states) state.name: state.name};
  }

  /// Machine city name → display label for [stateName] in [countryName].
  ///
  /// Returns an empty map when the country or state is unknown.
  Future<Map<String, String>> citiesForState(
    String countryName,
    String stateName,
  ) async {
    final country = _countryByName(countryName);
    if (country == null) return const {};
    final states = await GeoRepository.instance.statesOf(country.alpha2Code);
    final normalized = stateName.trim().toLowerCase();
    for (final state in states) {
      if (state.name.trim().toLowerCase() == normalized) {
        final cities = await GeoRepository.instance.citiesOf(state.id);
        return {for (final city in cities) city.name: city.name};
      }
    }
    return const {};
  }

  /// Resolves the parent state name for [cityName] in [countryName].
  ///
  /// Used to initialize a local-only state filter from saved
  /// country/city data. Returns null when the city cannot be resolved
  /// to a dataset state; callers must keep any existing value.
  Future<String?> resolveStateName(String countryName, String cityName) async {
    final country = _countryByName(countryName);
    final normalized = cityName.trim().toLowerCase();
    if (country == null || normalized.isEmpty) return null;
    final matches = await GeoRepository.instance.searchCities(
      countryIso2: country.alpha2Code,
      query: cityName.trim(),
      limit: 20,
    );
    for (final match in matches) {
      if (match.city.name.trim().toLowerCase() == normalized) {
        return match.state.name;
      }
    }
    return null;
  }

  Country? _countryByName(String name) {
    final normalized = name.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    for (final country in CountryUtils.getAllCountries()) {
      if (country.name.trim().toLowerCase() == normalized) return country;
    }
    return null;
  }
}
