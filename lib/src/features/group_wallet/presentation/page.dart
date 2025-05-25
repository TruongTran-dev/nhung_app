import 'dart:convert';
import 'dart:developer';

import 'package:expensive_management/data/api/api_path.dart';
import 'package:expensive_management/src/core/common/extensions.dart';
import 'package:expensive_management/src/core/di/injection_container.dart';
import 'package:expensive_management/src/core/storage/shared_pref_storage.dart';
import 'package:expensive_management/src/core/utils/app_utils.dart';
import 'package:expensive_management/src/features/group_wallet/domain/models/group_wallet_datamodel.dart';
import 'package:expensive_management/src/shared/routes/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import 'components/group_wallet_detail.dart';

class GroupWalletPage extends StatefulWidget {
  const GroupWalletPage({super.key});

  @override
  State<GroupWalletPage> createState() => _GroupWalletPageState();
}

class _GroupWalletPageState extends State<GroupWalletPage> {
  @override
  void initState() {
    super.initState();
    // _fetchUsers();
    _fetchWalletGroups();
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

  void _onOpenCreateGroupWallet() async {
    // Navigate to create group wallet page
    final result = await context.push(AppRoutes.groupWalletDetail, extra: GroupWalletDetailProps());
    log("Create group wallet result: $result");
    if (result != null && result is bool && result) {
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _fetchWalletGroups();
        });
      });
    }
  }

  void _onSeeDetail(GroupWallet gWallet) async {
    final result = await context.push(
      AppRoutes.groupWalletDetail,
      extra: GroupWalletDetailProps(groupWallet: gWallet, isEdit: true),
    );
    log("Group wallet detail result: $result");

    if (result != null && result is bool && result) {
      // Add a 1-second delay before refreshing data
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _fetchWalletGroups();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.theme.primaryColor,
        title: const Text('Nhóm chi tiêu chung', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _onOpenCreateGroupWallet,
          ),
        ],
      ),
      body: FutureBuilder<List<GroupWallet>>(
        future: _fetchWalletGroups(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Không có nhóm nào',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tạo nhóm để quản lý chi tiêu cùng bạn bè, gia đình',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _onOpenCreateGroupWallet,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: const Text(
                      'Tạo nhóm mới',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemBuilder: (context, index) {
              final gWallet = snapshot.data![index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: Colors.white,
                child: InkWell(
                  onTap: () {
                    // Handle tap on the card
                    _onSeeDetail(gWallet);
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
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: () => _onSeeDetail(gWallet),
                            ),
                          ],
                        ),
                        // const SizedBox(height: 8),
                        // ExpansionTile(
                        //   title:
                        //       Text('Thành viên(${wallet.groupMembers.length})', style: const TextStyle(fontSize: 14)),
                        //   tilePadding: EdgeInsets.zero,
                        //   childrenPadding: const EdgeInsets.only(left: 16),
                        //   children: wallet.groupMembers.map((member) {
                        //     return ListTile(
                        //       contentPadding: EdgeInsets.zero,
                        //       dense: true,
                        //       leading: CircleAvatar(
                        //         radius: 14,
                        //         backgroundColor: Colors.blue.shade100,
                        //         child: Text(
                        //           member.username.isNotEmpty ? member.username[0].toUpperCase() : 'U',
                        //           style: const TextStyle(fontSize: 12),
                        //         ),
                        //       ),
                        //       title: Text(member.username, style: const TextStyle(fontSize: 14)),
                        //     );
                        //   }).toList(),
                        // ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
