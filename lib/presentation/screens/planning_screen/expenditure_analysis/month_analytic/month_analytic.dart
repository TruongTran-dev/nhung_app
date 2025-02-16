import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:expensive_management/business/blocs/expenditure_analytic_blocs/month_analytic_bloc.dart';
import 'package:expensive_management/data/models/analytic_model.dart';
import 'package:expensive_management/presentation/widgets/animation_loading.dart';
import 'package:expensive_management/utils/enum/enum.dart';
import 'package:expensive_management/utils/shared_preferences_storage.dart';
import 'package:expensive_management/utils/utils.dart';
import 'month_analytic_event.dart';
import 'month_analytic_state.dart';

class MonthAnalytic extends StatefulWidget {
  final String fromMonth, toMonth;
  final List<int> walletIDs, categoryIDs;
  final TransactionType type;
  const MonthAnalytic({Key? key, required this.fromMonth, required this.toMonth, required this.walletIDs, required this.categoryIDs, this.type = TransactionType.expense}) : super(key: key);

  @override
  State<MonthAnalytic> createState() => _MonthAnalyticState();
}

class _MonthAnalyticState extends State<MonthAnalytic> {
  bool _showDetail = false;

  final currency = SharedPreferencesStorage().getCurrency();

  @override
  void initState() {
    BlocProvider.of<MonthAnalyticBloc>(context).add(MonthAnalyticEvent(
      walletIDs: widget.walletIDs,
      categoryIDs: widget.categoryIDs,
      fromMonth: widget.fromMonth,
      toMonth: widget.toMonth,
      type: widget.type,
    ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MonthAnalyticBloc, MonthAnalyticState>(
      builder: (context, state) {
        List<CategoryReport> listReport = state.data?.categoryReports ?? [];
        listReport.sort((a, b) => a.time.compareTo(b.time));

        return state.isLoading
            ? const AnimationLoading()
            : Padding(
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 8.0),
                      child: Text('(Đơn vị: triệu VNĐ)', style: TextStyle(fontSize: 12, color: Colors.black)),
                    ),
                    SfCartesianChart(
                      primaryXAxis: CategoryAxis(),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: [
                        ColumnSeries<CategoryReport, String>(
                          dataSource: listReport,
                          xValueMapper: (CategoryReport data, _) => data.time,
                          yValueMapper: (CategoryReport data, _) => data.totalAmount / 1000000,
                          name: 'Chi tiêu tháng',
                          color: Colors.lightBlueAccent,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tổng chi tiêu', style: TextStyle(fontSize: 14, color: Colors.grey)),
                          Text(
                            formatterDouble(state.data?.totalAmount),
                            style: const TextStyle(fontSize: 14, color: Colors.black),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Trung bình chỉ/tháng', style: TextStyle(fontSize: 14, color: Colors.grey)),
                          Text(formatterDouble(state.data?.mediumAmount), style: const TextStyle(fontSize: 14, color: Colors.black)),
                        ],
                      ),
                    ),
                    Divider(color: Colors.grey.withOpacity(0.2), height: 10, thickness: 10),
                    listFilter(listReport),
                  ],
                ),
              );
      },
    );
  }

  Widget listFilter(List<CategoryReport>? listReport) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
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
          if (_showDetail)
            SizedBox(
              height: 40 * (listReport!.length).toDouble(),
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

  Widget details(CategoryReport report) {
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
            Text(report.time, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
            Row(
              children: [
                Text('${formatterDouble(report.totalAmount)} $currency', style: const TextStyle(color: Colors.red)),
                const Icon(Icons.keyboard_arrow_right_rounded, size: 20, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
