import 'package:equatable/equatable.dart';

class CandidateXpEntity extends Equatable {
  const CandidateXpEntity({
    this.userId,
    this.totalXp = 0,
    this.level = 1,
    this.levelTitle = '',
    this.currentLevelXp = 0,
    this.nextLevelXp = 100,
    this.xpToNextLevel = 100,
    this.progressPercentage = 0.0,
  });

  final int? userId;
  final int totalXp;
  final int level;
  final String levelTitle;
  final int currentLevelXp;
  final int nextLevelXp;
  final int xpToNextLevel;
  final double progressPercentage;

  CandidateXpEntity copyWith({
    int? userId,
    int? totalXp,
    int? level,
    String? levelTitle,
    int? currentLevelXp,
    int? nextLevelXp,
    int? xpToNextLevel,
    double? progressPercentage,
  }) {
    return CandidateXpEntity(
      userId: userId ?? this.userId,
      totalXp: totalXp ?? this.totalXp,
      level: level ?? this.level,
      levelTitle: levelTitle ?? this.levelTitle,
      currentLevelXp: currentLevelXp ?? this.currentLevelXp,
      nextLevelXp: nextLevelXp ?? this.nextLevelXp,
      xpToNextLevel: xpToNextLevel ?? this.xpToNextLevel,
      progressPercentage: progressPercentage ?? this.progressPercentage,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    totalXp,
    level,
    levelTitle,
    currentLevelXp,
    nextLevelXp,
    xpToNextLevel,
    progressPercentage,
  ];
}
