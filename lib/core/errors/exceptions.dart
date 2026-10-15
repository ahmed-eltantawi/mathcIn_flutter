// This file is used to create custom exceptions for the application
// Each exception is a class that implements the Exception interface
// And there is an exception for each type of Failure

import 'package:dio/dio.dart';
import 'package:MatchIn/core/errors/error_model.dart';

class OfflineException implements Exception {}

class ServerException implements Exception {
  ServerException({required this.errorModel});
  final ErrorModel errorModel;
}

class CacheException implements Exception {}

class EmptyCacheException implements Exception {}

ErrorModel _fallbackErrorModel({required String message, int statusCode = 0}) {
  return ErrorModel(statusCode: statusCode, errorMessage: message);
}

ErrorModel _extractErrorModel(DioException e) {
  final response = e.response;
  final data = response?.data;

  if (data is Map<String, dynamic>) {
    return ErrorModel.fromJson(
      data,
      defaultStatusCode: response?.statusCode ?? 0,
    );
  }

  return _fallbackErrorModel(
    message: e.message ?? 'There was a problem with the server',
    statusCode: response?.statusCode ?? 0,
  );
}

void handleDioExceptions(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
      throw OfflineException();

    case DioExceptionType.sendTimeout:
      throw OfflineException();
    case DioExceptionType.receiveTimeout:
      throw OfflineException();

    case DioExceptionType.cancel:
      throw ServerException(
        errorModel: _fallbackErrorModel(
          message: 'The request was cancelled',
          statusCode: 499,
        ),
      );

    case DioExceptionType.connectionError:
      throw OfflineException();

    case DioExceptionType.unknown:
      throw ServerException(errorModel: _extractErrorModel(e));

    case DioExceptionType.badCertificate:
      throw ServerException(errorModel: _extractErrorModel(e));

    case DioExceptionType.badResponse:
      switch (e.response!.statusCode) {
        case 400: // bad request
          throw ServerException(errorModel: _extractErrorModel(e));
        case 401: // unauthorized
          throw ServerException(errorModel: _extractErrorModel(e));
        case 403: // forbidden
          throw ServerException(errorModel: _extractErrorModel(e));
        case 404: // not found
          throw ServerException(errorModel: _extractErrorModel(e));
        case 500: // internal server error
          throw ServerException(errorModel: _extractErrorModel(e));
        case 504: // gateway timeout
          throw ServerException(errorModel: _extractErrorModel(e));

        default:
          throw ServerException(errorModel: _extractErrorModel(e));
      }
    case DioExceptionType.transformTimeout:
      throw ServerException(
        errorModel: _fallbackErrorModel(
          message: 'The server response took too long to transform',
        ),
      );
  }
}
