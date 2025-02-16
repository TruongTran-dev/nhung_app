import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:expensive_management/business/blocs/expenditure_report_bloc.dart';
import 'package:expensive_management/business/blocs/revenue_report_bloc.dart';
import 'package:expensive_management/data/models/category_report_model.dart';
import 'package:expensive_management/presentation/screens/planning_screen/balance_payments/balance_payment.dart';
import 'package:expensive_management/presentation/screens/planning_screen/expenditure_analysis/analytics.dart';
import 'package:expensive_management/presentation/screens/report_screen/expenditure_report/expenditure_report_state.dart' as e;
import 'package:expensive_management/presentation/screens/report_screen/revenue_report/revenue_report_event.dart';
import 'package:expensive_management/presentation/screens/report_screen/revenue_report/revenue_report_state.dart' as r;

import 'expenditure_report/expenditure_report_event.dart';

class ReportScreen extends StatefulWidget {
  final BuildContext preContext;
  const ReportScreen({super.key, required this.preContext});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
    widget.preContext.read<ExpenditureReportBloc>().add(ExpenditureReportEvent());
    widget.preContext.read<RevenueReportBloc>().add(RevenueReportEvent());
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        height: 530,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('Báo cáo tỉ lệ chi tiêu theo hạng mục', textAlign: TextAlign.left, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, color: Colors.grey[500])),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(color: Theme.of(context).colorScheme.background, borderRadius: BorderRadius.circular(10)),
                          child: TabBar(
                            controller: _tabController,
                            unselectedLabelColor: Colors.grey[500],
                            labelColor: Colors.black,
                            labelStyle: const TextStyle(fontSize: 14),
                            padding: const EdgeInsets.all(2),
                            indicatorWeight: 1.5,
                            indicatorColor: Colors.black,
                            indicator: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                            tabs: const [
                              Tab(text: 'Hạng mục chi'),
                              Tab(text: 'Hạng mục thu'),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            BlocBuilder<ExpenditureReportBloc, e.ExpenditureReportState>(
                              builder: (context, state) {
                                Widget body = const SizedBox.shrink();
                                if (state is e.LoadingState) {
                                  body = const AnimationLoading();
                                }
                                if (state is e.FailureState) {
                                  showMessage1OptionDialog(context, state.errorMessage);
                                }

                                if (state is e.SuccessState) {
                                  return ReportView(reports: state.expenditureReports, isRevenue: false);
                                }
                                return body;
                              },
                            ),

                            BlocBuilder<RevenueReportBloc, r.RevenueReportState>(
                              builder: (context, state) {
                                Widget body = const SizedBox.shrink();
                                if (state is r.LoadingState) {
                                  body = const AnimationLoading();
                                }
                                if (state is r.FailureState) {
                                  showMessage1OptionDialog(context, state.errorMessage);
                                }

                                if (state is r.SuccessState) {
                                  return ReportView(reports: state.revenueReports, isRevenue: true);
                                }
                                return body;
                              },
                            ),
                            // ExpenditureReport(),
                            // RevenueReport(),
                          ],
                        ),
                      ),
                    ],
                  ),
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
                  const Text('Xem chi tiết', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black)),
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
            Text('${formatterDouble(report.percent)} %', style: const TextStyle(color: Colors.black)),
          ],
        ),
      ),
    );
  }
}
