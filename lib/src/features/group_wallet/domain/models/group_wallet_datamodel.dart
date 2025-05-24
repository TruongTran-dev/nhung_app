import 'package:equatable/equatable.dart';

class GroupWalletResponse {
  final List<GroupWallet> content;
  final int pageNumber;
  final int pageSize;
  final int totalPage;
  final int totalRecord;

  const GroupWalletResponse({
    required this.content,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPage,
    required this.totalRecord,
  });

  factory GroupWalletResponse.fromJson(Map<String, dynamic> json) {
    return GroupWalletResponse(
      content: (json['content'] as List).map((e) => GroupWallet.fromJson(e)).toList(),
      pageNumber: json['pageNumber'],
      pageSize: json['pageSize'],
      totalPage: json['totalPage'],
      totalRecord: json['totalRecord'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content.map((e) => e.toJson()).toList(),
      'pageNumber': pageNumber,
      'pageSize': pageSize,
      'totalPage': totalPage,
      'totalRecord': totalRecord,
    };
  }
}

class GroupWallet extends Equatable {
  final int id;
  final String name;
  final String description;
  final List<GroupMember> groupMembers;

  const GroupWallet({
    required this.id,
    required this.name,
    required this.description,
    this.groupMembers = const [],
  });

  @override
  List<Object?> get props => [id, name, description, groupMembers];

  factory GroupWallet.fromJson(Map<String, dynamic> json) {
    return GroupWallet(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      groupMembers: json['groupMembers'] != null
          ? (json['groupMembers'] as List).map((e) => GroupMember.fromJson(e)).toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'groupMembers': groupMembers.map((e) => e.toJson()).toList(),
    };
  }
}

class GroupMember extends Equatable {
  final int groupId;
  final String groupRole;
  final int userId;
  final String username;

  const GroupMember({
    required this.groupId,
    required this.groupRole,
    required this.userId,
    required this.username,
  });

  @override
  List<Object> get props => [groupId, groupRole, userId, username];

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      groupId: json['groupId'],
      groupRole: json['groupRole'],
      userId: json['userId'],
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'groupRole': groupRole,
      'userId': userId,
      'username': username,
    };
  }
}
