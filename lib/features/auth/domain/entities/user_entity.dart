/// Domain entity representing the authenticated user.
/// Holds all fields returned by POST /api/auth/login → user object.
class UserEntity {
  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    this.avatar,
    this.phone,
  });

  final int id;
  final String name;
  final String email;
  final String role;
  final bool isActive;
  final String? avatar;
  final String? phone;
}
