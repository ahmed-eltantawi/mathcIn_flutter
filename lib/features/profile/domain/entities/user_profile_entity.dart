import 'package:equatable/equatable.dart';

class UserProfileEntity extends Equatable {
  const UserProfileEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.jobTitle,
    required this.location,
    this.avatarUrl,
    this.phone,
    this.universityName,
    this.degree,
    this.years,
    this.experienceJobTitle,
    this.companyName,
    this.duration,
  });

  final int id;
  final String name;
  final String email;
  final String jobTitle;
  final String location;
  final String? avatarUrl;
  final String? phone;
  final String? universityName;
  final String? degree;
  final String? years;
  final String? experienceJobTitle;
  final String? companyName;
  final String? duration;

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    jobTitle,
    location,
    avatarUrl,
    phone,
    universityName,
    degree,
    years,
    experienceJobTitle,
    companyName,
    duration,
  ];
}
