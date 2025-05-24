import 'package:expensive_management/src/core/common/extensions.dart';
import 'package:expensive_management/src/core/di/injection_container.dart';
import 'package:expensive_management/src/core/utils/app_utils.dart';
import 'package:expensive_management/src/features/my_wallet/domain/models/wallet.dart';
import 'package:expensive_management/src/features/my_wallet/presentation/bloc/bloc.dart';
import 'package:expensive_management/src/shared/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SelectWallets extends StatefulWidget {
  const SelectWallets({
    super.key,
    required this.wallets,
    this.isMultiSelect = false,
  });

  final List<Wallet> wallets;
  final bool isMultiSelect;

  @override
  State<SelectWallets> createState() => _SelectWalletsState();
}

class _SelectWalletsState extends State<SelectWallets> {
  late final WalletBloc _walletBloc;
  List<Wallet> listWalletSelected = [];

  @override
  void initState() {
    super.initState();
    _walletBloc = serviceLocator<WalletBloc>();
    _walletBloc.add(GetWalletsEvent());
    listWalletSelected = widget.wallets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.theme.primaryColor,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.of(context).pop(listWalletSelected);
          },
          child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 24),
        ),
        centerTitle: true,
        title: const Text(
          'Chọn tài khoản',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocConsumer<WalletBloc, WalletState>(
        bloc: _walletBloc,
        listener: (context, state) {
          if (state is GetListWalletErrorState) {
            AppUtils.showSnackBar(context, 'Có lỗi xảy ra khi lấy danh sách ví');
            // Navigator.pop(context);
          }
        },
        builder: (context, state) {
          if (state is WalletLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }
          final List<Wallet> listWallet = state is GetListWalletSuccessState ? state.wallets : [];

          final groupWallets = listWallet.where((w) => w.groupId != null).toList();
          final personalWallets = listWallet.where((w) => w.groupId == null).toList();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: listWallet.isEmpty
                ? Text(
                    'Không có dữ liệu tài khoản, vui lòng thêm tài khoản mới.',
                    style: TextStyle(fontSize: 16, color: context.theme.primaryColor),
                  )
                : SingleChildScrollView(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (personalWallets.isNotEmpty) ...[
                          _buildPesonalWalletsSelection(personalWallets),
                        ],
                        if (groupWallets.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _buildGroupWalletsSelection(groupWallets),
                        ],
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
            // : ListView.builder(
            //     itemCount: listWallet.length,
            //     itemBuilder: (context, index) {
            //       final Wallet item = listWallet[index];
            //       return Padding(
            //         padding: const EdgeInsets.only(top: 10),
            //         child: InkWell(
            //           onTap: () {
            //             setState(() {
            //               if (listWalletSelected.any((wallet) => wallet.id == item.id)) {
            //                 listWalletSelected.removeWhere((wallet) => wallet.id == item.id);
            //               } else {
            //                 listWalletSelected.add(item);
            //               }
            //             });
            //           },
            //           child: Container(
            //             height: 60,
            //             decoration: BoxDecoration(
            //               borderRadius: BorderRadius.circular(10),
            //               color: Colors.white,
            //             ),
            //             alignment: Alignment.center,
            //             child: Row(
            //               crossAxisAlignment: CrossAxisAlignment.center,
            //               children: [
            //                 Padding(
            //                   padding: const EdgeInsets.symmetric(horizontal: 10),
            //                   child: Icon(
            //                     !listWallet[index].accountType.isNullOrEmpty
            //                         ? getIconWallet(walletType: listWallet[index].accountType)
            //                         : Icons.help,
            //                     size: 30,
            //                     color: Colors.grey.withOpacity(0.6),
            //                   ),
            //                 ),
            //                 Expanded(
            //                   child: Column(
            //                     crossAxisAlignment: CrossAxisAlignment.start,
            //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //                     children: [
            //                       Text(
            //                         listWallet[index].name,
            //                         style: const TextStyle(fontSize: 16, color: Colors.black),
            //                       ),
            //                       Text(
            //                         '${listWallet[index].accountBalance} ${listWallet[index].currency}',
            //                         style: const TextStyle(fontSize: 14, color: Colors.grey),
            //                       ),
            //                     ],
            //                   ),
            //                 ),
            //                 Padding(
            //                   padding: const EdgeInsets.symmetric(horizontal: 10),
            //                   child: listWalletSelected.any((wallet) => wallet.id == item.id)
            //                       ? Icon(
            //                           Icons.check_circle_outline,
            //                           color: context.theme.primaryColor,
            //                           size: 24,
            //                         )
            //                       : const SizedBox(width: 24),
            //                 ),
            //               ],
            //             ),
            //           ),
            //         ),
            //       );
            //     },
            //   ),
          );
        },
      ),
    );
  }

  Widget _buildPesonalWalletsSelection(List<Wallet> personalWallets) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: context.theme.primaryColor, width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tài khoản cá nhân (có thể chọn nhiều)',
            style: TextStyle(fontSize: 16, color: context.theme.primaryColor),
          ),
          if (widget.isMultiSelect)
            Container(
              decoration: BoxDecoration(
                color: Colors.blueGrey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              margin: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Chọn tất cả',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Checkbox(
                    value: personalWallets.isNotEmpty &&
                        personalWallets
                            .every((wallet) => listWalletSelected.any((selected) => selected.id == wallet.id)),
                    onChanged: (bool? value) {
                      if (value == true) {
                        // Remove any group wallets first
                        listWalletSelected.removeWhere((wallet) => wallet.groupId != null);
                        // Add all wallets that aren't already selected
                        for (final wallet in personalWallets) {
                          if (!listWalletSelected.any((selected) => selected.id == wallet.id)) {
                            listWalletSelected.add(wallet);
                          }
                        }
                      } else {
                        // Remove all personal wallets
                        listWalletSelected
                            .removeWhere((selected) => personalWallets.any((wallet) => wallet.id == selected.id));
                      }
                      setState(() {});
                    },
                    activeColor: context.theme.primaryColor,
                  ),
                ],
              ),
            ),
          Column(
            spacing: 8,
            children: personalWallets.map((wallet) {
              return _buildItemWallet(
                wallet: wallet,
                onTap: () {
                  // If multi-select is enabled, toggle the selection
                  if (widget.isMultiSelect) {
                    listWalletSelected.removeWhere((wallet) => wallet.groupId != null);
                    if (listWalletSelected.any((w) => w.id == wallet.id)) {
                      listWalletSelected.removeWhere((w) => w.id == wallet.id);
                    } else {
                      listWalletSelected.add(wallet);
                    }
                  } else {
                    if (listWalletSelected.any((w) => w.id == wallet.id)) {
                      listWalletSelected.removeWhere((w) => w.id == wallet.id);
                    } else {
                      listWalletSelected.clear();
                      listWalletSelected.add(wallet);
                    }
                  }

                  setState(() {});
                },
                isSelected: listWalletSelected.any((w) => w.id == wallet.id),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Map<int, List<Wallet>> _groupWalletsByGroupId(List<Wallet> wallets) {
    // Group wallets by groupId
    Map<int, List<Wallet>> groupedWallets = {};

    for (var wallet in wallets) {
      if (wallet.groupId != null) {
        if (!groupedWallets.containsKey(wallet.groupId)) {
          groupedWallets[wallet.groupId!] = [];
        }
        groupedWallets[wallet.groupId]!.add(wallet);
      }
    }

    // Convert map to list of wallet groups
    return groupedWallets;
  }

  Widget _buildGroupWalletsSelection(List<Wallet> groupWallets) {
    Map<int, List<Wallet>> _listGroup = _groupWalletsByGroupId(groupWallets);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: context.theme.primaryColor, width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tài khoản nhóm (chỉ chọn một nhóm)',
            style: TextStyle(fontSize: 16, color: context.theme.primaryColor),
          ),
          ..._listGroup.entries.map((entry) {
            final groupId = entry.key;
            final groupName = entry.value.first.groupName;
            final walletsInGroup = entry.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 8,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: context.theme.primaryColor, width: 1)),
                  ),
                  child: Text(
                    'Nhóm "${groupName}"',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ...walletsInGroup.map((wallet) {
                  return _buildItemWallet(
                    wallet: wallet,
                    onTap: () {
                      listWalletSelected.removeWhere((w) => w.groupId == null || w.groupId != groupId);
                      setState(() {
                        if (listWalletSelected.any((w) => w.id == wallet.id)) {
                          // If this wallet is already selected, just remove it
                          listWalletSelected.removeWhere((w) => w.id == wallet.id);
                        } else {
                          // Remove wallets from other groups
                          listWalletSelected.removeWhere((w) => w.groupId != null && w.groupId != groupId);

                          // Add this wallet
                          listWalletSelected.add(wallet);
                        }
                      });
                    },
                    isSelected: listWalletSelected.any((w) => w.id == wallet.id),
                  );
                }),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildItemWallet({
    required Wallet wallet,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.blueGrey.withValues(alpha: 0.2),
        ),
        alignment: Alignment.center,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Icon(
                !wallet.accountType.isNullOrEmpty ? getIconWallet(walletType: wallet.accountType) : Icons.help,
                size: 30,
                color: Colors.grey.withOpacity(0.6),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    wallet.name,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  Text(
                    '${wallet.accountBalance.currencyFormat()} ${wallet.currency}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: isSelected
                  ? Icon(
                      Icons.check_circle_outline,
                      color: context.theme.primaryColor,
                      size: 24,
                    )
                  : const SizedBox(width: 24),
            ),
          ],
        ),
      ),
    );
  }
}
