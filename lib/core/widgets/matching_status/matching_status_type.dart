import 'package:MatchIn/core/utils/app_constants.dart';

enum MatchingStatusType {
  excellent,
  good,
  fair,
  poor;

  factory MatchingStatusType.fromPercentage(
    int percentage,
  ) {
    if (percentage >=
        AppConstants.excellentMatchThreshold) {
      return MatchingStatusType.excellent;
    } else if (percentage >=
        AppConstants.goodMatchThreshold) {
      return MatchingStatusType.good;
    } else if (percentage >=
        AppConstants.fairMatchThreshold) {
      return MatchingStatusType.fair;
    }
    return MatchingStatusType.poor;
  }
}
