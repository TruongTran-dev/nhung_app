import 'dart:convert';
import 'dart:math' show Random;

import 'package:equatable/equatable.dart';
import 'package:expensive_management/src/core/common/api_path.dart';
import 'package:expensive_management/src/core/common/extensions.dart';
import 'package:expensive_management/src/core/di/injection_container.dart';
import 'package:expensive_management/src/core/storage/shared_pref_storage.dart';
import 'package:expensive_management/src/core/utils/app_utils.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:expensive_management/src/features/planning_expenditure_analysis/analytics.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({
    super.key,
  });

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
      _getExpenseDataReport();
    } else {
      _getRevenueDataReport();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  Future<List<CategoryReportData>> _getExpenseDataReport() async {
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
      final url = Uri.parse("${ApiPath.apiDomain}${ApiPath.categoryReport}?type=EXPENSE");
      final response = await http.get(url, headers: headers).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final reportData = data['data'];
        if (reportData is List) {
          final List<CategoryReportData> reports = reportData
              .map((item) => CategoryReportData(
                    name: item['categoryName'] as String,
                    percent: (item['percent'] as num).toDouble(),
                  ))
              .toList();
          return reports;
        }

        return [];
      } else {
        print("Error fetching week expense report: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error fetching week expense report: $e");
      return [];
    }
  }

  Future<List<CategoryReportData>> _getRevenueDataReport() async {
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
      final url = Uri.parse("${ApiPath.apiDomain}${ApiPath.categoryReport}?type=INCOME");
      final response = await http.get(url, headers: headers).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final reportData = data['data'];
        if (reportData is List) {
          final List<CategoryReportData> reports = reportData
              .map((item) => CategoryReportData(
                    name: item['categoryName'] as String,
                    percent: (item['percent'] as num).toDouble(),
                  ))
              .toList();
          return reports;
        }

        return [];
      } else {
        print("Error fetching week income report: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error fetching week income report: $e");
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
                              child: Text(
                                'Hạng mục chi',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _tabController.index == 0 ? Colors.black : Colors.grey,
                                ),
                              ),
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
                              child: Text(
                                'Hạng mục thu',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _tabController.index == 1 ? Colors.black : Colors.grey,
                                ),
                              ),
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
                          FutureBuilder<List<CategoryReportData>>(
                            future: _getExpenseDataReport(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator.adaptive());
                              } else if (snapshot.hasError) {
                                return Center(child: Text('Error: ${snapshot.error}'));
                              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const Center(child: Text('Chưa có dữ liệu báo cáo hạng mục chi'));
                              } else {
                                return ReportView(
                                  reports: snapshot.data!,
                                  isRevenue: false,
                                );
                              }
                            },
                          ),
                          FutureBuilder<List<CategoryReportData>>(
                            future: _getRevenueDataReport(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator.adaptive());
                              } else if (snapshot.hasError) {
                                return Center(child: Text('Error: ${snapshot.error}'));
                              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                return const Center(child: Text('Chưa có dữ liệu báo cáo hạng mục thu'));
                              } else {
                                return ReportView(
                                  reports: snapshot.data!,
                                  isRevenue: true,
                                );
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
  final List<CategoryReportData> reports;
  final bool isRevenue;

  const ReportView({
    super.key,
    required this.reports,
    this.isRevenue = false,
  });

  @override
  State<ReportView> createState() => _ReportViewState();
}

class _ReportViewState extends State<ReportView> {
  final TooltipBehavior _tooltip = TooltipBehavior(enable: true);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.white),
      padding: EdgeInsets.only(bottom: 12),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 10, bottom: 10.0),
              child: Text('(Đơn vị: %)', style: TextStyle(fontSize: 12, color: Colors.black)),
            ),
            SizedBox(
              height: 300,
              child: SfCircularChart(
                margin: EdgeInsets.zero,
                tooltipBehavior: _tooltip,
                series: <CircularSeries>[
                  PieSeries<CategoryReportData, String>(
                    dataSource: widget.reports,
                    xValueMapper: (CategoryReportData data, _) => data.name,
                    yValueMapper: (CategoryReportData data, _) => data.percent,
                    name: widget.isRevenue ? 'Thu' : 'Chi',
                    explode: false,
                    pointColorMapper: (CategoryReportData data, index) => getColor(index),
                  ),
                ],
              ),
            ),
            ...widget.reports.mapIndexed((index, report) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 12,
                      decoration: BoxDecoration(
                        color: getColor(index),
                        shape: BoxShape.rectangle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        report.name,
                        style: TextStyle(fontSize: 14, color: Colors.black.withValues(alpha: 0.7)),
                      ),
                    ),
                    Text(
                      '${report.percent.toStringAsFixed(2)}%',
                      style: TextStyle(fontSize: 14, color: Colors.black.withValues(alpha: 0.7)),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Color getColor(int index) {
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
      return Color.fromRGBO(random.nextInt(256), random.nextInt(256), random.nextInt(256), 1.0).withValues(alpha: 0.4);
    }
  }
}

class CategoryReportData extends Equatable {
  final String name;
  final double percent;

  const CategoryReportData({
    required this.name,
    required this.percent,
  });

  factory CategoryReportData.fromJson(Map<String, dynamic> json) {
    return CategoryReportData(
      name: json['comm'] as String,
      percent: (json['percent'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [name, percent];
  @override
  bool get stringify => true;

  CategoryReportData copyWith({
    String? name,
    double? percent,
  }) {
    return CategoryReportData(
      name: name ?? this.name,
      percent: percent ?? this.percent,
    );
  }
}
