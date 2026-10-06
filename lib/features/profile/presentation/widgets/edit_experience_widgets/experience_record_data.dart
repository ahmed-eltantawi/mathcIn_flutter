class ExperienceRecordData {
  const ExperienceRecordData({
    required this.id,
    required this.jobTitle,
    required this.companyName,
    this.employmentType,
    this.workMode,
    this.location,
    this.startDate,
    this.endDate,
    this.description,
    this.skills = const [],
  });

  final int id;
  final String jobTitle;
  final String companyName;
  final String? employmentType;
  final String? workMode;
  final String? location;
  final String? startDate;
  final String? endDate;
  final String? description;
  final List<String> skills;
}
