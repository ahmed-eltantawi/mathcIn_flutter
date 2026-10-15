import 'package:MatchIn/features/profile/presentation/widgets/edit_profile_widgets/avatar_file_validator.dart';
import 'package:flutter_test/flutter_test.dart';

String? validate(String name, int size) => AvatarFileValidator.validate(
  fileName: name,
  sizeBytes: size,
  hasContent: size > 0,
  unsupportedMessage: 'bad type',
  tooLargeMessage: 'too large',
  emptyMessage: 'empty',
);

void main() {
  group('AvatarFileValidator.extensionOf', () {
    test('extracts lowercase extension', () {
      expect(AvatarFileValidator.extensionOf('photo.JPG'), 'jpg');
      expect(AvatarFileValidator.extensionOf('avatar.profile.png'), 'png');
    });

    test('returns empty for missing extension', () {
      expect(AvatarFileValidator.extensionOf('photo'), '');
      expect(AvatarFileValidator.extensionOf('photo.'), '');
    });
  });

  group('AvatarFileValidator.validate', () {
    test('accepts JPG, PNG, and WEBP', () {
      expect(validate('a.jpg', 100), isNull);
      expect(validate('a.jpeg', 100), isNull);
      expect(validate('a.png', 100), isNull);
      expect(validate('a.webp', 100), isNull);
    });

    test('rejects unsupported image types', () {
      expect(validate('a.pdf', 100), 'bad type');
      expect(validate('a.gif', 100), 'bad type');
      expect(validate('a.bmp', 100), 'bad type');
      expect(validate('a', 100), 'bad type');
    });

    test('rejects empty files', () {
      expect(validate('a.jpg', 0), 'empty');
    });

    test('rejects files greater than 5 MiB', () {
      expect(validate('a.jpg', 5 * 1024 * 1024 + 1), 'too large');
    });

    test('accepts exactly 5 MiB', () {
      expect(validate('a.jpg', 5 * 1024 * 1024), isNull);
    });
  });
}
