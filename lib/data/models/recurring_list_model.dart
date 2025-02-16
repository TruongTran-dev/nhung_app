import 'package:expensive_management/utils/enum/enum.dart';

class RecurringListModel {
  final int? id;
  final double? amount;
  final int? categoryId;
  final String? categoryName;
  final String? categoryLogo;
  final String? description;
  final int? walletId;
  final String? walletName;
  final bool? addToReport;
  final TransactionType? transactionType;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? time;
  final FrequencyType? frequencyType;
  final List<String>? dayInWeeks;

  RecurringListModel({
    this.id,
    this.amount,
    this.categoryId,
    this.categoryName,
    this.categoryLogo,
    this.description,
    this.walletId,
    this.walletName,
    this.addToReport,
    this.transactionType,
    this.fromDate,
    this.toDate,
    this.time,
    this.frequencyType,
    this.dayInWeeks,
  });

  factory RecurringListModel.fromJson(Map<String, dynamic> json) =>
      RecurringListModel(
        id: json['id'] ?? 0,
        amount: json['amount'] ?? 0.0,
        categoryId: json['categoryId'] ?? 0,
        categoryName: json['categoryName'] ?? '',
        categoryLogo: json['categoryLogo'] ?? '',
        description: json['description'] ?? '',
        walletId: json['walletId'] ?? 0,
        walletName: json['walletName'] ?? '',
        addToReport: json['addToReport'] ?? false,
        transactionType: getTransactionType(json['transactionType'] ?? ''),
        fromDate: DateTime.parse(json['fromDate'] ?? ''),
        toDate: json['toDate'] != null ? DateTime.parse(json['toDate']) : null,
        time: json['time'] ?? '',
        frequencyType: getFrequencyType(json['frequencyType'] ?? ''),
        dayInWeeks: List<String>.from(json['dayInWeeks'] ?? []),
      );

  @override
  String toString() {
    return 'RecurringListModel{id: $id, amount: $amount, categoryId: $categoryId, categoryName: $categoryName, categoryLogo: $categoryLogo, description: $description, walletId: $walletId, walletName: $walletName, addToReport: $addToReport, transactionType: $transactionType, fromDate: $fromDate, toDate: $toDate, time: $time, frequencyType: $frequencyType, dayInWeeks: $dayInWeeks}';
  }
}


TransactionType getTransactionType(String transactionTypeString) {
  switch (transactionTypeString.toUpperCase()) {
    case 'EXPENSE':
      return TransactionType.expense;
    case 'INCOME':
      return TransactionType.income;
    default:
    // Handle unrecognized transaction type if needed
      throw Exception('Invalid transaction type: $transactionTypeString');
  }
}

FrequencyType getFrequencyType(String frequencyTypeString) {
  switch (frequencyTypeString.toUpperCase()) {
    case 'DAILY':
      return FrequencyType.daily;
    case 'WEEK':
      return FrequencyType.week;
    case 'MONTHLY':
      return FrequencyType.monthly;
    case 'QUARTERLY':
      return FrequencyType.quarterly;
    case 'YEARLY':
      return FrequencyType.yearly;
    case 'WEEKDAY':
      return FrequencyType.weekday;
    default:
    // Handle unrecognized frequency type if needed
      throw Exception('Invalid frequency type: $frequencyTypeString');
  }
}
