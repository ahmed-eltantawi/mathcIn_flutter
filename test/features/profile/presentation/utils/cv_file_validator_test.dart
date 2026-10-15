import 'package:MatchIn/features/profile/presentation/widgets/profile_screen_widgets/cv_widgets/cv_file_validator.dart';
import 'package:flutter_test/flutter_test.dart';

String? validate({
  required String fileName,
  required int sizeBytes,
  bool hasContent = true,
}) {
  return CvFileValidator.validate(
    fileName: fileName,
    sizeBytes: sizeBytes,
    hasContent: hasContent,
    unsupportedMessage: 'unsupported',
    tooLargeMessage: 'too large',
    emptyMessage: 'empty',
  );
}

void main() {
  group('CvFileValidator.extensionOf', () {
    test('extracts lowercase extension', () {
      expect(CvFileValidator.extensionOf('My CV.PDF'), 'pdf');
      expect(CvFileValidator.extensionOf('resume.docx'), 'docx');
    });

    test('returns empty for missing extension', () {
      expect(CvFileValidator.extensionOf('resume'), isEmpty);
      expect(CvFileValidator.extensionOf('resume.'), isEmpty);
    });
  });

  group('CvFileValidator.validate', () {
    test('accepts PDF', () {
      expect(validate(fileName: 'cv.pdf', sizeBytes: 1024), isNull);
    });

    test('accepts DOCX', () {
      expect(validate(fileName: 'cv.docx', sizeBytes: 1024), isNull);
    });

    test('rejects DOC', () {
      expect(validate(fileName: 'cv.doc', sizeBytes: 1024), 'unsupported');
    });

    test('rejects unsupported extensions', () {
      expect(validate(fileName: 'cv.txt', sizeBytes: 1024), 'unsupported');
      expect(validate(fileName: 'cv.png', sizeBytes: 1024), 'unsupported');
      expect(validate(fileName: 'cv', sizeBytes: 1024), 'unsupported');
    });

    test('rejects empty files', () {
      expect(validate(fileName: 'cv.pdf', sizeBytes: 0), 'empty');
      expect(
        validate(fileName: 'cv.pdf', sizeBytes: 1024, hasContent: false),
        'empty',
      );
    });

    test('accepts exactly 5 MiB', () {
      expect(validate(fileName: 'cv.pdf', sizeBytes: 5 * 1024 * 1024), isNull);
    });

    test('rejects files greater than 5 MiB', () {
      expect(
        validate(fileName: 'cv.pdf', sizeBytes: 5 * 1024 * 1024 + 1),
        'too large',
      );
    });
  });
}
