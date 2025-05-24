import 'package:equatable/equatable.dart';

class UserMemberData extends Equatable {
  final int id;
  final String email;
  final String username;
  final String fullName;
  final bool isSelected;

  const UserMemberData({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
    this.isSelected = false,
  });

  @override
  List<Object?> get props => [id, email, username, fullName, isSelected];

  factory UserMemberData.fromJson(Map<String, dynamic> json) {
    return UserMemberData(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      fullName: json['fullName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'fullName': fullName,
    };
  }

  @override
  bool get stringify => true;

  UserMemberData copyWith({
    int? id,
    String? email,
    String? username,
    String? fullName,
    bool? isSelected,
  }) {
    return UserMemberData(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
