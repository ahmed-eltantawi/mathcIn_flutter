import 'package:MatchIn/core/networking/api_end_points.dart';

class ErrorModel {
  ErrorModel({required this.statusCode, required this.errorMessage});

  factory ErrorModel.fromJson(Map<String, dynamic> json, {int? statusCode}) {
    String message =
        json[ApiKey.errorMessage]?.toString() ?? 'Unknown error occurred';

    if (json['errors'] is Map && (json['errors'] as Map).isNotEmpty) {
      final errors = json['errors'] as Map;
      final firstKey = errors.keys.first;
      final firstVal = errors[firstKey];
      if (firstVal is List && firstVal.isNotEmpty) {
        message = firstVal.first.toString();
      } else if (firstVal is String) {
        message = firstVal;
      }
    }

    final code = json[ApiKey.statusCode] is int
        ? json[ApiKey.statusCode] as int
        : (statusCode ?? 0);

    return ErrorModel(
      statusCode: code,
      errorMessage: message,
    );
  }

  final int statusCode;
  final String errorMessage;
}
