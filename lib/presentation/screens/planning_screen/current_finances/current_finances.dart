import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expensive_management/app/app_routes.dart';
import 'package:expensive_management/business/blocs/current_finances_bloc.dart';
import 'package:expensive_management/data/models/wallet.dart';
import 'package:expensive_management/presentation/screens/wallet_detail_screen/wallet_detail.dart';
import 'package:expensive_management/business/blocs/wallet_details_bloc.dart';
import 'package:expensive_management/presentation/screens/wallet_detail_screen/wallet_details_event.dart';
import 'package:expensive_management/presentation/widgets/animation_loading.dart';
import 'package:expensive_management/utils/enum/api_error_result.dart';
import 'package:expensive_management/utils/screen_utilities.dart';
import 'package:expensive_management/utils/shared_preferences_storage.dart';
import 'package:expensive_management/utils/utils.dart';

import 'current_finances_event.dart';
import 'current_finances_state.dart';

class CurrentFinances extends StatefulWidget {
  const CurrentFinances({Key? key}) : super(key: key);

  @override
  State<CurrentFinances> createState() => _CurrentFinancesState();
}

class _CurrentFinancesState extends State<CurrentFinances> {
  late CurrentFinancesBloc _currentFinancesBloc;

  final String currency = SharedPreferencesStorage().getCurrency();

  @override
  void initState() {
    _currentFinancesBloc = BlocProvider.of<CurrentFinancesBloc>(context)..add(CurrentFinancesInitEvent());
    super.initState();
  }

  @override
  void dispose() {
    _currentFinancesBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CurrentFinancesBloc, CurrentFinancesState>(
      listenWhen: (preState, curState) {
        return curState.apiError != ApiError.noError;
      },
      listener: (context, state) {
        if (state.apiError == ApiError.internalServerError) {
          showMessage1OptionDialog(context, 'Error!', content: 'Internal_server_error');
        }
        if (state.apiError == ApiError.noInternetConnection) {
          showMessageNoInternetDialog(context);
        }
      },
      builder: (context, state) => _body(context, state),
    );
  }

  Widget _body(BuildContext context, CurrentFinancesState state) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        centerTitle: true,
        automaticallyImplyLeading: true,
        title: const Text('Tài chính hiện tại', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: state.isLoading
          ? const AnimationLoading()
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: RefreshIndicator(
                onRefresh: () async => await reloadPage(),
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
                                'Chọn tài khoản/ví để xem báo cáo tình hình tài chính',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor),
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
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, AppRoutes.addWallet);
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
  }

  Widget _createItemWallet(BuildContext context, Wallet wallet, {int? index, int? endIndex}) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => WalletDetailBloc(context)..add(WalletDetailInit(walletId: wallet.id)),
              child: WalletDetail(wallet: wallet),
            ),
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
                    Text('${formatterInt(wallet.accountBalance)} $currency', style: const TextStyle(fontSize: 14, color: Colors.grey)),
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
    _currentFinancesBloc.add(CurrentFinancesInitEvent());
    setState(() {});
  }
}
