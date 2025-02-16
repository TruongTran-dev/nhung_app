import 'day_transaction_model.dart';

class WalletReport {
  final double? expenseTotal;
  final double? incomeTotal;
  final double? currentBalance;
  final List<DayTransaction>? dayTransactionList;

  WalletReport({
    this.expenseTotal,
    this.incomeTotal,
    this.currentBalance,
    this.dayTransactionList,
  });
  factory WalletReport.fromJson(Map<String, dynamic> json) {
    final List<dynamic> dayTransactionListJson = json['dayTransactionList'];
    final List<DayTransaction> dayTransactionList = dayTransactionListJson
        .map(
            (dayTransactionJson) => DayTransaction.fromJson(dayTransactionJson))
        .toList();

    return WalletReport(
      expenseTotal: double.parse(json['expenseTotal'].toString()),
      incomeTotal: double.parse(json['incomeTotal'].toString()),
      currentBalance: double.parse(json['currentBalance'].toString()),
      dayTransactionList: dayTransactionList,
    );
  }

  @override
  String toString() {
    return 'WalletReport{expenseTotal: $expenseTotal, incomeTotal: $incomeTotal, currentBalance: $currentBalance, dayTransactionList: $dayTransactionList}';
  }
}
