import 'package:MatchIn/core/widgets/helpers/url_launcher_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UrlLauncherHelper.isViewable', () {
    test('accepts http and https URLs', () {
      expect(
        UrlLauncherHelper.isViewable('https://cdn.example.com/cv.pdf'),
        isTrue,
      );
      expect(
        UrlLauncherHelper.isViewable('http://cdn.example.com/cv.docx'),
        isTrue,
      );
    });

    test('rejects missing or blank URLs', () {
      expect(UrlLauncherHelper.isViewable(null), isFalse);
      expect(UrlLauncherHelper.isViewable(''), isFalse);
      expect(UrlLauncherHelper.isViewable('   '), isFalse);
    });

    test('rejects storage paths and non-web schemes', () {
      expect(UrlLauncherHelper.isViewable('cvs/user-1/cv.pdf'), isFalse);
      expect(UrlLauncherHelper.isViewable('/var/storage/cv.pdf'), isFalse);
      expect(
        UrlLauncherHelper.isViewable('ftp://cdn.example.com/cv.pdf'),
        isFalse,
      );
      expect(UrlLauncherHelper.isViewable('file:///cv.pdf'), isFalse);
    });
  });

  group('UrlLauncherHelper.open', () {
    test('returns false without attempting launch for unusable URLs', () async {
      expect(await UrlLauncherHelper.open(null), isFalse);
      expect(await UrlLauncherHelper.open('cvs/user-1/cv.pdf'), isFalse);
    });
  });
}
