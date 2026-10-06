class EducationRecordData {
  const EducationRecordData({
    required this.id,
    required this.degree,
    required this.institution,
    this.startDate,
    this.endDate,
    this.grade,
    this.isCurrent = false,
  });

  final int id;
  final String degree;
  final String institution;
  final String? startDate;
  final String? endDate;
  final String? grade;
  final bool isCurrent;
}
