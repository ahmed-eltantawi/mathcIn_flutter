class EducationProfileItemData {
  const EducationProfileItemData({
    required this.degree,
    required this.institution,
    this.startDate,
    this.endDate,
    this.grade,
  });

  final String degree;
  final String institution;
  final String? startDate;
  final String? endDate;
  final String? grade;
}
