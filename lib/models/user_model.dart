// ============================================================================
// FUNCTIONS & METHODS INDEX:
// - Line 14: UserRoleExtension.displayName -> Returns descriptive title for role.
// - Line 23: UserRoleExtension.shortName -> Returns concise title (Doctor/Nurse).
// - Line 56: UserModel.copyWith() -> Returns updated clone of user profile model.
// ============================================================================

enum UserRole {
  doctor,
  nurse,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.doctor:
        return 'Doctor / Physician';
      case UserRole.nurse:
        return 'Nurse / Bedside Care';
    }
  }

  String get shortName {
    switch (this) {
      case UserRole.doctor:
        return 'Doctor';
      case UserRole.nurse:
        return 'Nurse';
    }
  }
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String department;
  final String hospital;
  final String badgeNumber;
  final String avatarUrl;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.department = 'H . M . S - Inpatient Ward',
    this.hospital = 'H . M . S',
    this.badgeNumber = 'BMC-8921',
    this.avatarUrl = '',
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    String? department,
    String? hospital,
    String? badgeNumber,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      department: department ?? this.department,
      hospital: hospital ?? this.hospital,
      badgeNumber: badgeNumber ?? this.badgeNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
