import 'package:MatchIn/core/widgets/matching_status/matching_status_type.dart';

class SavedJobItemModel {
  const SavedJobItemModel({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.workMode,
    required this.experience,
    required this.jobType,
    required this.postedDate,
    required this.skills,
    required this.matchStatus,
    this.matchPercentage,
    this.isSaved = true,
    this.showShareButton = true,
  });

  final String id;
  final String title;
  final String company;
  final String location;
  final String workMode;
  final String experience;
  final String jobType;
  final String postedDate;
  final List<String> skills;
  final MatchingStatusType matchStatus;
  final int? matchPercentage;
  final bool isSaved;
  final bool showShareButton;

  SavedJobItemModel copyWith({
    String? id,
    String? title,
    String? company,
    String? location,
    String? workMode,
    String? experience,
    String? jobType,
    String? postedDate,
    List<String>? skills,
    MatchingStatusType? matchStatus,
    int? matchPercentage,
    bool? isSaved,
    bool? showShareButton,
  }) {
    return SavedJobItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      location: location ?? this.location,
      workMode: workMode ?? this.workMode,
      experience: experience ?? this.experience,
      jobType: jobType ?? this.jobType,
      postedDate: postedDate ?? this.postedDate,
      skills: skills ?? this.skills,
      matchStatus: matchStatus ?? this.matchStatus,
      matchPercentage: matchPercentage ?? this.matchPercentage,
      isSaved: isSaved ?? this.isSaved,
      showShareButton: showShareButton ?? this.showShareButton,
    );
  }
}
