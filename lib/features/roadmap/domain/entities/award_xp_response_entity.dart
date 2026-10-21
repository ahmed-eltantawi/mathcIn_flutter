import 'package:equatable/equatable.dart';

class AwardXpResponseEntity extends Equatable {
  const AwardXpResponseEntity({
    required this.xpAdded,
    required this.earnedXp,
    this.roadmapId,
    this.roadmapTitle,
    this.reason,
    this.leveledUp = false,
    this.previousLevel = 1,
    this.newLevel = 1,
  });

  final int xpAdded;
  final int earnedXp;
  final int? roadmapId;
  final String? roadmapTitle;
  final String? reason;
  final bool leveledUp;
  final int previousLevel;
  final int newLevel;

  @override
  List<Object?> get props => [
    xpAdded,
    earnedXp,
    roadmapId,
    roadmapTitle,
    reason,
    leveledUp,
    previousLevel,
    newLevel,
  ];
}
