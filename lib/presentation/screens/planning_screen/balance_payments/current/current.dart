import 'package:expensive_management/utils/shared_preferences_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expensive_management/business/blocs/balance_payment_blocs/current_bloc.dart';

import '../balance_payment.dart';

class CurrentAnalytic extends StatefulWidget {
  final List<int> walletIDs;
  const CurrentAnalytic({Key? key, required this.walletIDs}) : super(key: key);

  @override
  State<CurrentAnalytic> createState() => _CurrentAnalyticState();
}

class _CurrentAnalyticState extends State<CurrentAnalytic> {
  final currency = SharedPreferencesStorage().getCurrency();

  @override
  void initState() {
    BlocProvider.of<CurrentAnalyticBloc>(context).add(CurrentAnalyticEvent(walletIDs: widget.walletIDs));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CurrentAnalyticBloc, CurrentAnalyticState>(
      builder: (context, state) {
        List<ReportData> data = state.data ?? [];

        return state.isLoading
            ? const AnimationLoading()
            : SizedBox(
                height: 150 + 100 * (data.length).toDouble(),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  physics: const BouncingScrollPhysics(),
                  itemCount: data.length,
                  itemBuilder: (context, index) => _itemList(data[index]),
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
      padding: const EdgeInsets.all(10),
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
                  decoration: const BoxDecoration(
                    border: BorderDirectional(top: BorderSide(width: 0.5, color: Colors.grey)),
                  ),
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
}
