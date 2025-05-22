import 'package:expensive_management/src/core/common/extensions.dart';
import 'package:expensive_management/src/core/di/injection_container.dart';
import 'package:expensive_management/src/core/utils/app_utils.dart';
import 'package:expensive_management/src/features/my_wallet/domain/models/wallet.dart';
import 'package:expensive_management/src/features/my_wallet/presentation/bloc/bloc.dart';
import 'package:expensive_management/src/shared/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SelectWallets extends StatefulWidget {
  const SelectWallets({super.key, required this.wallets});

  final List<Wallet> wallets;

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

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: listWallet.isEmpty
                ? Text(
                    'Không có dữ liệu tài khoản, vui lòng thêm tài khoản mới.',
                    style: TextStyle(fontSize: 16, color: context.theme.primaryColor),
                  )
                : ListView.builder(
                    itemCount: listWallet.length,
                    itemBuilder: (context, index) {
                      final Wallet item = listWallet[index];
                      return Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              if (listWalletSelected.any((wallet) => wallet.id == item.id)) {
                                listWalletSelected.removeWhere((wallet) => wallet.id == item.id);
                              } else {
                                listWalletSelected.add(item);
                              }
                            });
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
                                    !listWallet[index].accountType.isNullOrEmpty
                                        ? getIconWallet(walletType: listWallet[index].accountType)
                                        : Icons.help,
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
                                        listWallet[index].name,
                                        style: const TextStyle(fontSize: 16, color: Colors.black),
                                      ),
                                      Text(
                                        '${listWallet[index].accountBalance} ${listWallet[index].currency}',
                                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: listWalletSelected.any((wallet) => wallet.id == item.id)
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
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
