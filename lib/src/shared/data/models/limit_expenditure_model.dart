import 'package:equatable/equatable.dart';
import 'package:expensive_management/src/features/my_wallet/domain/models/wallet.dart';

class LimitModel extends Equatable {
  final int id;
  final double amount;
  final double actualAmount;
  final String limitName;
  final List<String>? categoryIds;
  final List<String>? walletIds;
  final List<Wallet>? listWallet;
  final DateTime? fromDate;
  final DateTime? toDate;

  const LimitModel({
    required this.id,
    required this.amount,
    required this.actualAmount,
    this.limitName = '',
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
      categoryIds: json['categoryIds'] != null ? List<String>.from(json['categoryIds']) : null,
      walletIds: json['walletIds'] != null ? List<String>.from(json['walletIds']) : null,
      listWallet: json['walletOutputs'] != null
          ? (json['walletOutputs'] as List<dynamic>)
              .map((wallet) => Wallet.fromJson(wallet as Map<String, dynamic>))
              .toList()
          : null,
      fromDate: json['fromDate'] != null ? DateTime.parse(json['fromDate'].toString()) : null,
      toDate: json['toDate'] != null ? DateTime.parse(json['toDate'].toString()) : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        amount,
        actualAmount,
        limitName,
        categoryIds,
        walletIds,
        listWallet,
        fromDate,
        toDate,
      ];

  @override
  bool get stringify => true;
}
