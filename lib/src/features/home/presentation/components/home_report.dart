import 'dart:convert';
import 'dart:math';

import 'package:expensive_management/data/api/api_path.dart';
import 'package:expensive_management/src/core/di/injection_container.dart';
import 'package:expensive_management/src/core/utils/app_utils.dart';
import 'package:expensive_management/src/shared/utils/enum/enum.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:expensive_management/data/models/category_report_model.dart';
import 'package:expensive_management/presentation/screens/planning_screen/balance_payments/balance_payment.dart';
import 'package:expensive_management/presentation/screens/planning_screen/expenditure_analysis/analytics.dart';

class ReportPage extends StatefulWidget {
  final BuildContext preContext;
  const ReportPage({super.key, required this.preContext});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final sharedPref = serviceLocator<AppPrefStorage>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Set up listener for tab changes
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _fetchData();
      }
    });
  }

  // Method to fetch data based on current tab
  void _fetchData() {
    if (_tabController.index == 0) {
      _getExpenditureRevenueDataReport(type: TransactionType.expense);
    } else {
      _getExpenditureRevenueDataReport(type: TransactionType.income);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  Future<List<CategoryReportModel>> _getExpenditureRevenueDataReport({
    required TransactionType type,
  }) async {
    try {
      final token = sharedPref.getAccessToken();
      if (!await AppUtils.isValidToken()) {
        //logout();
      }

      final headers = {
        "Authorization": token,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      final url = Uri.parse("${ApiPath.apiDomain}${ApiPath.weekReport}?type=${type.name.toUpperCase()}");
      final response = await http.get(url, headers: headers).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final reportData = data['data'];
        // print("Report data: $reportData");
        if (reportData != null && reportData is List) {
          return reportData.map((e) => CategoryReportModel.fromJson(e)).toList();
        } else {
          return [];
        }
      } else {
        print("Error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error fetching week report: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, left: 16, right: 16),
      child: SizedBox(
        height: 530,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Báo cáo tỉ lệ chi tiêu theo hạng mục',
              textAlign: TextAlign.left,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 16, color: Colors.black.withValues(alpha: 0.7)),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                margin: EdgeInsets.only(top: 12),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      height: 48,
                      child: TabBar(
                        controller: _tabController,
                        dividerHeight: 0,
                        indicatorSize: TabBarIndicatorSize.tab,
                        automaticIndicatorColorAdjustment: false,
                        padding: EdgeInsets.symmetric(vertical: 4),
                        indicatorColor: Colors.transparent,
                        onTap: (value) {
                          setState(() {});
                        },
                        tabs: [
                          Tab(
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: _tabController.index == 0 ? Colors.white : Colors.transparent,
                              ),
                              child: Text('Hạng mục chi',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _tabController.index == 0 ? Colors.black : Colors.grey,
                                  )),
                            ),
                          ),
                          Tab(
                            child: Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: _tabController.index == 1 ? Colors.white : Colors.transparent,
                              ),
                              child: Text('Hạng mục thu',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _tabController.index == 1 ? Colors.black : Colors.grey,
                                  )),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          FutureBuilder<List<CategoryReportModel>>(
                            future: _getExpenditureRevenueDataReport(type: TransactionType.expense),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator.adaptive());
                              } else if (snapshot.hasError) {
                                return Center(child: Text('Error: ${snapshot.error}'));
                              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const Center(child: Text('Chưa có dữ liệu báo cáo hạng mục chi'));
                              } else {
                                return ReportView(reports: snapshot.data!, isRevenue: false);
                              }
                            },
                          ),
                          FutureBuilder<List<CategoryReportModel>>(
                            future: _getExpenditureRevenueDataReport(type: TransactionType.income),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator.adaptive());
                              } else if (snapshot.hasError) {
                                return Center(child: Text('Error: ${snapshot.error}'));
                              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const Center(child: Text('Chưa có dữ liệu báo cáo hạng mục thu'));
                              } else {
                                return ReportView(reports: snapshot.data!, isRevenue: true);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReportView extends StatefulWidget {
  final List<CategoryReportModel> reports;
  final bool isRevenue;

  const ReportView({super.key, required this.reports, this.isRevenue = false});

  @override
  State<ReportView> createState() => _ReportViewState();
}

class _ReportViewState extends State<ReportView> {
  final TooltipBehavior _tooltip = TooltipBehavior(enable: true);

  bool _showDetail = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 10, bottom: 10.0),
            child: Text('(Đơn vị: %)', style: TextStyle(fontSize: 12, color: Colors.black)),
          ),
          SizedBox(
            height: 350,
            child: SfCircularChart(
              tooltipBehavior: _tooltip,
              series: <CircularSeries>[
                PieSeries<CategoryReportModel, String>(
                  dataSource: widget.reports,
                  xValueMapper: (CategoryReportModel data, _) => data.categoryName,
                  yValueMapper: (CategoryReportModel data, _) => data.percent,
                  name: widget.isRevenue ? 'Thu' : 'Chi',
                  explode: false,
                  pointColorMapper: (CategoryReportModel data, index) {
                    // Generate random color with good contrast
                    if (index == 0) {
                      return Color(0xfffbdcea);
                    } else if (index == 1) {
                      return Color(0xffdbd9ff);
                    } else if (index == 2) {
                      return Color(0xff7e9ae6);
                    } else if (index == 3) {
                      return Color(0xff73dce6);
                    } else if (index == 4) {
                      return Color(0xffcff5f4);
                    } else {
                      final random = Random();
                      return Color.fromRGBO(random.nextInt(256), random.nextInt(256), random.nextInt(256), 1.0)
                          .withValues(alpha: 0.4);
                    }
                  },
                ),
              ],
            ),
          ),
          // listDetails(widget.reports),
        ],
      ),
    );
  }

  Widget listDetails(List<CategoryReportModel> listReport) {
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
          if (_showDetail && listReport.isNotEmpty)
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

  Widget details(CategoryReportModel report) {
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
            Text(report.categoryName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
            Text('${formatterDouble(report.percent.toInt())} %', style: const TextStyle(color: Colors.black)),
          ],
        ),
      ),
    );
  }
}
