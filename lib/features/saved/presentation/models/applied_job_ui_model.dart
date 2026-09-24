import 'package:flutter/material.dart';

enum ApplicationStatus {
  applied,
  inReview,
  interview,
}

class AppliedJobUiModel {
  const AppliedJobUiModel({
    required this.id,
    required this.title,
    required this.company,
    required this.companyInitials,
    required this.logoBgColor,
    required this.logoTextColor,
    required this.tags,
    required this.appliedTime,
    required this.footerStatus,
    required this.status,
    this.highlightNote,
  });

  final String id;
  final String title;
  final String company;
  final String companyInitials;
  final Color logoBgColor;
  final Color logoTextColor;
  final List<String> tags;
  final String appliedTime;
  final String footerStatus;
  final ApplicationStatus status;
  final String? highlightNote;

  AppliedJobUiModel copyWith({
    String? id,
    String? title,
    String? company,
    String? companyInitials,
    Color? logoBgColor,
    Color? logoTextColor,
    List<String>? tags,
    String? appliedTime,
    String? footerStatus,
    ApplicationStatus? status,
    String? highlightNote,
  }) {
    return AppliedJobUiModel(
      id: id ?? this.id,
      title: title ?? this.title,
      company: company ?? this.company,
      companyInitials: companyInitials ?? this.companyInitials,
      logoBgColor: logoBgColor ?? this.logoBgColor,
      logoTextColor: logoTextColor ?? this.logoTextColor,
      tags: tags ?? this.tags,
      appliedTime: appliedTime ?? this.appliedTime,
      footerStatus: footerStatus ?? this.footerStatus,
      status: status ?? this.status,
      highlightNote: highlightNote ?? this.highlightNote,
    );
  }

  static final List<AppliedJobUiModel> dummyAppliedJobs = [
    const AppliedJobUiModel(
      id: 'app_1',
      title: 'Senior Product Designer',
      company: 'Spotify',
      companyInitials: 'SP',
      logoBgColor: Color(0xFFE8F5E9),
      logoTextColor: Color(0xFF2E7D32),
      tags: ['Stockholm', 'Hybrid', 'Full-time'],
      appliedTime: 'Applied 2 days ago',
      footerStatus: 'Application viewed by recruiter',
      status: ApplicationStatus.interview,
      highlightNote: 'Interview scheduled for tomorrow at 2:00 PM',
    ),
    const AppliedJobUiModel(
      id: 'app_2',
      title: 'Junior Flutter Developer',
      company: 'TechNova',
      companyInitials: 'TN',
      logoBgColor: Color(0xFFEDE7F6),
      logoTextColor: Color(0xFF512DA8),
      tags: ['Cairo', 'Hybrid', 'Full-time'],
      appliedTime: 'Applied 4 days ago',
      footerStatus: 'Under review by hiring team',
      status: ApplicationStatus.inReview,
    ),
    const AppliedJobUiModel(
      id: 'app_3',
      title: 'Mobile Developer Intern',
      company: 'CodeHub',
      companyInitials: 'CH',
      logoBgColor: Color(0xFFFBE9E7),
      logoTextColor: Color(0xFFD84315),
      tags: ['Remote', 'Internship'],
      appliedTime: 'Applied 1 week ago',
      footerStatus: 'Application submitted',
      status: ApplicationStatus.applied,
    ),
  ];
}
