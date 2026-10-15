import 'package:MatchIn/features/profile/presentation/widgets/profile_screen_widgets/profile_form_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProfileFormValidator.formatDate', () {
    test('formats as YYYY-MM-DD with zero padding', () {
      expect(
        ProfileFormValidator.formatDate(DateTime(2018, 9, 1)),
        '2018-09-01',
      );
      expect(
        ProfileFormValidator.formatDate(DateTime(2023, 12, 31)),
        '2023-12-31',
      );
    });
  });

  group('ProfileFormValidator.parseDate', () {
    test('parses YYYY-MM-DD strings', () {
      expect(
        ProfileFormValidator.parseDate('2018-09-01'),
        DateTime(2018, 9, 1),
      );
    });

    test('returns null for null, empty, or invalid input', () {
      expect(ProfileFormValidator.parseDate(null), isNull);
      expect(ProfileFormValidator.parseDate('  '), isNull);
      expect(ProfileFormValidator.parseDate('not-a-date'), isNull);
    });
  });

  group('ProfileFormValidator.normalizeDateForDisplay', () {
    test('keeps plain YYYY-MM-DD values unchanged', () {
      expect(
        ProfileFormValidator.normalizeDateForDisplay('2000-01-01'),
        '2000-01-01',
      );
    });

    test('trims an ISO-8601 datetime to its calendar date', () {
      expect(
        ProfileFormValidator.normalizeDateForDisplay(
          '2010-10-05T00:00:00.000000Z',
        ),
        '2010-10-05',
      );
    });

    test('never shifts the calendar day across timezones', () {
      // A naive instant parse could move this to Oct 4 west of UTC;
      // the date part is extracted verbatim instead.
      expect(
        ProfileFormValidator.normalizeDateForDisplay(
          '2010-10-05T00:00:00.000000Z',
        ),
        '2010-10-05',
      );
      expect(
        ProfileFormValidator.normalizeDateForDisplay(
          '2010-10-05T23:30:00+02:00',
        ),
        '2010-10-05',
      );
    });

    test('returns empty for null or blank input', () {
      expect(ProfileFormValidator.normalizeDateForDisplay(null), '');
      expect(ProfileFormValidator.normalizeDateForDisplay('   '), '');
    });

    test('keeps malformed values verbatim', () {
      expect(
        ProfileFormValidator.normalizeDateForDisplay('not-a-date'),
        'not-a-date',
      );
      expect(
        ProfileFormValidator.normalizeDateForDisplay('2010-13-45'),
        '2010-13-45',
      );
      expect(
        ProfileFormValidator.normalizeDateForDisplay('2010-02-30'),
        '2010-02-30',
      );
    });
  });

  group('ProfileFormValidator.parseDisplayDate', () {
    test('parses normalized dates as local midnight', () {
      expect(
        ProfileFormValidator.parseDisplayDate('2010-10-05T00:00:00.000000Z'),
        DateTime(2010, 10, 5),
      );
      expect(
        ProfileFormValidator.parseDisplayDate('2000-01-01'),
        DateTime(2000, 1, 1),
      );
    });

    test('returns null for null, empty, or malformed input', () {
      expect(ProfileFormValidator.parseDisplayDate(null), isNull);
      expect(ProfileFormValidator.parseDisplayDate('  '), isNull);
      expect(ProfileFormValidator.parseDisplayDate('not-a-date'), isNull);
    });
  });

  group('ProfileFormValidator.validateInstitution', () {
    test('returns message when blank', () {
      expect(
        ProfileFormValidator.validateInstitution(
          '   ',
          requiredMessage: 'Required',
        ),
        'Required',
      );
    });

    test('returns null when provided', () {
      expect(
        ProfileFormValidator.validateInstitution(
          'Ain Shams University',
          requiredMessage: 'Required',
        ),
        isNull,
      );
    });
  });

  group('ProfileFormValidator.validateDateRange', () {
    test('returns null when either date is missing', () {
      expect(
        ProfileFormValidator.validateDateRange(
          start: null,
          end: DateTime(2023, 7, 1),
          invalidMessage: 'Invalid',
        ),
        isNull,
      );
      expect(
        ProfileFormValidator.validateDateRange(
          start: DateTime(2018, 9, 1),
          end: null,
          invalidMessage: 'Invalid',
        ),
        isNull,
      );
    });

    test('returns null when end is on or after start', () {
      expect(
        ProfileFormValidator.validateDateRange(
          start: DateTime(2018, 9, 1),
          end: DateTime(2023, 7, 1),
          invalidMessage: 'Invalid',
        ),
        isNull,
      );
      expect(
        ProfileFormValidator.validateDateRange(
          start: DateTime(2018, 9, 1),
          end: DateTime(2018, 9, 1),
          invalidMessage: 'Invalid',
        ),
        isNull,
      );
    });

    test('returns message when end is before start', () {
      expect(
        ProfileFormValidator.validateDateRange(
          start: DateTime(2023, 7, 1),
          end: DateTime(2018, 9, 1),
          invalidMessage: 'Invalid',
        ),
        'Invalid',
      );
    });
  });
}
