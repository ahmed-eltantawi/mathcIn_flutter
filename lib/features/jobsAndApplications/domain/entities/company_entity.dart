import 'package:equatable/equatable.dart';

class CompanyEntity extends Equatable {
  const CompanyEntity({
    required this.id,
    required this.name,
    this.logoUrl,
    this.isVerified = false,
    this.isActive = true,
  });

  final int id;
  final String name;
  final String? logoUrl;
  final bool isVerified;
  final bool isActive;

  @override
  List<Object?> get props => [id, name, logoUrl, isVerified, isActive];
}
