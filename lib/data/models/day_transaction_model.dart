import 'collection_model.dart';

class DayTransaction {
  final String? date;
  final double? amountTotal;
  final List<CollectionModel>? transactionOutputs;

  DayTransaction({
    this.date,
    this.amountTotal,
    this.transactionOutputs,
  });

  factory DayTransaction.fromJson(Map<String, dynamic> json) {
    final List<dynamic> transactionOutputsJson = json['transactionOutputs'];
    final List<CollectionModel> transactionOutputs = transactionOutputsJson.map((transactionOutputJson) => CollectionModel.fromJson(transactionOutputJson)).toList();

    return DayTransaction(
      date: json['date'] as String?,
      amountTotal: double.parse(json['amountTotal'].toString()),
      transactionOutputs: transactionOutputs,
    );
  }

  @override
  String toString() {
    return 'DayTransaction{date: $date, amountTotal: $amountTotal, transactionOutputs: $transactionOutputs}';
  }
}
