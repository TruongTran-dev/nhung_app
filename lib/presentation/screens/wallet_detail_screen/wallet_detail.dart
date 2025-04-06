import 'package:expensive_management/app/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:expensive_management/app/app_routes.dart';
import 'package:expensive_management/data/models/collection_model.dart';
import 'package:expensive_management/data/models/day_transaction_model.dart';
import 'package:expensive_management/data/models/wallet.dart';
import 'package:expensive_management/data/models/wallet_report_model.dart';
import 'package:expensive_management/business/blocs/wallet_details_bloc.dart';
import 'package:expensive_management/presentation/screens/wallet_detail_screen/wallet_details_event.dart';
import 'package:expensive_management/presentation/screens/wallet_detail_screen/wallet_details_state.dart';
import 'package:expensive_management/presentation/widgets/app_image.dart';
import 'package:expensive_management/utils/enum/api_error_result.dart';
import 'package:expensive_management/utils/enum/date_time_picker.dart';
import 'package:expensive_management/utils/screen_utilities.dart';
import 'package:expensive_management/utils/shared_preferences_storage.dart';
import 'package:expensive_management/utils/utils.dart';

class WalletDetail extends StatefulWidget {
  final Wallet wallet;

  const WalletDetail({super.key, required this.wallet});

  @override
  State<WalletDetail> createState() => _WalletDetailState();
}

class _WalletDetailState extends State<WalletDetail> {
  late WalletDetailBloc _walletDetailsBloc;

  final String currency = SharedPreferencesStorage().getCurrency();

  String toDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String fromDate =
      DateFormat('yyyy-MM-dd').format(DateTime(DateTime.now().year, DateTime.now().month - 1, DateTime.now().day));

  @override
  void initState() {
    _walletDetailsBloc = BlocProvider.of<WalletDetailBloc>(context)..add(WalletDetailInit(walletId: widget.wallet.id));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _reloadPage() {
    showLoading(context);
    _walletDetailsBloc.add(WalletDetailInit(walletId: widget.wallet.id, fromDate: fromDate, toDate: toDate));
    Future.delayed(const Duration(milliseconds: 1500), () {
      Navigator.pop(context);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<WalletDetailBloc, WalletDetailState>(
      listenWhen: (preState, curState) {
        return curState.apiError != ApiError.noError;
      },
      listener: (context, curState) {
        if (curState.apiError == ApiError.internalServerError) {
          showMessage1OptionDialog(context, 'Error!', content: 'Internal_server_error');
        }
        if (curState.apiError == ApiError.noInternetConnection) {
          showMessage1OptionDialog(context, 'Error!', content: 'No_internet_connection');
        }
      },
      builder: (context, curState) {
        return _body(context, curState.walletReport);
      },
    );
  }

  Widget _body(BuildContext context, WalletReport? walletReport) {
    if (walletReport == null) {
      return const SizedBox.shrink();
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Theme.of(context).primaryColor,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios, size: 24, color: Colors.white),
        ),
        centerTitle: true,
        title: Text(
          widget.wallet.name ?? '',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _reloadPage(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _timeReport(),

            Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              padding: EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.withValues(alpha: 0.8),
                boxShadow: [
                  BoxShadow(color: Colors.grey, blurRadius: 10, offset: const Offset(-3, 3)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.wallet.name ?? '',
                    style: TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Số dư: ${formatterDouble(walletReport.currentBalance)} $currency",
                    style: TextStyle(fontSize: 18, color: Colors.black.withValues(alpha: 0.6)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    spacing: 12,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.green.withValues(alpha: 0.65),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text('Tổng thu', style: TextStyle(fontSize: 16, color: Colors.white)),
                              Text(
                                '${formatterDouble(walletReport.incomeTotal)} $currency',
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.red.withValues(alpha: 0.5),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Text('Tổng chi', style: TextStyle(fontSize: 16, color: Colors.white)),
                              Text(
                                '${formatterDouble(walletReport.expenseTotal)} $currency',
                                style: const TextStyle(fontSize: 16, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            // Container(
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(15),
            //     color: Colors.white,
            //   ),
            //   child: Padding(
            //     padding: const EdgeInsets.all(10),
            //     child: Row(
            //       crossAxisAlignment: CrossAxisAlignment.center,
            //       children: [
            //         Expanded(
            //           child: Column(
            //             crossAxisAlignment: CrossAxisAlignment.center,
            //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //             children: [
            //               Text('Tổng thu', style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor)),
            //               Text('${formatterDouble(walletReport.incomeTotal)} $currency',
            //                   style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor)),
            //             ],
            //           ),
            //         ),
            //         Container(width: 1, color: Colors.grey),
            //         Expanded(
            //           child: Column(
            //             crossAxisAlignment: CrossAxisAlignment.center,
            //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //             children: [
            //               const Text('Tổng chi', style: TextStyle(fontSize: 16, color: Colors.redAccent)),
            //               Text('${formatterDouble(walletReport.expenseTotal)} $currency',
            //                   style: const TextStyle(fontSize: 16, color: Colors.redAccent)),
            //             ],
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),

            Expanded(child: _infoReport(walletReport.dayTransactionList ?? [])),
          ],
        ),
      ),
    );
  }

  Widget _timeReport() {
    return Container(
      height: 50,
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16.0),
            child: Text('Thời gian', style: TextStyle(fontSize: 16, color: Colors.black)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _time(title: 'Từ', isFrom: true),
                  _time(title: 'Đến', isFrom: false),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _time({String? title, bool isFrom = false}) {
    return Expanded(
      child: Row(
        children: [
          Text('$title: '),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: isFrom ? 10 : 0),
              child: InkWell(
                onTap: () => showDatePickerPlus(
                  context,
                  minTime: DateTime(2000, 01, 01),
                  maxTime: DateTime(2025, 12, 30),
                  currentTime: isFrom
                      ? DateTime(DateTime.now().year, DateTime.now().month - 1, DateTime.now().day)
                      : DateTime.now(),
                  onConfirm: (date) {
                    setState(() {
                      isFrom
                          ? fromDate = DateFormat('yyyy-MM-dd').format(date)
                          : toDate = DateFormat('yyyy-MM-dd').format(date);
                    });
                  },
                  onCancel: () {
                    setState(() {});
                  },
                  whenComplete: _reloadPage,
                ),
                child: Container(
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(width: 1, color: Theme.of(context).primaryColor),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                            padding: const EdgeInsets.only(left: 10.0), child: Text(isFrom ? fromDate : toDate)),
                      ),
                      Icon(Icons.expand_more, size: 16, color: Theme.of(context).primaryColor),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoReport(List<DayTransaction> listDayTransaction) {
    return SizedBox(
      child: isNotNullOrEmpty(listDayTransaction)
          ? ListView.builder(
              itemCount: listDayTransaction.length,
              itemBuilder: (context, index) {
                final dayTransaction = listDayTransaction[index];
                return (dayTransaction.transactionOutputs != null && dayTransaction.transactionOutputs!.isNotEmpty)
                    ? _createItemReport(index == listDayTransaction.length - 1, dayTransaction)
                    : const SizedBox.shrink();
              },
            )
          : Center(
              child: Text(
                'Chưa có ghi chép chi tiêu nào',
                style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor),
              ),
            ),
    );
  }

  Widget _createItemReport(bool isLastIndex, DayTransaction dayTransaction) {
    // final total = dayTransaction.transactionOutputs?.fold<double>(0, (previousValue, element) {
    //   if (element.transactionType == 'EXPENSE') {
    //     return previousValue - element.amount!;
    //   } else {
    //     return previousValue + element.amount!;
    //   }
    // });
    // final bool isNegative = total != null && total < 0;
    // final String value = "${isNegative ? "- " : ""}${formatterDouble(isNegative ? -total : total)} $currency";

    return Container(
      padding: EdgeInsets.fromLTRB(16, 20, 16, isLastIndex ? 32 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${dayTransaction.date}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
          if (dayTransaction.transactionOutputs != null && dayTransaction.transactionOutputs!.isNotEmpty)
            ...dayTransaction.transactionOutputs!.mapIndexed((index, collectionInfo) {
              final isExpense = collectionInfo.transactionType == 'EXPENSE';
              return Container(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(width: 1, color: Colors.grey.withOpacity(0.2)),
                  ),
                ),
                child: Row(
                  spacing: 10,
                  children: [
                    Container(
                      height: 32,
                      width: 32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey.withOpacity(0.2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: AppImage(
                          localPathOrUrl: collectionInfo.categoryLogo,
                          boxFit: BoxFit.contain,
                          errorWidget: const Icon(Icons.help_outline, size: 24, color: Colors.grey),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${collectionInfo.categoryName}',
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                    Text(
                      '${isExpense ? "-" : "+"} ${formatterDouble(collectionInfo.amount)} $currency',
                      style: TextStyle(fontSize: 16, color: isExpense ? Colors.redAccent : Colors.greenAccent),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );

    // return Padding(
    //   padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
    //   child: Container(
    //     decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.white),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         Padding(
    //           padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    //           child: Row(
    //             crossAxisAlignment: CrossAxisAlignment.center,
    //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //             children: [
    //               Text('${dayTransaction?.date}', style: const TextStyle(fontSize: 16, color: Colors.black)),
    //               //TODO: recheck amountTotal it's incorrect when have income and expense
    //               // Text('${formatterDouble(dayTransaction?.amountTotal)} $currency'),
    //               Text(
    //                 value,
    //                 style: TextStyle(
    //                   fontSize: 16,
    //                   color: isNegative ? Colors.red : Colors.green,
    //                   fontWeight: FontWeight.bold,
    //                 ),
    //               ),
    //             ],
    //           ),
    //         ),
    //         const Divider(height: 1, color: Colors.grey),
    //         if (isNotNullOrEmpty(dayTransaction?.transactionOutputs))
    //           SizedBox(
    //             height: 60 * (dayTransaction?.transactionOutputs!.length ?? 1).toDouble(),
    //             child: ListView.builder(
    //               physics: const NeverScrollableScrollPhysics(),
    //               itemCount: dayTransaction?.transactionOutputs!.length,
    //               itemBuilder: (context, index) => _createItemTransaction(dayTransaction?.transactionOutputs![index]),
    //             ),
    //           ),
    //       ],
    //     ),
    //   ),
    // );
  }

  Widget _createItemTransaction(CollectionModel? collectionInfo) {
    final isExpense = collectionInfo?.transactionType == 'EXPENSE';
    if (isNullOrEmpty(collectionInfo)) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 52,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 12),
        onTap: () async {
          final result = await Navigator.pushNamed(context, AppRoutes.collection, arguments: collectionInfo);
          if (result != null) {
            _reloadPage();
          } else {
            return;
          }
        },
        leading: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.grey.withOpacity(0.2)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AppImage(
              localPathOrUrl: collectionInfo?.categoryLogo,
              boxFit: BoxFit.contain,
              errorWidget: const Icon(Icons.help_outline, size: 30, color: Colors.grey),
            ),
          ),
        ),
        title: Text('${collectionInfo?.categoryName}', style: const TextStyle(fontSize: 16, color: Colors.black)),
        trailing: Text(
          '${isExpense ? "-" : "+"} ${formatterDouble(collectionInfo?.amount)} $currency',
          style: TextStyle(fontSize: 16, color: isExpense ? Colors.redAccent : Colors.greenAccent),
        ),
      ),
    );
  }
}
