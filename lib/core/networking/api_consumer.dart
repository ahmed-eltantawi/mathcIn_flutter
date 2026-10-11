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
}
