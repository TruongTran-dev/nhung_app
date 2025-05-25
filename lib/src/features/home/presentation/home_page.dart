import 'dart:convert';
import 'dart:developer';

import 'package:expensive_management/app/app_colors.dart';
import 'package:expensive_management/data/api/api_path.dart';
import 'package:expensive_management/src/core/common/extensions.dart';
import 'package:expensive_management/src/core/di/injection_container.dart';
import 'package:expensive_management/src/features/main/presentation/main_app.dart';
import 'package:expensive_management/src/features/my_wallet/presentation/bloc/bloc.dart';
import 'package:expensive_management/src/shared/routes/router.dart';
import 'package:expensive_management/src/shared/utils/screen_utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:expensive_management/src/features/my_wallet/domain/models/wallet.dart';
import 'package:expensive_management/src/features/home/domain/models/week_report_model.dart';
import 'package:expensive_management/src/features/home/presentation/components/home_report.dart';
import 'package:expensive_management/src/core/storage/shared_pref_storage.dart';
import 'package:expensive_management/src/shared/utils/utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.uniqueKey});

  final String? uniqueKey;

  @override
  State<HomePage> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomePage> {
  final sharedPref = serviceLocator<AppPrefStorage>();
  bool _isShowBalance = false;

  String get currency => sharedPref.getCurrency();

  bool _showDetail = true;

  late final WalletBloc _walletBloc;

  double _amount = 0;
  List<Wallet> _listWallet = [];

  @override
  void initState() {
    _isShowBalance = sharedPref.getHiddenAmount();
    _walletBloc = serviceLocator<WalletBloc>();
    _walletBloc.add(GetWalletsEvent());
    super.initState();
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.uniqueKey != widget.uniqueKey) {
      // refresh the page
      // _initializeUserData(logoutLoginSameSession: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildAmountWalletList(),
    );
  }

  Widget _buildAmountWalletList() {
    return BlocConsumer<WalletBloc, WalletState>(
      bloc: _walletBloc,
      listener: (context, state) {
        // print("BuildWalletState: ${state.runtimeType}");
        if (state is GetListWalletSuccessState) {
          _amount = state.moneyTotal;
          _listWallet.clear();
          _listWallet = state.wallets;
        } else if (state is GetListWalletErrorState) {
          log("Error: ${state.message}");
          // showToast(state.message);
          showMessage1OptionDialog(
            context,
            state.message,
          );
        }
      },
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _balance(_amount),
            Expanded(
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withAlpha(0),
                      Colors.white.withAlpha(100),
                      Colors.white.withAlpha(200),
                      Colors.white,
                      Colors.white,
                      Colors.white.withAlpha(200),
                      Colors.white.withAlpha(100),
                      Colors.white.withAlpha(0),
                    ],
                    stops: const [0.0, 0.01, 0.05, 0.2, 0.9, 0.95, 0.99, 1.0],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      _myWallet(_listWallet),
                      _weekReport(),
                      ReportPage(),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _weekReport() {
    return FutureBuilder(
      future: _getWeekReport(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        } else {
          final report = snapshot.data!;
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
                                  pointColorMapper: (data, index) => AppColors.secondary,
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
      },
    );
  }

  Future<WeekReportModel?> _getWeekReport() async {
    try {
      final token = sharedPref.getAccessToken();
      final headers = {
        "Authorization": token,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      final url = Uri.parse("${ApiPath.apiDomain}${ApiPath.weekReport}");
      final response = await http.get(url, headers: headers).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final reportData = data['data'];

        log("Week Report data: $reportData");
        final report = WeekReportModel.fromJson(reportData);
        return report;
      } else {
        log("Error fetching week report: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      log("Error fetching week report: $e");
      return null;
    }
  }

  Widget _myWallet(List<Wallet> listWallet) {
    final width = context.screenSize.width;

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
                  final scaffoldMainPage = context.findAncestorWidgetOfExactType<MainApp>();
                  if (scaffoldMainPage != null) {
                    scaffoldMainPage.navigationShell.goBranch(1);
                  }
                },
                child: Text('Xem tất cả', style: TextStyle(fontSize: 14, color: Colors.blue.withValues(alpha: 0.8))),
              )
            ],
          ),
        ),
        listWallet.isEmpty
            ? Container(
                height: 100,
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
                          return ElevatedButton(
                            onPressed: () {
                              context.push(AppRoutes.walletDetail, extra: wallet);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              elevation: 0,
                            ),
                            child: Stack(
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
                                    children: [
                                      Text(
                                        wallet.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 22,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (wallet.groupId != null)
                                        Text(
                                          'Ví nhóm: ${wallet.groupName}',
                                          style: TextStyle(fontSize: 14, color: Colors.black.withValues(alpha: 0.5)),
                                        ),
                                      Text(
                                        _isShowBalance
                                            ? '${formatterDouble(wallet.accountBalance)} $currency'
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
                                        ? getIconWallet(walletType: wallet.accountType)
                                        : Icons.help_outline,
                                    size: 36,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
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
      padding: const EdgeInsets.only(bottom: 10, left: 16, right: 16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.7),
        boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5, offset: Offset(0, 2))],
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tổng số dư', style: TextStyle(fontSize: 18, color: Colors.black45)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _isShowBalance ? '${formatterDouble(balance.toInt())}  $currency' : '******  $currency',
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
                      await sharedPref.setHiddenAmount(_isShowBalance);
                    },
                    child: Icon(
                      _isShowBalance ? Icons.visibility : Icons.visibility_off,
                      size: 26,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget listDetails(List<DataSf> listReport) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
            Text('${formatterDouble(report.value.toInt())} VND', style: const TextStyle(color: Colors.black)),
          ],
        ),
      ),
    );
  }
}
