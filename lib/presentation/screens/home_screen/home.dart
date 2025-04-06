import 'dart:math';

import 'package:expensive_management/app/extensions.dart';
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
      child: BlocProvider(
        create: (context) => HomePageBloc(context)..add(InitializedEvent()),
        child: const HomeView(),
      ),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

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
      if (!mounted) return;
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
    return RefreshIndicator(
      onRefresh: () async => _reloadPage(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: RefreshIndicator(
          onRefresh: () async => _reloadPage(),
          child: Column(
            children: [
              _balance(state.amount),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _myWallet(state.listWallet),
                      _reportWeek(state.weekReport),
                      ReportScreen(preContext: context),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reportWeek(WeekReportModel report) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Báo cáo chi tiêu theo tuần',
              textAlign: TextAlign.left,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16, color: Colors.black.withValues(alpha: 0.7)),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(color: Colors.grey, blurRadius: 5, offset: Offset(0, 2)),
              ],
            ),
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
                          style: TextStyle(color: Colors.black.withValues(alpha: 0.5), fontSize: 16),
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
                            pointColorMapper: (data, index) {
                              // Define a list of colors
                              final colors = [
                                Colors.blue,
                                Colors.green,
                                Colors.red,
                                Colors.orange,
                                Colors.purple,
                                Colors.teal,
                              ];
                              // Use index to pick a color from the list
                              return colors[index % colors.length];
                            },
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
        ],
      ),
    );
  }

  Widget _myWallet(List<Wallet> listWallet) {
    // return Container(
    //   margin: const EdgeInsets.only(top: 16),
    //   decoration: const BoxDecoration(
    //     borderRadius: BorderRadius.all(Radius.circular(15)),
    //     color: Colors.white,
    //     boxShadow: [
    //       BoxShadow(color: Colors.grey, blurRadius: 5, offset: Offset(0, 2)),
    //     ],
    //   ),
    //   child: Column(
    //     children: [
    //       Padding(
    //         padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
    //         child: SizedBox(
    //           height: 20,
    //           child: Row(
    //             crossAxisAlignment: CrossAxisAlignment.center,
    //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //             children: [
    //               const Text('Ví của tôi', style: TextStyle(fontSize: 16, color: Colors.black)),
    //               GestureDetector(
    //                 onTap: () {
    //                   Navigator.pushNamed(context, AppRoutes.myWallet);
    //                 },
    //                 child: Text('Xem tất cả', style: TextStyle(fontSize: 14, color: Theme.of(context).primaryColor)),
    //               )
    //             ],
    //           ),
    //         ),
    //       ),
    //       const Padding(padding: EdgeInsets.only(bottom: 10.0), child: Divider(height: 1, color: Colors.grey)),
    //       isNullOrEmpty(listWallet)
    //           ? Container(
    //               height: 60,
    //               alignment: Alignment.center,
    //               child: Text(
    //                 'Bạn chưa có tài khoản/ví.\nVui lòng tạo mới tài khoản/ví.',
    //                 textAlign: TextAlign.center,
    //                 style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor),
    //               ),
    //             )
    //           : SizedBox(
    //               height: 60 * (listWallet.length).toDouble() + 15,
    //               child: ListView.builder(
    //                 padding: EdgeInsets.zero,
    //                 physics: const NeverScrollableScrollPhysics(),
    //                 itemCount: listWallet.length,
    //                 itemBuilder: (context, index) {
    //                   return _createItemWallet(context, listWallet[index],
    //                       thisIndex: index, endIndex: listWallet.length);
    //                 },
    //               ),
    //             ),
    //     ],
    //   ),
    // );
    final width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Ví của tôi', style: TextStyle(fontSize: 16, color: Colors.black)),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.myWallet);
                },
                child: Text('Xem tất cả', style: TextStyle(fontSize: 14, color: Colors.blue.withValues(alpha: 0.8))),
              )
            ],
          ),
        ),
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
                width: width,
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    spacing: 12,
                    children: [
                      ...listWallet.mapIndexed(
                        (index, wallet) {
                          final color = [
                            Colors.blue[100]!,
                            Colors.green[100]!,
                            Colors.orange[100]!,
                            Colors.purple[100]!,
                            Colors.cyan[100]!,
                            Colors.amber[100]!,
                          ][index % 6];
                          return Stack(
                            children: [
                              Container(
                                constraints: BoxConstraints(
                                  minWidth: width * 0.5,
                                  maxWidth: width * 0.6,
                                  minHeight: 70,
                                  maxHeight: 120,
                                ),
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: const [
                                    BoxShadow(color: Colors.grey, blurRadius: 5, offset: Offset(0, 2)),
                                  ],
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  spacing: 12,
                                  children: [
                                    Text(
                                      '${wallet.name}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 22, color: Colors.black, fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      _isShowBalance
                                          ? '${formatterDouble((wallet.accountBalance ?? 0).toDouble())} $currency'
                                          : '****** $currency',
                                      style: TextStyle(fontSize: 16, color: Colors.black.withValues(alpha: 0.5)),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                right: 16,
                                bottom: 16,
                                child: Icon(
                                  isNotNullOrEmpty(wallet.accountType)
                                      ? getIconWallet(walletType: wallet.accountType ?? '')
                                      : Icons.help_outline,
                                  size: 36,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  Widget _balance(double balance) {
    return Container(
      padding: const EdgeInsets.only(top: 28, bottom: 10, left: 16, right: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tổng số dư ', style: TextStyle(fontSize: 18, color: Colors.black45)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
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
                  child: Icon(_isShowBalance ? Icons.visibility : Icons.visibility_off, size: 26, color: Colors.black),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _pushToWalletDetails(BuildContext context, Wallet wallet) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => WalletDetailBloc(context),
            child: WalletDetail(wallet: wallet),
          ),
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Xem chi tiết',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
                ),
                Icon(_showDetail ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 20, color: Colors.grey),
              ],
            ),
          ),
          if (_showDetail) ...listReport.map((report) => details(report)),
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
