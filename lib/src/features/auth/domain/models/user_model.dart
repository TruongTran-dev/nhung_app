import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String accessToken;
  final String refreshToken;
  final int id;
  final String username;
  final String email;
  final List<String> roles;
  final String expiredAccessToken;
  final String expiredRefreshToken;
  const UserModel({
    required this.accessToken,
    required this.refreshToken,
    required this.id,
    required this.username,
    required this.email,
    required this.roles,
    required this.expiredAccessToken,
    required this.expiredRefreshToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      roles: (json['roles'] as List<dynamic>?)?.map((role) => role as String).toList() ?? [],
      expiredAccessToken: json['expiredAccessDate'] as String,
      expiredRefreshToken: json['expiredRefreshDate'] as String,
    );
  }

  @override
  List<Object?> get props => [
        accessToken,
        refreshToken,
        id,
        username,
        email,
        roles,
        expiredAccessToken,
        expiredRefreshToken,
      ];

  @override
  String toString() {
    return 'UserModel{accessToken: $accessToken, refreshToken: $refreshToken, id: $id, username: $username, email: $email, roles: $roles, expiredAccessToken: $expiredAccessToken, expiredRefreshToken: $expiredRefreshToken}';
  }

  @override
  bool get stringify => true;

  UserModel copyWith({
    String? accessToken,
    String? refreshToken,
    int? id,
    String? username,
    String? email,
    List<String>? roles,
    String? expiredAccessToken,
    String? expiredRefreshToken,
  }) {
    return UserModel(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      roles: roles ?? this.roles,
      expiredAccessToken: expiredAccessToken ?? this.expiredAccessToken,
      expiredRefreshToken: expiredRefreshToken ?? this.expiredRefreshToken,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'id': id,
      'username': username,
      'email': email,
      'roles': roles,
      'expiredAccessDate': expiredAccessToken,
      'expiredRefreshDate': expiredRefreshToken,
    };
  }
}
