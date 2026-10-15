import 'dart:io';

import 'package:MatchIn/core/widgets/helpers/url_launcher_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

///* Writes CV [bytes] to a temporary file and opens it externally.
///
/// Returns true when an external viewer was launched. Never throws:
/// returns false when the file cannot be written or opened so callers
/// can show localized feedback instead.
Future<bool> previewCvBytes({
  required String fileName,
  required Uint8List bytes,
}) async {
  if (bytes.isEmpty) return false;
  if (kIsWeb) return false;
  try {
    final tempDir = await getTemporaryDirectory();
    final safeName = _sanitizeFileName(fileName);
    final file = File('${tempDir.path}/$safeName');
    await file.writeAsBytes(bytes, flush: true);
    final opened = await UrlLauncherHelper.openFile(file.path);
    return opened;
  } catch (_) {
    return false;
  }
}

String _sanitizeFileName(String fileName) {
  final trimmed = fileName.trim();
  final base = trimmed.isEmpty ? 'cv' : trimmed;
  final safe = base.replaceAll(RegExp(r'[^\w\-. ]'), '_');
  return 'cv_preview_$safe';
}
