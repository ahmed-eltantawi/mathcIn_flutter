import 'package:MatchIn/core/services/app_config_service.dart';
import 'package:MatchIn/core/services/services_locator.dart';

/// Resolves avatar paths returned by the API against its runtime host.
///
/// The API documents avatar values as paths such as
/// `/uploads/avatars/avatar-demo.png`, while Flutter image providers require
/// an absolute URL.
abstract class ProfileAvatarUrl {
  static String? resolve(String? value) {
    final raw = value?.trim();
    if (raw == null || raw.isEmpty) return null;

    final uri = Uri.tryParse(raw);
    if (uri != null && uri.hasScheme && uri.host.isNotEmpty) {
      return uri.toString();
    }

    if (!getIt.isRegistered<AppConfigService>()) return null;
    final apiBaseUrl = getIt<AppConfigService>().currentBaseUrl;
    if (apiBaseUrl == null) return null;

    final baseUri = Uri.tryParse(apiBaseUrl);
    if (baseUri == null || !baseUri.hasScheme || baseUri.host.isEmpty) {
      return null;
    }

    final origin = baseUri.replace(path: '/', query: null, fragment: null);
    return origin.resolve(raw).toString();
  }
}
