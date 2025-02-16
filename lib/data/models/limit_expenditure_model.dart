import 'package:expensive_management/data/models/wallet.dart';

class LimitModel {
  final int? id;
  final double amount;
  final double actualAmount;
  final String? limitName;
  final List<String>? categoryIds;
  final List<String>? walletIds;
  final List<Wallet>? listWallet;
  final DateTime? fromDate;
  final DateTime? toDate;

  LimitModel({
    this.id,
    required this.amount,
    required this.actualAmount,
    this.limitName,
    this.categoryIds,
    this.walletIds,
    this.listWallet,
    this.fromDate,
    this.toDate,
  });

  factory LimitModel.fromJson(Map<String, dynamic> json) {
    return LimitModel(
      id: json['id'],
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      actualAmount: double.tryParse(json['actualAmount'].toString()) ?? 0.0,
      limitName: json['limitName'],
      categoryIds: List<String>.from(json['categoryIds']),
      walletIds: List<String>.from(json['walletIds']),
      listWallet: json['walletOutputs'] == null ? [] : (json['walletOutputs'] as List<dynamic>).map((report) => Wallet.fromJson(report as Map<String, dynamic>)).toList(),
      fromDate: DateTime.parse(json['fromDate']),
      toDate: json['toDate'] != null ? DateTime.parse(json['toDate'].toString()) : null,
    );
  }
}
