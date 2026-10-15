import 'package:url_launcher/url_launcher.dart';

/// Opens an HTTP(S) URL through a platform-compatible mechanism.
///
/// Only absolute HTTP(S) URLs are considered viewable. Storage paths
/// and other backend-internal references are never treated as public
/// URLs. Returns false (never throws) when the URL cannot be opened
/// so callers can show localized feedback instead.
class UrlLauncherHelper {
  const UrlLauncherHelper._();

  static bool isViewable(String? url) {
    final trimmed = url?.trim() ?? '';
    if (trimmed.isEmpty) return false;
    final uri = Uri.tryParse(trimmed);
    if (uri == null) return false;
    if (uri.scheme != 'http' && uri.scheme != 'https') return false;
    return uri.host.isNotEmpty;
  }

  static Future<bool> open(String? url) async {
    if (!isViewable(url)) return false;
    try {
      return await launchUrl(
        Uri.parse(url!.trim()),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      return false;
    }
  }

  /// Opens a local file through a platform-compatible mechanism.
  ///
  /// Only non-empty paths are attempted. Returns false (never throws)
  /// when the file cannot be opened so callers can show localized
  /// feedback instead.
  static Future<bool> openFile(String? path) async {
    final trimmed = path?.trim() ?? '';
    if (trimmed.isEmpty) return false;
    try {
      return await launchUrl(
        Uri.file(trimmed),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      return false;
    }
  }
}
