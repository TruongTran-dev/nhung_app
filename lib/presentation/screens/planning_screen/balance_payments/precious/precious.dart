import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:expensive_management/business/blocs/balance_payment_blocs/precious_bloc.dart';
import 'package:expensive_management/data/models/data_sfcartesian_char_model.dart';

import '../balance_payment.dart';

class PreciousAnalytic extends StatefulWidget {
  final int year;
  final List<int> walletIDs;

  const PreciousAnalytic({
    Key? key,
    required this.year,
    required this.walletIDs,
  }) : super(key: key);

  @override
  State<PreciousAnalytic> createState() => _PreciousAnalyticState();
}

class _PreciousAnalyticState extends State<PreciousAnalytic> {
  final currency = SharedPreferencesStorage().getCurrency();

  @override
  void initState() {
    BlocProvider.of<PreciousAnalyticBloc>(context).add(PreciousAnalyticEvent(
      year: widget.year,
      walletIDs: widget.walletIDs,
    ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PreciousAnalyticBloc, PreciousAnalyticState>(
      builder: (context, state) {
        List<ReportData> data = state.data ?? [];

        List<DataSf> sfListExpense = data.map((reportData) {
          return DataSf(title: reportData.name, value: reportData.expenseTotal / 1000000);
        }).toList();
        List<DataSf> sfListIncome = data.map((reportData) {
          return DataSf(title: reportData.name, value: reportData.incomeTotal / 1000000);
        }).toList();
        List<DataSf> sfListRemain = data.map((reportData) {
          return DataSf(title: reportData.name, value: reportData.remainTotal / 1000000);
        }).toList();

        return state.isLoading
            ? const AnimationLoading()
            : SingleChildScrollView(
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _charts(sfListIncome, sfListExpense, sfListRemain),
                    Divider(height: 10, thickness: 10, color: Theme.of(context).colorScheme.background),
                    SizedBox(
                      height: 100 * (data.length.toDouble()) + 100,
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: data.length,
                        itemBuilder: (context, index) => _itemList(data[index]),
                      ),
                    ),
                  ],
                ),
              );
      },
    );
  }

  Widget _itemList(ReportData data) {
    return Container(
      decoration: BoxDecoration(
        border: BorderDirectional(
          top: BorderSide(width: 0.5, color: Colors.grey.withOpacity(0.2)),
          bottom: BorderSide(width: 0.5, color: Colors.grey.withOpacity(0.2)),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: SizedBox(
        height: 100,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(data.name, style: const TextStyle(fontSize: 16, color: Colors.black)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  '${formatterDouble(data.incomeTotal)} $currency',
                  style: const TextStyle(fontSize: 14, color: Colors.green),
                ),
                Text(
                  '${formatterDouble(data.expenseTotal)} $currency',
                  style: const TextStyle(fontSize: 14, color: Colors.red),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 10),
                  decoration: const BoxDecoration(border: BorderDirectional(top: BorderSide(width: 0.5, color: Colors.grey))),
                  child: Text(
                    '${formatterDouble(data.remainTotal)} $currency',
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _charts(List<DataSf> listIncome, listExpense, listRemain) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, top: 10.0, bottom: 4),
          child: Text('(Đơn vị: triệu VNĐ)', style: TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w400)),
        ),
        SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: [
            ColumnSeries<DataSf, String>(
              dataSource: listIncome,
              xValueMapper: (DataSf data, _) => data.title,
              yValueMapper: (DataSf data, _) => data.value,
              name: 'Thu',
              color: Colors.grey,
              // Enable data label
              // dataLabelSettings: DataLabelSettings(isVisible: true)
            ),
            ColumnSeries<DataSf, String>(
              dataSource: listExpense,
              xValueMapper: (DataSf data, _) => data.title,
              yValueMapper: (DataSf data, _) => data.value,
              name: 'Chi',
              color: Colors.blue,
              // Enable data label
              // dataLabelSettings: DataLabelSettings(isVisible: true)
            ),
            ColumnSeries<DataSf, String>(
              dataSource: listRemain,
              xValueMapper: (DataSf data, _) => data.title,
              yValueMapper: (DataSf data, _) => data.value,
              name: 'Còn lại',
              color: Colors.red,
              // Enable data label
              // dataLabelSettings: DataLabelSettings(isVisible: true)
            )
          ],
        ),
      ],
    );
  }
}
