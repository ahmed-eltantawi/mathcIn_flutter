/// Validates picked profile images before preview and upload.
///
/// The API documents JPEG and PNG avatar uploads. The local size limit is
/// retained as a client-side guard; the server remains authoritative.
class AvatarFileValidator {
  const AvatarFileValidator._();

  static const List<String> allowedExtensions = ['jpg', 'jpeg', 'png'];

  /// Client-side maximum image size (5 MiB).
  static const int maxBytes = 5 * 1024 * 1024;

  /// Lowercase extension without the dot, or empty when absent.
  static String extensionOf(String fileName) {
    final dot = fileName.lastIndexOf('.');
    if (dot < 0 || dot == fileName.length - 1) return '';
    return fileName.substring(dot + 1).toLowerCase();
  }

  /// Returns a localized error message, or null when the file is valid.
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
