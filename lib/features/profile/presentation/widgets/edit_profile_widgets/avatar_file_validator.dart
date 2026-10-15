/// Validates picked profile images before preview and upload.
///
/// Provisional constraints (JPG/JPEG, PNG, WEBP; 5 MiB) mirror the CV
/// upload policy until the backend documents the avatar contract.
///
/// TODO(avatar-backend): verify accepted formats, size limits, and
/// MIME types against the final Swagger contract. Do not treat these
/// provisional rules as production backend validation.
class AvatarFileValidator {
  const AvatarFileValidator._();

  static const List<String> allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

  /// Provisional maximum image size (5 MiB), pending backend confirmation.
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
