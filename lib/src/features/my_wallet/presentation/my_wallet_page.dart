import 'package:expensive_management/app/app_colors.dart';
import 'package:expensive_management/src/core/common/extensions.dart';
import 'package:expensive_management/src/core/di/injection_container.dart';
import 'package:expensive_management/src/core/utils/app_utils.dart';
import 'package:expensive_management/src/features/my_wallet/presentation/bloc/bloc.dart';
import 'package:expensive_management/src/shared/routes/router.dart';
import 'package:expensive_management/src/shared/utils/screen_utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expensive_management/src/features/my_wallet/domain/models/wallet.dart';
import 'package:expensive_management/src/shared/utils/app_constants.dart';
import 'package:expensive_management/src/core/storage/shared_pref_storage.dart';
import 'package:expensive_management/src/shared/utils/utils.dart';
import 'package:go_router/go_router.dart';

class MyWalletPage extends StatefulWidget {
  const MyWalletPage({super.key});

  @override
  State<MyWalletPage> createState() => _MyWalletPageState();
}

class _MyWalletPageState extends State<MyWalletPage> {
  late WalletBloc _walletBloc;

  @override
  void initState() {
    _walletBloc = serviceLocator<WalletBloc>();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _reloadPage() {
    _walletBloc.add(GetWalletsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: AppColors.secondary,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Danh sách tài khoản ví',
          style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocConsumer<WalletBloc, WalletState>(
        bloc: _walletBloc,
        listener: (context, state) {
          if (state is GetListWalletErrorState) {
            showMessage1OptionDialog(context, state.message);
          }
          if (state is DeleteWalletErrorState) {
            showMessage1OptionDialog(context, state.message);
          }
          if (state is DeleteWalletSuccessState) {
            AppUtils.showSnackBar(context, 'Xoá tài khoản thành công');
            _reloadPage();
          }
        },
        builder: (context, state) {
          final isLoading = state is WalletLoadingState;
          return isLoading
              ? const Center(child: CircularProgressIndicator.adaptive())
              : _body(
                  state is GetListWalletSuccessState ? state.wallets : [],
                  state is GetListWalletSuccessState ? state.moneyTotal : 0,
                );
        },
      ),
    );
  }

  Widget _body(List<Wallet> listWallet, double moneyTotal) {
    final personalWallets = listWallet.where((wallet) => wallet.groupId == null).toList();
    final groupWallets = listWallet.where((wallet) => wallet.groupId != null).toList();
    String currency = serviceLocator<AppPrefStorage>().getCurrency();

    return RefreshIndicator(
      onRefresh: () async => _reloadPage(),
      // child: ListView.builder(
      //   padding: const EdgeInsets.symmetric(horizontal: 16),
      //   itemCount: listWallet.length + 2, // +2 for the header and add button
      //   itemBuilder: (context, index) {
      //     // First item (index 0) - Total money display
      //     if (index == 0) {
      //       return Padding(
      //         padding: const EdgeInsets.only(bottom: 16),
      //         child: Container(
      //           decoration: BoxDecoration(
      //             borderRadius: BorderRadius.circular(10),
      //             color: Theme.of(context).colorScheme.surface,
      //           ),
      //           child: Padding(
      //             padding: const EdgeInsets.symmetric(vertical: 16),
      //             child: Center(
      //               child: Text(
      //                 'Tổng tiền : ${formatterDouble(moneyTotal.toInt())} $currency',
      //                 style: const TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
      //               ),
      //             ),
      //           ),
      //         ),
      //       );
      //     }
      //     // Last item - Add wallet button
      //     if (index == listWallet.length + 1) {
      //       return _addItemWallet();
      //     }
      //     // Wallet items (index 1 to length)
      //     return _buildItemWallet(
      //       listWallet[index - 1], // -1 because index 0 is the header
      //       index: index,
      //     );
      //   },
      // ),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Center(
                child: Text(
                  'Tổng tiền : ${formatterDouble(moneyTotal.toInt())} $currency',
                  style: const TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            if (listWallet.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Bạn chưa có tài khoản ví nào.\nHãy thêm tài khoản để quản lý chi tiêu của bạn.',
                    style: TextStyle(fontSize: 16, color: Colors.grey.withOpacity(0.7)),
                  ),
                ),
              ),
            if (personalWallets.isNotEmpty) _buildPersonalWalletsSection(personalWallets),
            if (groupWallets.isNotEmpty) _buildGroupWalletsSection(groupWallets),
            _addItemWallet(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalWalletsSection(List<Wallet> personalWallets) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 10,
          children: [
            Text(
              'Tài khoản ví cá nhân',
              style: TextStyle(fontSize: 18, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
            ),
            ...personalWallets.mapIndexed((index, wallet) => _buildItemWallet(wallet, index: index)),
          ],
        ),
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

  Widget _buildGroupWalletsSection(List<Wallet> groupWallets) {
    final groupedWallets = _groupWalletsByGroupId(groupWallets);

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Tài khoản ví nhóm',
              style: TextStyle(fontSize: 18, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
            ),
            ...groupedWallets.entries.map((entry) {
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
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      spacing: 8,
                      children: walletsInGroup
                          .mapIndexed(
                            (index, wallet) => _buildItemWallet(wallet, index: index),
                          )
                          .toList(),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  void _onGoToAddWallet() {
    context.push(AppRoutes.addWallet);
  }

  void _onGoToWalletDetail(Wallet wallet) {
    context.push(AppRoutes.walletDetail, extra: wallet).then((_) {
      // Reload data when coming back from wallet detail
      _walletBloc.add(GetWalletsEvent());
    });
  }

  void _onGoToEditWallet(Wallet wallet) {
    context.push(AppRoutes.updateWallet, extra: wallet).then((_) {
      // Reload data when coming back from wallet detail
      _walletBloc.add(GetWalletsEvent());
    });
  }

  void _onDeleteWallet(Wallet wallet) {
    _walletBloc.add(DeleteWalletEvent(wallet.id));
  }

  Widget _addItemWallet() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        onPressed: _onGoToAddWallet,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Theme.of(context).primaryColor, width: 2),
          ),
          elevation: 2,
        ),
        child: Text(
          '+ Thêm tài khoản',
          style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }

  Widget _buildItemWallet(Wallet wallet, {required int index}) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        _onGoToWalletDetail.call(wallet);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.primaries[index % Colors.primaries.length].withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey.withOpacity(0.2),
                  ),
                  child: Icon(
                    getIconWallet(walletType: wallet.accountType),
                    size: 30,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      wallet.name,
                      style: const TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${formatterInt(wallet.accountBalance)} ${wallet.currency}',
                      style: const TextStyle(fontSize: 20, color: Colors.black),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isDismissible: true,
                      enableDrag: true,
                      builder: (context) => _bottomOption(
                        onEdit: () {
                          _onGoToEditWallet(wallet);
                        },
                        onDelete: () {
                          _onDeleteWallet(wallet);
                        },
                      ),
                    );
                  },
                  child: const Icon(Icons.more_vert, size: 24, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomOption({VoidCallback? onEdit, VoidCallback? onDelete}) {
    return Container(
      color: Colors.grey[600],
      height: 130,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: MediaQuery.of(context).size.width * 0.44),
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: Colors.grey,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.white,
                foregroundColor: Colors.grey.withOpacity(0.5),
                alignment: Alignment.centerLeft,
              ),
              onPressed: () {
                Navigator.pop(context);
                onEdit?.call();
              },
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 12,
                children: [
                  Icon(Icons.edit, size: 24, color: Colors.grey),
                  Text('Sửa', style: TextStyle(fontSize: 16, color: Colors.black)),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.white,
                foregroundColor: Colors.grey.withOpacity(0.5),
                // padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),
              onPressed: () async {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.white,
                    title: const Text('Xóa tài khoản này?', style: TextStyle(fontSize: 16, color: Colors.black)),
                    content: Text(
                      AppConstants.contentDeleteWallet,
                      style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.5)),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Huỷ',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          // Navigator.pop(context);
                          onDelete?.call();
                        },
                        child: const Text('Xóa', style: TextStyle(fontSize: 16, color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 12,
                children: [
                  Icon(Icons.delete, size: 24, color: Colors.grey),
                  Text(
                    'Xoá',
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
