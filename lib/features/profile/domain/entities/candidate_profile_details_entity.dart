import 'package:equatable/equatable.dart';

class CandidateProfileDetailsEntity extends Equatable {
  const CandidateProfileDetailsEntity({
    required this.id,
    this.dateOfBirth,
    this.gender,
    this.jobTitle,
    this.location,
    this.country,
    this.state,
    this.city,
    this.githubUrl,
    this.linkedinUrl,
    this.militaryStatus,
    this.professionalSummary,
  });

  final int id;
  final String? dateOfBirth;
  final String? gender;
  final String? jobTitle;
  final String? location;
  final String? country;
  final String? state;
  final String? city;
  final String? githubUrl;
  final String? linkedinUrl;
  final String? militaryStatus;
  final String? professionalSummary;

  @override
  List<Object?> get props => [
    id,
    dateOfBirth,
    gender,
    jobTitle,
    location,
    country,
    state,
    city,
    githubUrl,
    linkedinUrl,
    militaryStatus,
    professionalSummary,
  ];
}
