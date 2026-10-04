import 'package:equatable/equatable.dart';

class ProfileUserEntity extends Equatable {
  const ProfileUserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    this.phone,
    this.avatar,
  });

  final int id;
  final String name;
  final String email;
  final String role;
  final bool isActive;
  final String? phone;
  final String? avatar;

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    role,
    isActive,
    phone,
    avatar,
  ];
}
