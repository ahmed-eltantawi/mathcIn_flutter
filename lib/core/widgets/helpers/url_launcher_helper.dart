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

  /// Opens a new email addressed to [address] in the device's email app.
  static Future<bool> openEmail(
    String? address, {
    String? subject,
    String? body,
  }) async {
    final trimmed = address?.trim() ?? '';
    if (trimmed.isEmpty) return false;

    try {
      final queryParameters = <String, String>{
        if (subject != null && subject.isNotEmpty) 'subject': subject,
        if (body != null && body.isNotEmpty) 'body': body,
      };
      final query = queryParameters.entries
          .map((entry) => '${entry.key}=${Uri.encodeComponent(entry.value)}')
          .join('&');
      final emailUri = Uri.parse(
        'mailto:$trimmed${query.isEmpty ? '' : '?$query'}',
      );
      return await launchUrl(
        emailUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      return false;
    }
  }

  /// Opens a WhatsApp conversation with [phoneNumber].
  static Future<bool> openWhatsApp(String? phoneNumber) async {
    final digits = phoneNumber?.replaceAll(RegExp(r'\D'), '') ?? '';
    if (digits.isEmpty) return false;
    return open(Uri.https('wa.me', '/$digits').toString());
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
