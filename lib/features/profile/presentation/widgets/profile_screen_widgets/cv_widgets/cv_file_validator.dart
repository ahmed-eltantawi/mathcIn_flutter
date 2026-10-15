class CvFileValidator {
  const CvFileValidator._();

  static const List<String> allowedExtensions = ['pdf', 'docx'];

  static const int maxBytes = 5 * 1024 * 1024;

  // TODO(cv-backend): Before production, verify the accepted formats
  // and the maximum file size against the live backend contract.
  // Currently PDF/DOCX up to 5 MiB are accepted client-side, matching
  // the picker configuration and the documented upload examples.

  static String extensionOf(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot < 0 || dot == fileName.length - 1) return '';
    return fileName.substring(dot + 1).toLowerCase();
  }

  /// Returns a localized error message, or null when the file is valid.
  /// Exactly [maxBytes] is accepted; anything larger is rejected.
  static String? validate({
    required String fileName,
    required int sizeBytes,
    required bool hasContent,
    required String unsupportedMessage,
    required String tooLargeMessage,
    required String emptyMessage,
  }) {
    if (!allowedExtensions.contains(extensionOf(fileName))) {
      return unsupportedMessage;
    }
    if (!hasContent || sizeBytes <= 0) {
      return emptyMessage;
    }
    if (sizeBytes > maxBytes) {
      return tooLargeMessage;
    }
    return null;
  }
}
