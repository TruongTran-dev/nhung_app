import 'dart:convert';
import 'dart:developer';

import 'package:expensive_management/src/core/common/api_path.dart';
import 'package:expensive_management/src/core/common/extensions.dart';
import 'package:expensive_management/src/core/di/injection_container.dart';
import 'package:expensive_management/src/core/storage/shared_pref_storage.dart';
import 'package:expensive_management/src/core/utils/app_utils.dart';
import 'package:expensive_management/src/features/group_wallet/domain/models/group_wallet_datamodel.dart';
import 'package:expensive_management/src/features/group_wallet/presentation/components/group_wallet_detail.dart';
import 'package:expensive_management/src/shared/routes/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class SelectGroupBottomSheet extends StatefulWidget {
  const SelectGroupBottomSheet({
    super.key,
    this.selectedGroup,
  });
  final GroupWallet? selectedGroup;

  @override
  State<SelectGroupBottomSheet> createState() => _SelectGroupBottomSheetState();
}

class _SelectGroupBottomSheetState extends State<SelectGroupBottomSheet> {
  GroupWallet? selectedGroup;
  List<GroupWallet> groups = [];

  @override
  void initState() {
    super.initState();
    selectedGroup = widget.selectedGroup;
    _fetchWalletGroups().then((value) {
      setState(() {
        groups = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.theme.primaryColor,
        title: const Text('Chọn nhóm', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.pop(context, selectedGroup);
          },
        ),
        actions: [
          if (groups.isEmpty)
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: _onOpenCreateGroupWallet,
            ),
        ],
      ),
      body: groups.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Chưa có hội nhóm nào',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Vui lòng thêm mới hoặc tham gia một hội nhóm',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: groups.length,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemBuilder: (context, index) {
                final gWallet = groups[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: Colors.white,
                  child: InkWell(
                    onTap: () {
                      if (selectedGroup?.id == gWallet.id) {
                        setState(() {
                          selectedGroup = null; // Deselect if already selected
                        });
                      } else {
                        setState(() {
                          selectedGroup = gWallet; // Select the new group
                        });
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.grey.shade200,
                                child: Text(gWallet.name.isNotEmpty ? gWallet.name[0].toUpperCase() : 'G'),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      gWallet.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      gWallet.description,
                                      style: TextStyle(color: Colors.grey[600]),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              selectedGroup?.id == gWallet.id
                                  ? Icon(Icons.check_circle, color: context.theme.primaryColor)
                                  : const SizedBox.shrink(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
    );
  }

  void _onOpenCreateGroupWallet() async {
    // Navigate to create group wallet page
    final result = await context.push(AppRoutes.groupWalletDetail, extra: GroupWalletDetailProps());
    if (result != null && result is bool && result) {
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _fetchWalletGroups();
        });
      });
    }
  }

  Future<List<GroupWallet>> _fetchWalletGroups() async {
    try {
      final token = serviceLocator<AppPrefStorage>().getAccessToken();
      if (!await AppUtils.isValidToken() || token.isNullOrEmpty) {
        return [];
      }

      final response = await http.get(
        Uri.parse(ApiPath.apiDomain + ApiPath.group),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<GroupWallet> wallets = GroupWalletResponse.fromJson(responseData).content;
        return wallets;
      } else {
        throw Exception('Failed to load wallet groups: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching wallet groups: $e');
      return [];
    }
  }
}
