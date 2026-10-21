import 'package:MatchIn/features/roadmap/domain/entities/candidate_xp_entity.dart';

class CandidateXpModel extends CandidateXpEntity {
  const CandidateXpModel({
    super.userId,
    super.totalXp,
    super.level,
    super.levelTitle,
    super.currentLevelXp,
    super.nextLevelXp,
    super.xpToNextLevel,
    super.progressPercentage,
  });

  factory CandidateXpModel.fromJson(Map<String, dynamic> json) {
    final levelInfo = json['level_info'];
    final Map<String, dynamic> infoMap = levelInfo is Map<String, dynamic>
        ? levelInfo
        : const {};

    final totalXp =
        _parseInt(json['total_xp']) ?? _parseInt(infoMap['total_xp']) ?? 0;
    final level = _parseInt(json['level']) ?? _parseInt(infoMap['level']) ?? 1;
    final levelTitle =
        json['level_title']?.toString() ?? infoMap['title']?.toString() ?? '';

    final currentLevelXp = _parseInt(infoMap['current_level_xp']) ?? 0;
    final nextLevelXp = _parseInt(infoMap['next_level_xp']) ?? 100;
    final xpToNextLevel =
        _parseInt(infoMap['xp_to_next_level']) ??
        (nextLevelXp - currentLevelXp);
    final progress =
        _parseDouble(infoMap['progress_percentage']) ??
        (nextLevelXp > 0 ? (currentLevelXp / nextLevelXp) * 100 : 0.0);

    return CandidateXpModel(
      userId: _parseInt(json['user_id']),
      totalXp: totalXp,
      level: level,
      levelTitle: levelTitle,
      currentLevelXp: currentLevelXp,
      nextLevelXp: nextLevelXp,
      xpToNextLevel: xpToNextLevel,
      progressPercentage: progress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (userId != null) 'user_id': userId,
      'total_xp': totalXp,
      'level': level,
      'level_title': levelTitle,
      'level_info': {
        'level': level,
        'title': levelTitle,
        'total_xp': totalXp,
        'current_level_xp': currentLevelXp,
        'next_level_xp': nextLevelXp,
        'xp_to_next_level': xpToNextLevel,
        'progress_percentage': progressPercentage,
      },
    };
  }

  static int? _parseInt(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }
}
