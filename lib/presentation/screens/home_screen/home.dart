import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:expensive_management/app/app_routes.dart';
import 'package:expensive_management/business/blocs/expenditure_report_bloc.dart';
import 'package:expensive_management/business/blocs/revenue_report_bloc.dart';
import 'package:expensive_management/data/models/data_sfcartesian_char_model.dart';
import 'package:expensive_management/data/models/wallet.dart';
import 'package:expensive_management/data/models/week_report_model.dart';
import 'package:expensive_management/presentation/screens/home_screen/home_state.dart';
import 'package:expensive_management/presentation/screens/report_screen/report_screen.dart';
import 'package:expensive_management/presentation/widgets/animation_loading.dart';
import 'package:expensive_management/business/blocs/home_bloc.dart';
import 'package:expensive_management/utils/screen_utilities.dart';
import 'package:expensive_management/utils/shared_preferences_storage.dart';
import 'package:expensive_management/utils/utils.dart';

import '../wallet_detail_screen/wallet_detail.dart';
import '../../../business/blocs/wallet_details_bloc.dart';
import 'home_event.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ExpenditureReportBloc>(create: (context) => ExpenditureReportBloc(context)),
        BlocProvider<RevenueReportBloc>(create: (context) => RevenueReportBloc(context)),
      ],
      child: BlocProvider(create: (context) => HomePageBloc(context)..add(InitializedEvent()), child: const HomeView()),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _isShowBalance = SharedPreferencesStorage().getHiddenAmount();
  int notificationBadge = 0;

  final String currency = SharedPreferencesStorage().getCurrency();

  bool _showDetail = true;

  void _reloadPage() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      context.read<HomePageBloc>().add(InitializedEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomePageBloc, HomePageState>(
      listener: (context, state) {
        if (state is FailureState) {
          showMessage1OptionDialog(context, state.errorMessage);
        }
      },
      builder: (context, state) {
        if (state is SuccessState) {
          return _body(context, state);
        }
        return const AnimationLoading();
      },
    );
  }

  Widget _body(BuildContext context, SuccessState state) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: RefreshIndicator(
        onRefresh: () async => _reloadPage(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _balance(state.amount),
                _myWallet(state.listWallet),
                _reportWeek(state.weekReport),
                ReportScreen(preContext: context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _reportWeek(WeekReportModel report) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
      child: SizedBox(
        height: report.detailReport.isEmpty
            ? 140
            : _showDetail
                ? 400 + 40 * (report.detailReport.length).toDouble()
                : 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Text('Báo cáo chi tiêu theo tuần',
                  textAlign: TextAlign.left,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: Colors.grey[500])),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 10, top: 10, bottom: 10.0),
                      child: Text('(Đơn vị: triệu VNĐ)', style: TextStyle(fontSize: 12, color: Colors.black)),
                    ),
                    report.detailReport.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                            child: Text(
                              'Không thể hiển thị báo cáo tuần do chưa có hoạt động chi tiêu nào trong tuần.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Theme.of(context).primaryColor.withOpacity(0.7)),
                            ),
                          )
                        : SfCartesianChart(
                            primaryXAxis: CategoryAxis(),
                            tooltipBehavior: TooltipBehavior(enable: true),
                            series: [
                              ColumnSeries<dynamic, String>(
                                dataSource: report.detailReport,
                                xValueMapper: (data, _) => data.title,
                                yValueMapper: (data, _) => data.value / 1000000,
                                name: 'Báo cáo tuần',
                                color: Theme.of(context).primaryColor,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(5),
                                  topLeft: Radius.circular(5),
                                ),
                              )
                            ],
                          ),
                    if (report.detailReport.isNotEmpty) listDetails(report.detailReport),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _myWallet(List<Wallet> listWallet) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Container(
        decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(15)), color: Colors.white),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: SizedBox(
                height: 20,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Ví của tôi', style: TextStyle(fontSize: 16, color: Colors.black)),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.myWallet);
                      },
                      child: Text('Xem tất cả', style: TextStyle(fontSize: 14, color: Theme.of(context).primaryColor)),
                    )
                  ],
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.only(bottom: 10.0), child: Divider(height: 1, color: Colors.grey)),
            isNullOrEmpty(listWallet)
                ? Container(
                    height: 60,
                    alignment: Alignment.center,
                    child: Text(
                      'Bạn chưa có tài khoản/ví.\nVui lòng tạo mới tài khoản/ví.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor),
                    ),
                  )
                : SizedBox(
                    height: 60 * (listWallet.length).toDouble() + 15,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: listWallet.length,
                      itemBuilder: (context, index) {
                        return _createItemWallet(context, listWallet[index],
                            thisIndex: index, endIndex: listWallet.length);
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _balance(double balance) {
    return Container(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tổng số dư ', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                      child: Text(
                        _isShowBalance ? '${formatterDouble(balance)}  $currency' : '******  $currency',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: InkWell(
                        onTap: () async {
                          setState(() {
                            _isShowBalance = !_isShowBalance;
                          });
                          await SharedPreferencesStorage().setHiddenAmount(_isShowBalance);
                        },
                        child: Icon(_isShowBalance ? Icons.visibility : Icons.visibility_off,
                            size: 26, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              // if (notificationBadge > 0)
              //   badge.Badge(
              //     showBadge: (notificationBadge > 0),
              //     badgeContent: Text((notificationBadge.toString()),
              //         textAlign: TextAlign.center,
              //         style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
              //     badgeStyle: const badge.BadgeStyle(badgeColor: Colors.red, padding: EdgeInsets.fromLTRB(4, 2, 4, 2)),
              //     position: badge.BadgePosition.topEnd(top: -3, end: -3),
              //     child: const Icon(Icons.notifications, size: 26, color: Colors.black),
              //   ),
            ],
          ),
        ],
      ),
    );
  }

  _pushToWalletDetails(BuildContext context, Wallet wallet) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              BlocProvider(create: (context) => WalletDetailBloc(context), child: WalletDetail(wallet: wallet)),
        ),
      );

  Widget _createItemWallet(BuildContext context, Wallet wallet, {required int thisIndex, required int endIndex}) {
    return InkWell(
      onTap: () => _pushToWalletDetails(context, wallet),
      child: Container(
        height: 60,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular((thisIndex == endIndex) ? 15 : 0),
            bottomRight: Radius.circular((thisIndex == endIndex) ? 15 : 0),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(20)),
                child: Icon(
                  isNotNullOrEmpty(wallet.accountType)
                      ? getIconWallet(walletType: wallet.accountType ?? '')
                      : Icons.help_outline,
                  size: 24,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            Expanded(
              child: Text('${wallet.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, color: Colors.black)),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 16),
              child: Text(
                _isShowBalance
                    ? '${formatterDouble((wallet.accountBalance ?? 0).toDouble())} $currency'
                    : '****** $currency',
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget listDetails(List<DataSf> listReport) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _showDetail = !_showDetail;
              });
            },
            child: SizedBox(
              height: 40,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Xem chi tiết',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black)),
                  Icon(_showDetail ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 20, color: Colors.grey),
                ],
              ),
            ),
          ),
          if (_showDetail)
            SizedBox(
              height: 40 * (listReport.length).toDouble(),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: listReport.length,
                itemBuilder: (context, index) => details(listReport[index]),
              ),
            ),
        ],
      ),
    );
  }

  Widget details(DataSf report) {
    return InkWell(
      onTap: () {},
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          border: BorderDirectional(
            top: BorderSide(width: 0.5, color: Colors.grey.withOpacity(0.2)),
            bottom: BorderSide(width: 0.5, color: Colors.grey.withOpacity(0.2)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(report.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
            Text('${formatterDouble(report.value)} VND', style: const TextStyle(color: Colors.black)),
          ],
        ),
      ),
    );
  }
}
