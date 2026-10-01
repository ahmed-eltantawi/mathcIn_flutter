import 'package:MatchIn/features/jobsAndApplications/domain/entities/company_entity.dart';

///! Constants for JSON keys used in CompanyModel
abstract class CompanyModelKey {
  static const String id = 'id';
  static const String name = 'name';
  static const String logoUrl = 'logo_url';
  static const String isVerified = 'is_verified';
  static const String isActive = 'is_active';
}

class CompanyModel {
  const CompanyModel({
    required this.id,
    required this.name,
    this.logoUrl,
    this.isVerified = false,
    this.isActive = true,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      id: json[CompanyModelKey.id] is int
          ? json[CompanyModelKey.id] as int
          : int.tryParse(json[CompanyModelKey.id]?.toString() ?? '0') ?? 0,
      name: json[CompanyModelKey.name] as String? ?? '',
      logoUrl: json[CompanyModelKey.logoUrl] as String?,
      isVerified: json[CompanyModelKey.isVerified] as bool? ?? false,
      isActive: json[CompanyModelKey.isActive] as bool? ?? true,
    );
  }

  final int id;
  final String name;
  final String? logoUrl;
  final bool isVerified;
  final bool isActive;

  Map<String, dynamic> toJson() {
    return {
      CompanyModelKey.id: id,
      CompanyModelKey.name: name,
      CompanyModelKey.logoUrl: logoUrl,
      CompanyModelKey.isVerified: isVerified,
      CompanyModelKey.isActive: isActive,
    };
  }

  CompanyEntity toEntity() {
    return CompanyEntity(
      id: id,
      name: name,
      logoUrl: logoUrl,
      isVerified: isVerified,
      isActive: isActive,
    );
  }
}
