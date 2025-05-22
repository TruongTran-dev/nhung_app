import 'dart:developer';

import 'package:expensive_management/presentation/screens/planning_screen/expenditure_analysis/analytics.dart';
import 'package:expensive_management/src/core/common/extensions.dart';
import 'package:expensive_management/src/core/di/injection_container.dart';
import 'package:expensive_management/src/features/limit_expenditure/presentation/bloc/bloc.dart';
import 'package:expensive_management/src/shared/routes/router.dart';
import 'package:expensive_management/src/shared/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:expensive_management/data/models/limit_expenditure_model.dart';
import 'package:expensive_management/src/shared/utils/enum/enum.dart';
import 'package:expensive_management/src/core/storage/shared_pref_storage.dart';
import 'package:expensive_management/src/shared/utils/utils.dart';

import '../../../../presentation/screens/setting_screen/recurring_transaction/recurring_transaction.dart';
import 'components/limit_info.dart';

class LimitExpenditurePage extends StatefulWidget {
  const LimitExpenditurePage({super.key});

  @override
  State<LimitExpenditurePage> createState() => _LimitExpenditurePageState();
}

class _LimitExpenditurePageState extends State<LimitExpenditurePage> {
  final String currency = serviceLocator<AppPrefStorage>().getCurrency();

  TransactionDataStatus _statusSelected = TransactionDataStatus(
    name: 'Đang diễn ra',
    status: TransactionStatus.on_going,
  );

  void _reloadPage() {
    // showLoading(context);
    // // _limitBloc.add(GetListLimitEvent(status: _statusSelected.status));
    // // setState(() {});
    // Future.delayed(
    //   const Duration(seconds: 1),
    //   () {
    //     // ignore: use_build_context_synchronously
    //     Navigator.pop(context);
    //     setState(() {});
    //   },
    // );
  }
  late LimitExpenditureBloc _limitBloc;
  final List<LimitModel> _listLimit = [];

  void _getListLimit() {
    _limitBloc.add(GetLimitsEvent({'status': _statusSelected.status.name.toUpperCase()}));
  }

  @override
  void initState() {
    _limitBloc = serviceLocator<LimitExpenditureBloc>();
    _getListLimit();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios, size: 24, color: Colors.white),
        ),
        centerTitle: true,
        title: const Text(
          'Hạn mức chi',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final bool? result = await context.push(
                AppRoutes.limitInfor,
                extra: LimitInfoProps(isEdit: false, limitData: null),
              );
              if (result != null && result) {
                _getListLimit();
              }
            },
            icon: const Icon(Icons.add, size: 24, color: Colors.white),
          ),
        ],
      ),
      body: BlocConsumer(
        bloc: _limitBloc,
        listener: (context, state) {
          if (state is GetLimitsErrorState) {
            showMessage1OptionDialog(context, state.message);
          }
          if (state is GetLimitsSuccessState) {
            _listLimit.clear();
            _listLimit.addAll(state.limits);
          }
        },
        builder: (context, state) {
          final isLoading = state is LimitExpenditureLoadingState;
          return Stack(
            children: [
              Column(
                children: [
                  _itemStatus(),
                  Expanded(
                    child: _listLimit.isNotEmpty
                        ? ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: _listLimit.length,
                            itemBuilder: (context, index) => _itemLimit(_listLimit[index]),
                          )
                        : Center(
                            child: Text(
                              'Chưa có hạn mức chi.\nVui lòng thêm hạn mức.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor),
                            ),
                          ),
                  ),
                ],
              ),
              isLoading ? const Positioned.fill(child: LoadingWidget()) : const SizedBox.shrink(),
            ],
          );
        },
      ),
    );
    //   },
    // );
  }

  String formatDate(DateTime? date) => DateFormat('dd/MM').format(date ?? DateTime.now());

  int overAmount(double actual, double amount) => (actual - amount).toInt();

  Widget _dialogSelectStatus() {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text(
        'Chọn trạng thái hạn mức',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      content: Container(
        height: 150,
        width: 200,
        color: Colors.white,
        child: ListView(
          children: listTransactionStatus.map((transactionStatus) {
            return Container(
              height: 50,
              decoration: BoxDecoration(
                border: BorderDirectional(
                  top: BorderSide(width: 0.5, color: Colors.grey.withOpacity(0.3)),
                  bottom: BorderSide(width: 0.5, color: Colors.grey.withOpacity(0.3)),
                ),
              ),
              child: ListTile(
                visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
                onTap: () {
                  setState(() {
                    _statusSelected = transactionStatus;
                  });
                  Navigator.pop(context);
                  _getListLimit();
                },
                title: Text(transactionStatus.name),
                trailing: (_statusSelected.status == transactionStatus.status)
                    ? Icon(Icons.check, size: 16, color: Theme.of(context).primaryColor)
                    : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _itemStatus() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 12,
        children: [
          const Text('Chọn trạng thái hạn mức:'),
          Expanded(
            child: InkWell(
              onTap: () async {
                await showDialog(context: context, builder: (_) => _dialogSelectStatus());
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 1, color: Colors.grey),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    Expanded(child: Text(_statusSelected.name)),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemLimit(LimitModel limit) {
    final double sizeWidth = context.screenSize.width - 16 * 4;
    final double percent = limit.actualAmount / limit.amount;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () async {
          if (limit.id == null) return;
          final bool? result = await context.push(
            AppRoutes.limitInfor,
            extra: LimitInfoProps(isEdit: true, limitData: limit),
          );
          if (result != null && result) {
            _getListLimit();
          }
        },
        child: Container(
          // height: 150,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.grey.withOpacity(0.1)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            limit.limitName ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 18, color: Colors.black),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${formatDate(limit.fromDate)} - ${isNotNullOrEmpty(limit.toDate) ? formatDate(limit.toDate) : 'Không xác định'}',
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Chi: ${formatterDouble(limit.actualAmount.toInt())} $currency',
                          style: const TextStyle(fontSize: 14, color: Colors.red),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Hạn mức: ${formatterDouble(limit.amount.toInt())} $currency',
                          style: const TextStyle(fontSize: 14, color: Colors.black),
                        ),
                      ],
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isNullOrEmpty(limit.toDate)
                            ? ''
                            : (DateTime.now().isBefore(limit.toDate!))
                                ? '(còn ${(limit.toDate?.difference(DateTime.now()))?.inDays} ngày)'
                                : '(đã hết hạn)',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      (overAmount(limit.actualAmount, limit.amount) > 0.0)
                          ? Text(
                              'Vượt hạn mức: ${formatterDouble(overAmount(limit.actualAmount, limit.amount))} $currency',
                              style: const TextStyle(fontSize: 14, color: Colors.red),
                            )
                          : Text(
                              'Vượt hạn mức: --- $currency',
                              style: const TextStyle(fontSize: 14, color: Colors.red),
                            ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Stack(
                    children: [
                      Container(
                        height: 20,
                        width: sizeWidth,
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey.withOpacity(0.5),
                        ),
                        child: percent == 0.00
                            ? const SizedBox.shrink()
                            : Container(
                                height: 20,
                                width: sizeWidth * percent,
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: (percent < 0.5 && percent > 0.0)
                                      ? Colors.green
                                      : (percent > 0.5 && percent < 0.8)
                                          ? Colors.orangeAccent
                                          : Colors.red,
                                ),
                              ),
                      ),
                      Positioned(
                        right: sizeWidth * 0.4,
                        child: Text(
                          percent > 100 ? 'Vượt 100%' : '${(percent * 100).toStringAsFixed(2)} %',
                          style: const TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
