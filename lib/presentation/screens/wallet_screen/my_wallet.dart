import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expensive_management/app/app_routes.dart';
import 'package:expensive_management/data/models/wallet.dart';
import 'package:expensive_management/presentation/widgets/animation_loading.dart';
import 'package:expensive_management/presentation/screens/wallet_screen/components/edit_wallet.dart';
import 'package:expensive_management/business/blocs/my_wallet_bloc.dart';
import 'package:expensive_management/presentation/screens/wallet_screen/my_wallet_event.dart';
import 'package:expensive_management/presentation/screens/wallet_screen/my_wallet_state.dart';
import 'package:expensive_management/presentation/screens/wallet_detail_screen/wallet_detail.dart';
import 'package:expensive_management/business/blocs/wallet_details_bloc.dart';
import 'package:expensive_management/utils/app_constants.dart';
import 'package:expensive_management/utils/shared_preferences_storage.dart';
import 'package:expensive_management/utils/utils.dart';

class MyWalletPage extends StatefulWidget {
  const MyWalletPage({Key? key}) : super(key: key);

  @override
  State<MyWalletPage> createState() => _MyWalletPageState();
}

class _MyWalletPageState extends State<MyWalletPage> {
  late MyWalletPageBloc _myWalletPageBloc;

  @override
  void initState() {
    _myWalletPageBloc = BlocProvider.of<MyWalletPageBloc>(context)..add(GetListWalletEvent());
    super.initState();
  }

  @override
  void dispose() {
    _myWalletPageBloc.close();
    super.dispose();
  }

  void _reloadPage() {
    _myWalletPageBloc.add(GetListWalletEvent());
    Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyWalletPageBloc, MyWalletPageState>(
      builder: (context, curState) {
        return _body(context, curState);
      },
    );
  }

  Widget _body(BuildContext context, MyWalletPageState state) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'Tài khoản',
          style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: state.isLoading
          ? const AnimationLoading()
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: RefreshIndicator(
                onRefresh: () async => _reloadPage(),
                child: ListView.separated(
                  itemCount: (state.listWallet?.length ?? 0) + 1,
                  separatorBuilder: (context, index) {
                    if (index == 0 || index == (state.listWallet?.length ?? 0)) {
                      return const SizedBox.shrink();
                    }
                    return Container(
                      color: Theme.of(context).colorScheme.background,
                      child: const Padding(
                        padding: EdgeInsets.only(left: 70),
                        child: Divider(height: 0.5, color: Colors.grey),
                      ),
                    );
                  },
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Theme.of(context).colorScheme.background),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text(
                                'Tổng tiền : ${formatterDouble(state.moneyTotal)} ${SharedPreferencesStorage().getCurrency()}',
                                style: const TextStyle(fontSize: 16, color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    if (state.listWallet != null) {
                      return _createItemWallet(context, state.listWallet![index - 1], index: index - 1, endIndex: (state.listWallet?.length ?? 0) - 1);
                    }
                    return Container(
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.background, borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), border: Border.all(color: Theme.of(context).primaryColor, width: 2)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, AppRoutes.addWallet);
                              },
                              child: Text('+ Thêm tài khoản', style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor)),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
      floatingActionButton: InkWell(
        borderRadius: BorderRadius.circular(25),
        overlayColor: const MaterialStatePropertyAll(Colors.grey),
        onTap: () => Navigator.pushNamed(context, AppRoutes.addWallet),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(25)),
          child: const Icon(Icons.add, size: 40, color: Colors.white),
        ),
      ),
    );
  }

  Widget _createItemWallet(BuildContext context, Wallet wallet, {int? index, int? endIndex}) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(create: (context) => WalletDetailBloc(context), child: WalletDetail(wallet: wallet)),
          ),
        );
      },
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(index == 0 ? 10 : 0),
            topRight: Radius.circular(index == 0 ? 10 : 0),
            bottomLeft: Radius.circular((index == endIndex) ? 10 : 0),
            bottomRight: Radius.circular((index == endIndex) ? 10 : 0),
          ),
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
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.grey.withOpacity(0.2)),
                  child: Icon(getIconWallet(walletType: wallet.accountType), size: 30, color: Theme.of(context).primaryColor),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(wallet.name ?? '', style: const TextStyle(fontSize: 16, color: Colors.black)),
                    Text('${formatterInt(wallet.accountBalance)} ${wallet.currency}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
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
                      builder: (context) => _bottomOption(context: context, wallet: wallet),
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

  Widget _bottomOption({
    required BuildContext context,
    required Wallet wallet,
  }) {
    return Container(
      color: Colors.grey[600],
      height: 130,
      child: Container(
        decoration: const BoxDecoration(borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)), color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: MediaQuery.of(context).size.width * 0.45),
              child: Container(height: 4, decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: Colors.grey)),
            ),
            InkWell(
              overlayColor: const MaterialStatePropertyAll(Colors.grey),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditWalletPage(wallet: wallet)),
                );
              },
              child: const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.edit, size: 24, color: Colors.grey),
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text('Sửa', style: TextStyle(fontSize: 16, color: Colors.black)),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              overlayColor: const MaterialStatePropertyAll(Colors.grey),
              onTap: () async {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Xóa tài khoản này?', style: TextStyle(fontSize: 16, color: Colors.black)),
                    content: Text(AppConstants.contentDeleteWallet, style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.5))),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Huỷ', style: TextStyle(fontSize: 16, color: Colors.black)),
                      ),
                      TextButton(
                        onPressed: () async {
                          setState(() {
                            _myWalletPageBloc.add(
                              RemoveWalletEvent(walletId: wallet.id!)
                            );
                          });
                          Navigator.pop(context);
                          Navigator.pop(context);
                          await reloadPageWallet();
                        },
                        child: const Text('Xóa', style: TextStyle(fontSize: 16, color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.delete, size: 24, color: Colors.grey),
                    Padding(padding: EdgeInsets.only(left: 10), child: Text('Xoá', style: TextStyle(fontSize: 16, color: Colors.black))),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> reloadPageWallet() async {
    return _myWalletPageBloc.add(GetListWalletEvent());
  }
}
