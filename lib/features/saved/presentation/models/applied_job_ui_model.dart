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
}
