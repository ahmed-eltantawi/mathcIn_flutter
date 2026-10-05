class ExperienceProfileItemData {
  const ExperienceProfileItemData({
    required this.jobTitle,
    required this.companyName,
    this.employmentType,
    this.country,
    this.city,
    this.description,
    this.technologies = const [],
    this.startDate,
    this.endDate,
    this.isCurrent = false,
  });

  final String jobTitle;
  final String companyName;

  final String? employmentType;
  final String? country;
  final String? city;
  final String? description;

  final List<String> technologies;

  final String? startDate;
  final String? endDate;

  final bool isCurrent;
}
