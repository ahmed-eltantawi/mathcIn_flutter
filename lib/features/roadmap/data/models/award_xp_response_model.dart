import 'package:MatchIn/features/roadmap/domain/entities/award_xp_response_entity.dart';

/// Parses `PATCH /roadmaps/xp` (`{status, message, data: {...}}`).
class AwardXpResponseModel extends AwardXpResponseEntity {
  const AwardXpResponseModel({
    required super.xpAdded,
    required super.earnedXp,
    super.roadmapId,
    super.roadmapTitle,
    super.reason,
    super.leveledUp,
    super.previousLevel,
    super.newLevel,
  });

  factory AwardXpResponseModel.fromJson(Map<String, dynamic> json) {
    return AwardXpResponseModel(
      xpAdded: _parseInt(json['xp_added']) ?? 0,
      earnedXp: _parseInt(json['earned_xp']) ?? 0,
      roadmapId: _parseInt(json['roadmap_id']),
      roadmapTitle: json['roadmap_title']?.toString(),
      reason: json['reason']?.toString(),
      leveledUp: _parseBool(json['leveled_up']) ?? false,
      previousLevel: _parseInt(json['previous_level']) ?? 1,
      newLevel: _parseInt(json['new_level']) ?? 1,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  static bool? _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      if (normalized == 'true' || normalized == '1') return true;
      if (normalized == 'false' || normalized == '0') return false;
    }
    return null;
  }
}
