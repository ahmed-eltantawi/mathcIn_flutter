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

  static final List<SavedJobItemModel> dummySavedJobs = [
    const SavedJobItemModel(
      id: '1',
      title: 'Junior Flutter Developer',
      company: 'TechNova',
      location: 'Cairo',
      workMode: 'Hybrid',
      experience: '0–2 years',
      jobType: 'Full-time',
      postedDate: 'Posted 2 days ago',
      matchStatus: MatchingStatusType.excellent,
      matchPercentage: 92,
      skills: ['Flutter', 'REST API', 'Bloc'],
      isSaved: true,
      showShareButton: true,
    ),
    const SavedJobItemModel(
      id: '2',
      title: 'Mobile Developer Intern',
      company: 'CodeHub',
      location: 'Remote',
      workMode: 'Remote',
      experience: 'Entry Level',
      jobType: 'Internship',
      postedDate: 'Posted today',
      matchStatus: MatchingStatusType.excellent,
      matchPercentage: 86,
      skills: ['Flutter', 'Firebase', 'Git'],
      isSaved: true,
      showShareButton: true,
    ),
    const SavedJobItemModel(
      id: '3',
      title: 'Junior Software Engineer',
      company: 'NextStack',
      location: 'Giza',
      workMode: 'Full-time',
      experience: 'Entry Level',
      jobType: 'On-site',
      postedDate: 'Posted 3 days ago',
      matchStatus: MatchingStatusType.good,
      matchPercentage: 78,
      skills: ['Dart', 'OOP', 'SQL'],
      isSaved: true,
      showShareButton: true,
    ),
  ];

  static final List<SavedJobItemModel> dummyAppliedJobs = [
    const SavedJobItemModel(
      id: 'app_1',
      title: 'Flutter Developer',
      company: 'Google',
      location: 'Cairo',
      workMode: 'Hybrid',
      experience: '1-3 years',
      jobType: 'Full-time',
      postedDate: 'Applied 3 days ago',
      matchStatus: MatchingStatusType.excellent,
      matchPercentage: 95,
      skills: ['Flutter', 'State Management', 'Clean Architecture'],
      isSaved: true,
      showShareButton: false,
    ),
    const SavedJobItemModel(
      id: 'app_2',
      title: 'Junior Mobile Engineer',
      company: 'Vodafone',
      location: 'Smart Village',
      workMode: 'Full-time',
      experience: '0-2 years',
      jobType: 'Hybrid',
      postedDate: 'Applied 1 week ago',
      matchStatus: MatchingStatusType.good,
      matchPercentage: 84,
      skills: ['Mobile Dev', 'CI/CD', 'Git'],
      isSaved: false,
      showShareButton: false,
    ),
  ];
}
