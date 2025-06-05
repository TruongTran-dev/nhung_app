import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:expensive_management/src/core/common/api_path.dart';
import 'package:expensive_management/src/core/common/extensions.dart';
import 'package:expensive_management/src/core/di/injection_container.dart';
import 'package:expensive_management/src/core/storage/shared_pref_storage.dart';
import 'package:expensive_management/src/core/utils/app_utils.dart';
import 'package:expensive_management/src/features/group_wallet/domain/models/group_wallet_datamodel.dart';
import 'package:expensive_management/src/features/group_wallet/domain/models/user_member_datamodel.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'select_member_sheet.dart';

class GroupWalletDetailProps extends Equatable {
  final bool isEdit;
  final GroupWallet? groupWallet;

  const GroupWalletDetailProps({
    this.isEdit = false,
    this.groupWallet,
  });

  @override
  List<Object?> get props => [isEdit, groupWallet];
  @override
  bool get stringify => true;

  GroupWalletDetailProps copyWith({
    bool? isEdit,
    GroupWallet? groupWallet,
  }) {
    return GroupWalletDetailProps(
      isEdit: isEdit ?? this.isEdit,
      groupWallet: groupWallet ?? this.groupWallet,
    );
  }
}

class GroupWalletDetailPage extends StatefulWidget {
  const GroupWalletDetailPage({super.key, required this.props});
  final GroupWalletDetailProps props;

  @override
  State<GroupWalletDetailPage> createState() => _GroupWalletDetailPageState();
}

class _GroupWalletDetailPageState extends State<GroupWalletDetailPage> {
  final List<UserMemberData> _selectedMembers = [];
  List<UserMemberData> _allMembers = [];
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<int> _memberIdsPrevious = [];

  bool isLoading = false;

  bool isHasUpdatePermission = false;

  @override
  void initState() {
    super.initState();
    _getUserMembers();
  }

  void _getUserMembers() async {
    if (widget.props.isEdit && widget.props.groupWallet != null) {
      _groupNameController.text = widget.props.groupWallet!.name;
      _descriptionController.text = widget.props.groupWallet!.description;
      final groupMembers = widget.props.groupWallet!.groupMembers;
      _memberIdsPrevious = groupMembers.map((member) => member.userId).toList();

      final leaderMember = groupMembers.firstWhereOrNull((m) => m.groupRole == 'LEADER');
      final currentUserID = serviceLocator<AppPrefStorage>().getUserId();
      isHasUpdatePermission = leaderMember?.userId.toString() == currentUserID;
    } else {
      isHasUpdatePermission = true;
    }

    _allMembers = await _fetchUsers();

    // Update _selectedMembers with members from _allMembers that are selected
    if (_memberIdsPrevious.isNotEmpty) {
      setState(() {
        _selectedMembers.clear();
        _selectedMembers.addAll(_allMembers.where((member) => member.isSelected));
      });
    }
  }

  String? _getWalletMemberRole(UserMemberData member) {
    final groupMembers = widget.props.groupWallet?.groupMembers ?? [];
    final groupMember = groupMembers.firstWhereOrNull((m) => m.userId == member.id);
    return groupMember?.groupRole;
  }

  @override
  void didUpdateWidget(GroupWalletDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _getUserMembers();
  }

  Future<List<UserMemberData>> _fetchUsers() async {
    try {
      final token = serviceLocator<AppPrefStorage>().getAccessToken();
      if (!await AppUtils.isValidToken() || token.isNullOrEmpty) {
        return [];
      }

      final response = await http.get(
        Uri.parse('${ApiPath.apiDomain}/api/admin/users').replace(queryParameters: {"isMobile": "true"}),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token, // assuming you have a function to get the token
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['content'] as List;
        final members = data.map((json) => UserMemberData.fromJson(json)).toList();

        return members.map((member) {
          // Check if the member is already selected
          final isSelected = _memberIdsPrevious.contains(member.id);
          if (!_selectedMembers.map((e) => e.id).contains(member.id) && isSelected) {
            _selectedMembers.add(member.copyWith(isSelected: isSelected));
          } else if (_selectedMembers.map((e) => e.id).contains(member.id) && !isSelected) {
            _selectedMembers.removeWhere((e) => e.id == member.id);
          } else if (_selectedMembers.map((e) => e.id).contains(member.id) && isSelected) {
            _selectedMembers.removeWhere((e) => e.id == member.id);
            _selectedMembers.add(member.copyWith(isSelected: isSelected));
          }

          return member.copyWith(isSelected: isSelected);
        }).toList();
      } else {
        // throw Exception('Failed to load users: ${response.statusCode}');
        log('Failed to load users: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      log('Error fetching users: $e');
      return [];
    }
  }

  Future<void> _createGroupWallet() async {
    if (_groupNameController.text.isEmpty) {
      AppUtils.showSnackBar(context, 'Vui lòng nhập tên hội nhóm');
      return;
    }
    if (_descriptionController.text.isEmpty) {
      AppUtils.showSnackBar(context, 'Vui lòng nhập mô tả nhóm');
      return;
    }
    if (_selectedMembers.isEmpty) {
      AppUtils.showSnackBar(context, 'Vui lòng chọn thành viên');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final token = serviceLocator<AppPrefStorage>().getAccessToken();
      if (!await AppUtils.isValidToken() || token.isNullOrEmpty) {
        if (!mounted) return;
        AppUtils.showSnackBar(context, 'Token không hợp lệ. Vui lòng đăng nhập lại.');
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Get selected member usernames
      final List<String> memberUserNames =
          _selectedMembers.where((member) => member.isSelected).map((member) => member.username).toList();

      // Prepare request body
      final Map<String, dynamic> requestBody = {
        'name': _groupNameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'memberUserNames': memberUserNames,
      };
      log("Request body: $requestBody");

      final response = await http.post(
        Uri.parse(ApiPath.apiDomain + ApiPath.group),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (!mounted) return;
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        log("Create group wallet response data: $responseData");
        AppUtils.showSnackBar(context, 'Tạo ví hội nhóm thành công');
        _clearSession();
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['message'] ?? 'Đã xảy ra lỗi khi tạo ví nhóm';
        if (!mounted) return;
        AppUtils.showSnackBar(context, errorMessage);
      }
    } catch (e) {
      log('Error creating group wallet: $e');
      AppUtils.showSnackBar(context, 'Đã xảy ra lỗi khi tạo ví nhóm');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateGroupWallet() async {
    if (_groupNameController.text.isEmpty) {
      AppUtils.showSnackBar(context, 'Vui lòng nhập tên hội nhóm');
      return;
    }
    if (_descriptionController.text.isEmpty) {
      AppUtils.showSnackBar(context, 'Vui lòng nhập mô tả nhóm');
      return;
    }
    if (_selectedMembers.isEmpty) {
      AppUtils.showSnackBar(context, 'Vui lòng chọn thành viên');
      return;
    }

    if (widget.props.groupWallet == null) return;

    final oldName = widget.props.groupWallet!.name;
    final oldDescription = widget.props.groupWallet!.description;
    final newIds = _selectedMembers.where((member) => member.isSelected).map((member) => member.id).toList();

    // Check if there are any changes to display in the comparison popup
    final bool nameChanged = _groupNameController.text.trim() != oldName;
    final bool descriptionChanged = _descriptionController.text.trim() != oldDescription;
    final bool membersChanged = !_compareMemberLists(_memberIdsPrevious, newIds);

    // If nothing changed, show a message and return
    if (!nameChanged && !descriptionChanged && !membersChanged) {
      AppUtils.showSnackBar(context, 'Không có thay đổi nào để cập nhật');
      return;
    }

    // Show a dialog to compare changes
    final hasUpdate = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Xác nhận thay đổi'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (nameChanged) ...[
                const Text('Tên hội nhóm:', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    const Text('Cũ: ', style: TextStyle(color: Colors.red)),
                    Flexible(child: Text(oldName)),
                  ],
                ),
                Row(
                  children: [
                    const Text('Mới: ', style: TextStyle(color: Colors.green)),
                    Flexible(child: Text(_groupNameController.text.trim())),
                  ],
                ),
                const SizedBox(height: 10),
              ],
              if (descriptionChanged) ...[
                const Text('Mô tả:', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    const Text('Cũ: ', style: TextStyle(color: Colors.red)),
                    Flexible(child: Text(oldDescription)),
                  ],
                ),
                Row(
                  children: [
                    const Text('Mới: ', style: TextStyle(color: Colors.green)),
                    Flexible(child: Text(_descriptionController.text.trim())),
                  ],
                ),
                const SizedBox(height: 10),
              ],
              if (membersChanged) ...[
                const Text('Thành viên:', style: TextStyle(fontWeight: FontWeight.bold)),

                // Create a table to compare members
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    children: [
                      // Table header
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        color: Colors.grey.shade100,
                        child: const Row(
                          children: [
                            Expanded(child: Text('Tên thành viên', style: TextStyle(fontWeight: FontWeight.bold))),
                            SizedBox(width: 8),
                            Text('Trạng thái', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),

                      // Added members
                      ...newIds.where((id) => !_memberIdsPrevious.contains(id)).map((id) {
                        final member = _allMembers.firstWhere((m) => m.id == id);
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border(top: BorderSide(color: Colors.grey.shade300)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child:
                                    Text('${member.fullName}\n${member.email}', style: const TextStyle(fontSize: 13)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text('Thêm mới', style: TextStyle(color: Colors.green, fontSize: 12)),
                              ),
                            ],
                          ),
                        );
                      }),

                      // Removed members
                      ..._memberIdsPrevious.where((id) => !newIds.contains(id)).map((id) {
                        final member = _allMembers.firstWhere((m) => m.id == id,
                            orElse: () =>
                                UserMemberData(id: -1, username: 'Unknown', fullName: 'Unknown', email: 'Unknown'));
                        return member.id == -1
                            ? const SizedBox.shrink()
                            : Container(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                decoration: BoxDecoration(
                                  border: Border(top: BorderSide(color: Colors.grey.shade300)),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${member.fullName}\n${member.email}',
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text('Đã xóa', style: TextStyle(color: Colors.red, fontSize: 12)),
                                    ),
                                  ],
                                ),
                              );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xác nhận', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );

    if (hasUpdate == null || hasUpdate) {
      setState(() {
        isLoading = true;
      });

      try {
        final token = serviceLocator<AppPrefStorage>().getAccessToken();
        if (!await AppUtils.isValidToken() || token.isNullOrEmpty) {
          if (!mounted) return;
          AppUtils.showSnackBar(context, 'Token không hợp lệ. Vui lòng đăng nhập lại.');
          setState(() {
            isLoading = false;
          });
          return;
        }

        // Get selected member usernames
        final List<String> memberUserNames =
            _selectedMembers.where((member) => member.isSelected).map((member) => member.username).toList();

        // Prepare request body
        final Map<String, dynamic> requestBody = {
          'name': _groupNameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'memberUserNames': memberUserNames,
        };
        log("Request body: $requestBody");

        final response = await http.put(
          Uri.parse('${ApiPath.apiDomain}${ApiPath.group}/${widget.props.groupWallet!.id}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': token,
          },
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          if (!mounted) return;
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          log("Update group wallet response data: $responseData");
          AppUtils.showSnackBar(context, 'Cập nhật ví hội nhóm thành công');
          // Navigator.of(context).pop(true);
        } else {
          final errorBody = jsonDecode(response.body);
          final errorMessage = errorBody['message'] ?? 'Đã xảy ra lỗi khi cập nhật ví nhóm';
          if (!mounted) return;
          AppUtils.showSnackBar(context, errorMessage);
        }
      } catch (e) {
        log('Error updating group wallet: $e');
        if (!mounted) return;
        AppUtils.showSnackBar(context, 'Đã xảy ra lỗi khi cập nhật ví nhóm');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  bool _compareMemberLists(List<int> oldList, List<int> newList) {
    if (oldList.length != newList.length) return false;
    for (int id in oldList) {
      if (!newList.contains(id)) return false;
    }
    return true;
  }

  Future<void> _deleteGroupWallet() async {
    if (!mounted) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa ví hội nhóm này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (widget.props.groupWallet == null) {
        if (!mounted) return;
        AppUtils.showSnackBar(context, 'Không có ví hội nhóm để xóa');
        return;
      }
      setState(() {
        isLoading = true;
      });

      try {
        final token = serviceLocator<AppPrefStorage>().getAccessToken();
        if (!await AppUtils.isValidToken() || token.isNullOrEmpty) {
          if (!mounted) return;
          AppUtils.showSnackBar(context, 'Token không hợp lệ. Vui lòng đăng nhập lại.');
          return;
        }

        final response = await http.delete(
          Uri.parse('${ApiPath.apiDomain}${ApiPath.group}/${widget.props.groupWallet!.id}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': token,
          },
        );

        if (response.statusCode == 200 || response.statusCode == 204) {
          if (!mounted) return;
          AppUtils.showSnackBar(context, 'Xóa ví hội nhóm thành công');
          Navigator.of(context).pop(true);
        } else {
          final errorBody = jsonDecode(response.body);
          final errorMessage = errorBody['message'] ?? 'Đã xảy ra lỗi khi xóa ví nhóm';
          if (!mounted) return;
          AppUtils.showSnackBar(context, errorMessage);
        }
      } catch (e) {
        log('Error deleting group wallet: $e');
        if (!mounted) return;
        AppUtils.showSnackBar(context, 'Đã xảy ra lỗi khi xóa ví nhóm');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _clearSession() {
    _groupNameController.clear();
    _descriptionController.clear();
    _selectedMembers.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.theme.primaryColor,
        title: Text(
          widget.props.isEdit ? "Thông tin hội nhóm " : 'Tạo hội nhóm',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop(true);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Group Name Field
            TextField(
              controller: _groupNameController,
              enabled: isHasUpdatePermission,
              decoration: InputDecoration(
                labelText: 'Tên hội nhóm',
                hintText: 'Nhập tên hội nhóm',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.group),
                filled: !isHasUpdatePermission,
                fillColor: !isHasUpdatePermission ? Colors.grey.shade100 : null,
              ),
            ),
            const SizedBox(height: 16),

            // Description Field
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              enabled: isHasUpdatePermission,
              decoration: InputDecoration(
                labelText: 'Mô tả nhóm',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.description),
                filled: !isHasUpdatePermission,
                fillColor: !isHasUpdatePermission ? Colors.grey.shade100 : null,
              ),
            ),
            const SizedBox(height: 24),

            // Member Selection Section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Vai trò của bạn:",
                    textAlign: TextAlign.start,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.person, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${serviceLocator<AppPrefStorage>().getUserName()} (Bạn)",
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                serviceLocator<AppPrefStorage>().getUserEmail(),
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isHasUpdatePermission ? Colors.blue.shade100 : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isHasUpdatePermission ? "Nhóm trưởng" : "Thành viên",
                            style: TextStyle(
                              color: isHasUpdatePermission ? Colors.blue : Colors.grey,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _showBottomSelectMemberSheet,
                    child: Row(
                      children: const [
                        Expanded(
                          child: Text(
                            'Thành viên',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_outlined, size: 16),
                      ],
                    ),
                  ),
                  if (_selectedMembers.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ..._selectedMembers.mapIndexed((index, member) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            // User Avatar
                            const CircleAvatar(radius: 20, child: Icon(Icons.person)),
                            const SizedBox(width: 12),

                            // User Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    member.fullName ?? member.username,
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    "Email: ${member.email}",
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                  if (widget.props.isEdit)
                                    Text(
                                      _getWalletMemberRole(member) == "LEADER" ? "(Nhóm trưởng)" : "(Thành viên)",
                                      style: TextStyle(
                                        color: _getWalletMemberRole(member) == "LEADER" ? Colors.blue : Colors.grey,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // Checkbox
                            Checkbox(
                              value: member.isSelected,
                              activeColor: Colors.green,
                              onChanged: widget.props.isEdit && !isHasUpdatePermission
                                  ? null // Disable checkbox when in edit mode without permission
                                  : (bool? value) {
                                      // Update the member in the _selectedMembers list
                                      if (index != -1) {
                                        _selectedMembers[index] = member.copyWith(isSelected: value ?? false);
                                      }

                                      // Also update the same member in _allMembers to maintain consistency
                                      final allMembersIndex = _allMembers.indexWhere((m) => m.id == member.id);
                                      if (allMembersIndex != -1) {
                                        _allMembers[allMembersIndex] = _allMembers[allMembersIndex].copyWith(
                                          isSelected: value ?? false,
                                        );
                                      }
                                      setState(() {});
                                    },
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            if (widget.props.isEdit && isHasUpdatePermission)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _updateGroupWallet,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        backgroundColor: context.theme.primaryColor,
                      ),
                      child: const Text(
                        'Cập nhật',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _deleteGroupWallet,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        'Xóa',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            if (isHasUpdatePermission && !widget.props.isEdit)
              ElevatedButton(
                onPressed: _createGroupWallet,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  backgroundColor: context.theme.primaryColor,
                ),
                child: const Text(
                  'Tạo ví nhóm',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showBottomSelectMemberSheet() async {
    if (!mounted || !isHasUpdatePermission) return;

    final selectedMembersResult = await showModalBottomSheet<List<UserMemberData>>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.65,
      ),
      builder: (context) => SelectMemberSheet(members: _allMembers, selectedMembers: _selectedMembers),
    );

    if (selectedMembersResult != null) {
      _selectedMembers.clear();
      _selectedMembers.addAll(selectedMembersResult);
      setState(() {});
    }
  }
}
