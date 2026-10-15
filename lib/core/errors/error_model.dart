import 'package:MatchIn/core/networking/api_end_points.dart';

class ErrorModel {
  const ErrorModel({
    required this.statusCode,
    required this.errorMessage,
    this.fieldErrors = const {},
  });

  factory ErrorModel.fromJson(
    Map<String, dynamic> json, {
    int defaultStatusCode = 0,
  }) {
    final rawStatusCode = json[ApiKey.statusCode];
    final statusCode = rawStatusCode is int
        ? rawStatusCode
        : (rawStatusCode is num
            ? rawStatusCode.toInt()
            : int.tryParse(rawStatusCode?.toString() ?? '') ??
                defaultStatusCode);

    String errorMessage = 'An unexpected error occurred';
    final rawMessage = json[ApiKey.errorMessage];
    if (rawMessage is String && rawMessage.isNotEmpty) {
      errorMessage = rawMessage;
    } else if (json['error'] is String && (json['error'] as String).isNotEmpty) {
      errorMessage = json['error'] as String;
    } else if (json['errors'] is Map<String, dynamic>) {
      final errorsMap = json['errors'] as Map<String, dynamic>;
      final firstKey = errorsMap.keys.firstOrNull;
      if (firstKey != null) {
        final val = errorsMap[firstKey];
        if (val is List && val.isNotEmpty) {
          errorMessage = val.first.toString();
        } else if (val != null) {
          errorMessage = val.toString();
        }
      }
    }

    return ErrorModel(
      statusCode: statusCode,
      errorMessage: errorMessage,
      fieldErrors: _parseFieldErrors(json['errors']),
    );
  }

  /// Collects every `errors.<field>` message list so forms can render
  /// field-level validation feedback instead of only the first error.
  static Map<String, List<String>> _parseFieldErrors(dynamic raw) {
    if (raw is! Map<String, dynamic>) return const {};
    final parsed = <String, List<String>>{};
    raw.forEach((key, value) {
      if (value is List) {
        parsed[key] = value.map((e) => e.toString()).toList();
      } else if (value != null) {
        parsed[key] = [value.toString()];
      }
    });
    return parsed;
  }

  final int statusCode;
  final String errorMessage;
  final Map<String, List<String>> fieldErrors;
}

