import 'package:expensive_management/src/core/common/extensions.dart';
import 'package:expensive_management/src/core/di/injection_container.dart';
import 'package:expensive_management/src/core/utils/app_utils.dart';
import 'package:expensive_management/src/features/my_wallet/domain/models/wallet.dart';
import 'package:expensive_management/src/features/my_wallet/presentation/bloc/bloc.dart';
import 'package:expensive_management/src/shared/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SelectWalletCollection extends StatefulWidget {
  const SelectWalletCollection({super.key, this.selectedWallet});
  final Wallet? selectedWallet;

  @override
  State<SelectWalletCollection> createState() => _SelectWalletCollectionState();
}

class _SelectWalletCollectionState extends State<SelectWalletCollection> {
  final _walletBloc = serviceLocator.get<WalletBloc>();

  Wallet? selectedWallet;

  @override
  void initState() {
    super.initState();
    selectedWallet = widget.selectedWallet;
    _walletBloc.add(GetWalletsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.theme.primaryColor,
        elevation: 0,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context, selectedWallet);
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
      body: BlocConsumer(
        bloc: _walletBloc,
        listener: (context, state) {
          if (state is GetListWalletErrorState) {
            AppUtils.showSnackBar(context, 'Có lỗi xảy ra khi lấy danh sách ví');
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          if (state is WalletLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }
          List<Wallet> listWallet = state is GetListWalletSuccessState ? state.wallets : [];

          List<Wallet> personalWallets = listWallet.where((wallet) => wallet.groupId == null).toList();
          List<Wallet> groupWallets = listWallet.where((wallet) => wallet.groupId != null).toList();

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
          );
        },
      ),
    );
  }

  Widget _buildPesonalWalletsSelection(List<Wallet> personalWallets) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        // color: Colors.white,
        border: Border.all(color: context.theme.primaryColor, width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Text(
            'Tài khoản cá nhân',
            style: TextStyle(fontSize: 16, color: context.theme.primaryColor),
          ),
          Column(
            spacing: 8,
            children: personalWallets.map(_itemWallet).toList(),
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
    Map<int, List<Wallet>> listGroup = _groupWalletsByGroupId(groupWallets);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: context.theme.primaryColor, width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tài khoản nhóm',
            style: TextStyle(fontSize: 16, color: context.theme.primaryColor),
          ),
          ...listGroup.entries.map((entry) {
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
                    'Nhóm "$groupName"',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ...walletsInGroup.map(_itemWallet),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _itemWallet(Wallet item) {
    return InkWell(
      onTap: () {
        selectedWallet = item;
        setState(() {});
        Navigator.pop(context, selectedWallet);
      },
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        alignment: Alignment.center,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Icon(
                !item.accountType.isNullOrEmpty ? getIconWallet(walletType: item.accountType) : Icons.help,
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
                    item.name,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  Text(
                    '${item.accountBalance.currencyFormat()} ${item.currency}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (selectedWallet?.id == item.id)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(
                  Icons.check_circle_outline,
                  color: context.theme.primaryColor,
                  size: 24,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
