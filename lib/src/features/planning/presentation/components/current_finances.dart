import 'package:expensive_management/src/core/di/injection_container.dart';
import 'package:expensive_management/src/features/my_wallet/presentation/bloc/bloc.dart';
import 'package:expensive_management/src/shared/routes/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expensive_management/src/features/my_wallet/domain/models/wallet.dart';
import 'package:expensive_management/src/shared/widgets/animation_loading.dart';
import 'package:expensive_management/src/shared/utils/screen_utilities.dart';
import 'package:expensive_management/src/core/storage/shared_pref_storage.dart';
import 'package:expensive_management/src/shared/utils/utils.dart';
import 'package:go_router/go_router.dart';

class CurrentFinances extends StatefulWidget {
  const CurrentFinances({super.key});

  @override
  State<CurrentFinances> createState() => _CurrentFinancesState();
}

class _CurrentFinancesState extends State<CurrentFinances> {
  final String currency = serviceLocator<AppPrefStorage>().getCurrency();
  final WalletBloc _walletBloc = serviceLocator<WalletBloc>();

  @override
  void initState() {
    _walletBloc.add(GetWalletsEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WalletBloc, WalletState>(
      bloc: _walletBloc,
      listener: (context, state) {
        if (state is GetListWalletErrorState) {
          showMessage1OptionDialog(context, state.message);
        }
      },
      builder: (context, state) {
        bool isLoading = state is WalletLoadingState;
        final List<Wallet> listWallet = state is GetListWalletSuccessState ? state.wallets : [];

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Theme.of(context).primaryColor,
            centerTitle: true,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () {
                context.pop();
              },
            ),
            title: const Text(
              'Tài chính hiện tại',
              style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          body: isLoading
              ? const AnimationLoading()
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: RefreshIndicator(
                    onRefresh: () async => await reloadPage(),
                    child: ListView.separated(
                      itemCount: listWallet.length + 1,
                      separatorBuilder: (context, index) {
                        if (index == 0 || index == listWallet.length) {
                          return const SizedBox.shrink();
                        }
                        return Container(
                          color: Colors.white,
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
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: Text(
                                    'Chọn tài khoản/ví để xem báo cáo tình hình tài chính',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                        if (listWallet.isNotEmpty) {
                          return _createItemWallet(
                            listWallet[index - 1],
                            index: index - 1,
                            endIndex: listWallet.length - 1,
                          );
                        }
                        return Container(
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: InkWell(
                                  onTap: () {
                                    context.push(AppRoutes.addWallet);
                                  },
                                  child: Text(
                                    'Chưa có tài khoản/ví, vui lòng thêm tài khoản/ví',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _createItemWallet(Wallet wallet, {int? index, int? endIndex}) {
    return InkWell(
      onTap: () {
        context.push(AppRoutes.walletDetail, extra: wallet);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
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
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.grey.withOpacity(0.2)),
                  child: Icon(getIconWallet(walletType: wallet.accountType),
                      size: 30, color: Theme.of(context).primaryColor),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(wallet.name, style: const TextStyle(fontSize: 16, color: Colors.black)),
                    Text('${formatterInt(wallet.accountBalance)} $currency',
                        style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> reloadPage() async {
    _walletBloc.add(GetWalletsEvent());
  }
}
