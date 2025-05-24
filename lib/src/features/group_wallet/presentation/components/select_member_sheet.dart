import 'dart:async';

import 'package:flutter/material.dart';
import 'package:expensive_management/src/features/group_wallet/domain/models/user_member_datamodel.dart';
import 'package:expensive_management/src/core/common/extensions.dart';

class SelectMemberSheet extends StatefulWidget {
  const SelectMemberSheet({super.key, required this.members, this.selectedMembers = const []});
  final List<UserMemberData> members;
  final List<UserMemberData> selectedMembers;

  @override
  State<SelectMemberSheet> createState() => _SelectMemberSheetState();
}

class _SelectMemberSheetState extends State<SelectMemberSheet> {
  List<UserMemberData> _allMembers = [];
  List<UserMemberData> _filteredMembers = [];

  final TextEditingController _searchController = TextEditingController();
  final _debouncer = Debouncer();

  @override
  void initState() {
    super.initState();
    _allMembers = widget.members;
    if (widget.selectedMembers.isNotEmpty) {
      _allMembers = _allMembers.map((member) {
        final isSelected = widget.selectedMembers.any((selectedMember) => selectedMember.id == member.id);
        return member.copyWith(isSelected: isSelected);
      }).toList();
    }
    _filteredMembers = _allMembers;

    _searchController.addListener(() {
      _debouncer(() {
        _filterMembers();
      });
    });
  }

  void _filterMembers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMembers = _allMembers.where((member) {
        return member.fullName.toLowerCase().contains(query) ||
            member.email.toLowerCase().contains(query) ||
            member.username.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.theme.primaryColor,
        title: const Text('Chọn thành viên', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            final selected = _allMembers.where((member) => member.isSelected).toList();
            // if (selected.isNotEmpty) {
            Navigator.of(context).pop(selected);
            // } else {
            //   AppUtils.showSnackBar(context, 'Vui lòng chọn ít nhất một thành viên');
            // }
          },
        ),
      ),
      body: _allMembers.isEmpty
          ? const Center(
              child: Text('Không có thành viên nào'),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm thành viên',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  color: Colors.white,
                  child: Column(
                    children: _filteredMembers
                        .map((member) => CheckboxListTile(
                              title: Text(member.fullName),
                              subtitle: Text(member.email),
                              value: member.isSelected,
                              activeColor: Colors.green,
                              onChanged: (bool? value) {
                                setState(() {
                                  member.copyWith(isSelected: value ?? false);
                                  // Update the same member in _allMembers to maintain consistency
                                  final index = _allMembers.indexWhere((m) => m.id == member.id);
                                  if (index != -1) {
                                    _allMembers[index] = member.copyWith(isSelected: value ?? false);
                                  }
                                });
                              },
                              secondary: const CircleAvatar(child: Icon(Icons.person)),
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
    );
  }
}

class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 300)});

  void call(void Function() callback) {
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  void dispose() {
    _timer?.cancel();
  }
}
