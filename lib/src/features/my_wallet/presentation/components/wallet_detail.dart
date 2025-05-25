import 'dart:convert';
import 'dart:developer';

import 'package:expensive_management/data/api/api_path.dart';
import 'package:expensive_management/src/core/common/extensions.dart';
import 'package:expensive_management/src/core/di/injection_container.dart';
import 'package:expensive_management/src/core/utils/app_utils.dart';
import 'package:expensive_management/src/features/collection/presentation/collection_page.dart';
import 'package:expensive_management/src/features/my_wallet/domain/models/collection_model.dart';
import 'package:expensive_management/src/features/my_wallet/domain/models/wallet_report_model.dart';
import 'package:expensive_management/src/shared/routes/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:expensive_management/src/features/my_wallet/domain/models/day_transaction_model.dart';
import 'package:expensive_management/src/features/my_wallet/domain/models/wallet.dart';
import 'package:expensive_management/src/shared/widgets/app_image.dart';
import 'package:expensive_management/src/shared/utils/enum/date_time_picker.dart';
import 'package:expensive_management/src/core/storage/shared_pref_storage.dart';
import 'package:expensive_management/src/shared/utils/utils.dart';

class WalletDetailPage extends StatefulWidget {
  final Wallet wallet;

  const WalletDetailPage({super.key, required this.wallet});

  @override
  State<WalletDetailPage> createState() => _WalletDetailPageState();
}

class _WalletDetailPageState extends State<WalletDetailPage> {
  final AppPrefStorage sharedPref = serviceLocator<AppPrefStorage>();
  String currency = 'VND';

  String toDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String fromDate =
      DateFormat('yyyy-MM-dd').format(DateTime(DateTime.now().year, DateTime.now().month - 1, DateTime.now().day));

  String get _userId => serviceLocator<AppPrefStorage>().getUserId();
  String get _userName => serviceLocator<AppPrefStorage>().getUserName();

  @override
  void initState() {
    currency = sharedPref.getCurrency();
    _fetchWalletDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Theme.of(context).primaryColor,
        leading: InkWell(
          onTap: () => context.pop(),
          child: const Icon(Icons.arrow_back_ios, size: 24, color: Colors.white),
        ),
        centerTitle: true,
        title: Text(
          "Thông tin tài khoản ví",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchWalletDetails,
        child: _body(),
      ),
    );
  }

  Widget _body() {
    return FutureBuilder(
      future: _fetchWalletDetails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error fetching wallet details'));
        }
        final walletReport = snapshot.data;
        if (walletReport == null) {
          return const Center(child: Text('No data available'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _timeReportWidget(),
            _buildCardInfo(
              balance: walletReport.balance,
              incomeTotal: walletReport.incomeTotal,
              expenseTotal: walletReport.expenseTotal,
            ),
            Expanded(child: _infoReport(walletReport.dayTransactionList)),
          ],
        );
      },
    );
  }

  Future<WalletReportData> _fetchWalletDetails() async {
    final Map<String, dynamic> params = {
      'fromDate': fromDate,
      'toDate': toDate,
      'walletId': widget.wallet.id,
      "groupId": widget.wallet.groupId,
    };
    print("Params: $params");

    final dataEmpty = WalletReportData(
      balance: 0,
      incomeTotal: 0,
      expenseTotal: 0,
      dayTransactionList: [],
    );

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
      // final url = Uri.parse("${ApiPath.apiDomain}${ApiPath.getReportByWalletId}"
      //     .replaceAll("{fromDate}", fromDate)
      //     .replaceAll("{toDate}", toDate)
      //     .replaceAll("{walletId}", "${widget.wallet.id}"));
      // if (widget.wallet.groupId != null) {
      //   url.replace(queryParameters: params);
      // }
      final url = Uri.parse("${ApiPath.apiDomain}/api/v1/report/").replace(queryParameters: {
        'fromDate': fromDate,
        'toDate': toDate,
        'walletId': widget.wallet.id.toString(),
        if (widget.wallet.groupId != null) 'groupId': widget.wallet.groupId.toString(),
      });
      print("Request Wallet Report URL: ${url.toString()}");

      final response = await http.get(url, headers: headers).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        log("Response Wallet Report data: ${jsonEncode(data)}");
        return WalletReportData.fromJson(data);
      } else {
        print("Error: ${response.statusCode}");
        return dataEmpty;
      }
    } catch (e) {
      print("Error fetching week report: $e");
      return dataEmpty;
    }
  }

  Widget _buildCardInfo({
    required int balance,
    required int incomeTotal,
    required int expenseTotal,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey.withValues(alpha: 0.1),
        boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 10, offset: const Offset(-3, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Ví: ${widget.wallet.name}",
            style: TextStyle(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold),
          ),
          if (widget.wallet.groupId != null)
            Text(
              "Nhóm: ${widget.wallet.groupName}",
              style: TextStyle(fontSize: 16, color: Colors.black.withValues(alpha: 0.6)),
            ),
          const SizedBox(height: 8),
          Text(
            "Số dư: ${formatterDouble(balance)} $currency",
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
                        '${formatterDouble(incomeTotal)} $currency',
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
                        '${formatterDouble(expenseTotal)} $currency',
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
    );
  }

  Widget _timeReportWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: 24,
        children: [
          Text('Thời gian', style: TextStyle(fontSize: 16, color: Colors.black)),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildItemTime(title: 'Từ', isFrom: true),
                _buildItemTime(title: 'Đến', isFrom: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemTime({String? title, bool isFrom = false}) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$title: '),
          Padding(
            padding: EdgeInsets.only(right: isFrom ? 10 : 0),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
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
                // whenComplete: _reloadPage,
              ),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 1, color: Theme.of(context).primaryColor),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  isFrom ? fromDate : toDate,
                  style: TextStyle(fontSize: 14),
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
                return dayTransaction.transactionOutputs.isNotEmpty
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

  void _onTapItemReport(CollectionModel collection) {
    if (_userId.isNullOrEmpty || _userId != collection.createdBy.toString()) {
      return;
    }
    context.push(AppRoutes.newCollection, extra: CollectionInfoProps(isEdit: true, collection: collection));
  }

  Widget _createItemReport(bool isLastIndex, DayTransaction dayTransaction) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 20, 16, isLastIndex ? 32 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dayTransaction.date, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          ...dayTransaction.transactionOutputs.mapIndexed((index, collectionInfo) {
            final isExpense = collectionInfo.transactionType == 'EXPENSE';
            return ElevatedButton(
              onPressed: () {
                _onTapItemReport(collectionInfo);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.grey,
                elevation: 0,
                padding: EdgeInsets.zero,
                // shape: RoundedRectangleBorder(
                //   borderRadius: BorderRadius.circular(0),
                //   side: BorderSide(width: 1, color: Colors.grey.withOpacity(0.2), style: BorderStyle.solid),
                // ),
              ),
              child: Container(
                padding: EdgeInsets.fromLTRB(12, 4, 0, 4),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 1, color: Colors.grey.withOpacity(0.2)),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Row(
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
                          '${isExpense ? "-" : "+"} ${formatterDouble((collectionInfo.amount ?? 0).toInt())} $currency',
                          style: TextStyle(fontSize: 16, color: isExpense ? Colors.redAccent : Colors.greenAccent),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: !_userId.isNullOrEmpty && _userId == collectionInfo.createdBy.toString()
                              ? Colors.grey.withValues(alpha: 0.7)
                              : Colors.grey.withValues(alpha: 0.2),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                          Text(
                            '- Người tạo: ${_userId.isNullOrEmpty || _userId != collectionInfo.createdBy.toString() ? collectionInfo.createdByName ?? "(Không xác định)" : _userName.isNullOrEmpty ? collectionInfo.createdByName ?? "(Không xác định)" : _userName}',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          collectionInfo.description.isNullOrEmpty
                              ? const SizedBox.shrink()
                              : Text(
                                  '- Ghi chú: ${collectionInfo.description!}',
                                  style: TextStyle(fontSize: 14, color: Colors.grey),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
