import 'package:equatable/equatable.dart';

class UserMemberData extends Equatable {
  final int id;
  final String email;
  final String username;
  final String? fullName;
  final String? phone;
  final List<Role> roles;
  final bool isSelected;

  const UserMemberData({
    required this.id,
    required this.email,
    required this.username,
    this.fullName,
    this.phone,
    this.roles = const [],
    this.isSelected = false,
  });

  @override
  List<Object?> get props => [id, email, username, fullName, phone, roles, isSelected];

  factory UserMemberData.fromJson(Map<String, dynamic> json) {
    return UserMemberData(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      fullName: json['fullName'],
      phone: json['phone'],
      roles: json['roles'] != null ? List<Role>.from(json['roles'].map((role) => Role.fromJson(role))) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'fullName': fullName,
      'phone': phone,
      'roles': roles.map((role) => role.toJson()).toList(),
    };
  }

  @override
  bool get stringify => true;

  UserMemberData copyWith({
    int? id,
    String? email,
    String? username,
    String? fullName,
    String? phone,
    List<Role>? roles,
    bool? isSelected,
  }) {
    return UserMemberData(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      roles: roles ?? this.roles,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

class Role extends Equatable {
  final int id;
  final String name;

  const Role({
    required this.id,
    required this.name,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  @override
  List<Object?> get props => [id, name];
}
