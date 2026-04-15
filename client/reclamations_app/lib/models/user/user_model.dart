import 'package:equatable/equatable.dart';

enum UserRole { admin, technician, citizen }

class User extends Equatable {
  final int id;
  final String email;
  final String username;
  final String firstName;
  final String lastName;
  final String? phone;
  final UserRole role;
  final bool isActive;
  final DateTime dateJoined;

  const User({
    required this.id,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.phone,
    required this.role,
    required this.isActive,
    required this.dateJoined,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      phone: json['telephone'] as String?,
      role: _parseRole(json['role'] ?? json['groups']?.first),
      isActive: json['is_active'] ?? true,
      dateJoined: DateTime.parse(
        json['date_joined'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  static UserRole _parseRole(dynamic roleData) {
    if (roleData == null) return UserRole.citizen;

    String roleName;
    if (roleData is Map<String, dynamic>) {
      roleName = roleData['name'] ?? '';
    } else if (roleData is String) {
      roleName = roleData;
    } else {
      return UserRole.citizen;
    }

    switch (roleName.toUpperCase()) {
      case 'ADMIN':
        return UserRole.admin;
      case 'TECHNICIEN':
      case 'TECHNICIAN':
        return UserRole.technician;
      default:
        return UserRole.citizen;
    }
  }

  String get fullName => '$firstName $lastName';

  String get displayRole {
    switch (role) {
      case UserRole.admin:
        return 'Administrateur';
      case UserRole.technician:
        return 'Technicien';
      case UserRole.citizen:
        return 'Citoyen';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'telephone': phone,
      'role': role.name.toUpperCase(),
      'is_active': isActive,
      'date_joined': dateJoined.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    email,
    username,
    firstName,
    lastName,
    phone,
    role,
    isActive,
    dateJoined,
  ];
}
