import 'package:MatchIn/features/profile/domain/entities/user_profile_entity.dart';

class UserProfileModel {
  const UserProfileModel({
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

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    // Live `GET /auth/me` wraps the user in a `user` object; accept both
    // the wrapped shape and legacy top-level / `data` shapes.
    Map<String, dynamic> data;
    if (json['user'] is Map<String, dynamic>) {
      data = json['user'] as Map<String, dynamic>;
    } else if (json['data'] is Map<String, dynamic>) {
      final nested = json['data'] as Map<String, dynamic>;
      data = nested['user'] is Map<String, dynamic>
          ? nested['user'] as Map<String, dynamic>
          : nested;
    } else {
      data = json;
    }

    final locationVal =
        data['location']?.toString() ??
        [
          data['city'],
          data['country'],
        ].whereType<String>().where((s) => s.isNotEmpty).join(', ');

    return UserProfileModel(
      id: (data['id'] as num?)?.toInt() ?? 0,
      name: data['name']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      jobTitle:
          data['job_title']?.toString() ?? data['title']?.toString() ?? '',
      location: locationVal,
      avatarUrl: data['avatar_url']?.toString() ?? data['avatar']?.toString(),
      phone: data['phone']?.toString(),
      universityName:
          data['university_name']?.toString() ??
          data['university']?.toString() ??
          '',
      degree: data['degree']?.toString() ?? '',
      years: data['years']?.toString() ?? '',
      experienceJobTitle:
          data['experience_job_title']?.toString() ??
          data['job_title']?.toString() ??
          '',
      companyName:
          data['company_name']?.toString() ?? data['company']?.toString() ?? '',
      duration: data['duration']?.toString() ?? '',
    );
  }

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'job_title': jobTitle,
      'location': location,
      'avatar_url': avatarUrl,
      'phone': phone,
      'university_name': universityName,
      'degree': degree,
      'years': years,
      'experience_job_title': experienceJobTitle,
      'company_name': companyName,
      'duration': duration,
    };
  }

  UserProfileEntity toEntity() {
    return UserProfileEntity(
      id: id,
      name: name,
      email: email,
      jobTitle: jobTitle,
      location: location,
      avatarUrl: avatarUrl,
      phone: phone,
      universityName: universityName,
      degree: degree,
      years: years,
      experienceJobTitle: experienceJobTitle,
      companyName: companyName,
      duration: duration,
    );
  }
}
