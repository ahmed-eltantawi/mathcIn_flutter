class TeamMemberModel {
  const TeamMemberModel({
    required this.name,
    required this.arabicName,
    required this.linkedInUrl,
    this.facebookUrl,
  });

  final String name;
  final String arabicName;
  final String linkedInUrl;
  final String? facebookUrl;
}
