import 'package:equatable/equatable.dart';
import 'package:expensive_management/src/core/utils/app_utils.dart';
import 'package:expensive_management/src/features/my_wallet/domain/models/day_transaction_model.dart';

class WalletReportData extends Equatable {
  final int expenseTotal;
  final int incomeTotal;
  final int balance;
  final List<DayTransaction> dayTransactionList;

  const WalletReportData({
    required this.expenseTotal,
    required this.incomeTotal,
    required this.balance,
    required this.dayTransactionList,
  });

  factory WalletReportData.fromJson(Map<String, dynamic> json) {
    List<DayTransaction> dayTransactionList = [];
    final daytransaction = json['dayTransactionList'];
    if (daytransaction != null && daytransaction is List) {
      dayTransactionList = daytransaction.map((item) => DayTransaction.fromJson(item)).toList();
    }

    return WalletReportData(
      expenseTotal: AppUtils.parseDynamicToInt(json['expenseTotal']),
      incomeTotal: AppUtils.parseDynamicToInt(json['incomeTotal']),
      balance: AppUtils.parseDynamicToInt(json['currentBalance']),
      dayTransactionList: dayTransactionList,
    );
  }
  @override
  List<Object?> get props => [
        expenseTotal,
        incomeTotal,
        balance,
        dayTransactionList,
      ];

  @override
  bool get stringify => true;
}
