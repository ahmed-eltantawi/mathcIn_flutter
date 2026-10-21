import 'dart:typed_data';

///* API consumer is an abstract class used to consume the api requests
/// has five methods: get, post, put, patch, delete
/// each method takes a path, query parameters, data, and isFormData
abstract class ApiConsumer {
  //! ===== get =====
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool isFormData = false,
  });

  //! ===== post =====
  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool isFormData = false,
    void Function(int sentBytes, int totalBytes)? onSendProgress,
  });

  //! ===== put =====
  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool isFormData = false,
  });

  //! ===== patch =====
  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool isFormData = false,
  });

  //! ===== delete =====
  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool isFormData = false,
  });

  //! ===== downloadBytes =====
  /// Authenticated binary download (CV preview/file): never JSON-decodes
  /// the payload. Returns raw bytes plus best-effort filename/MIME hints
  /// from response headers.
  Future<({Uint8List bytes, String? fileName, String? mimeType})> downloadBytes(
    String path, {
    Map<String, dynamic>? queryParameters,
  });
}
