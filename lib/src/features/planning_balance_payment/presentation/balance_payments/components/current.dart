import 'package:expensive_management/data/models/report_expenditure_revenue_model.dart';
import 'package:expensive_management/src/shared/widgets/animation_loading.dart';
import 'package:expensive_management/src/core/di/injection_container.dart';
import 'package:expensive_management/src/core/storage/shared_pref_storage.dart';
import 'package:expensive_management/src/shared/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expensive_management/src/features/planning_balance_payment/presentation/bloc/current_bloc.dart';


class CurrentAnalytic extends StatefulWidget {
  final List<int> walletIDs;
  const CurrentAnalytic({super.key, required this.walletIDs});

  @override
  State<CurrentAnalytic> createState() => _CurrentAnalyticState();
}

class _CurrentAnalyticState extends State<CurrentAnalytic> {
  final currency = serviceLocator<AppPrefStorage>().getCurrency();

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
            : ListView.builder(
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                itemCount: data.length,
                itemBuilder: (context, index) => _itemList(data[index]),
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
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(data.name, style: const TextStyle(fontSize: 16, color: Colors.black)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            spacing: 8,
            children: [
              Text(
                'Thu: ${formatterDouble(data.incomeTotal.toInt())} $currency',
                style: const TextStyle(fontSize: 14, color: Colors.green),
              ),
              Text(
                'Chi: ${formatterDouble(data.expenseTotal.toInt())} $currency',
                style: const TextStyle(fontSize: 14, color: Colors.red),
              ),
              Container(
                padding: const EdgeInsets.only(top: 8),
                decoration: const BoxDecoration(
                  border: BorderDirectional(top: BorderSide(width: 0.5, color: Colors.grey)),
                ),
                child: Text(
                  'Còn lại: ${formatterDouble(data.remainTotal.toInt())} $currency',
                  style: const TextStyle(fontSize: 14, color: Colors.black),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
