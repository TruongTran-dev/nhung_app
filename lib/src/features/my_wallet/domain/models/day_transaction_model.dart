import 'package:equatable/equatable.dart';
import 'package:expensive_management/src/features/my_wallet/domain/models/collection_model.dart';
import 'package:expensive_management/src/core/utils/app_utils.dart';

class DayTransaction extends Equatable {
  final String date;
  final int amountTotal;
  final List<CollectionModel> transactionOutputs;

  const DayTransaction({
    required this.date,
    required this.amountTotal,
    required this.transactionOutputs,
  });

  factory DayTransaction.fromJson(Map<String, dynamic> json) {
    final List<dynamic> transactionOutputsJson = json['transactionOutputs'] ?? [];
    final List<CollectionModel> transactionOutputs =
        transactionOutputsJson.map((json) => CollectionModel.fromJson(json)).toList();

    return DayTransaction(
      date: json['date'] as String,
      amountTotal: AppUtils.parseDynamicToInt(json['amountTotal']),
      transactionOutputs: transactionOutputs,
    );
  }

  @override
  List<Object?> get props => [date, amountTotal, transactionOutputs];

  @override
  bool get stringify => true;
}
