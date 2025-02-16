import 'data_sfcartesian_char_model.dart';

class WeekReportModel {
  final double total;
  final List<DataSf> detailReport;

  WeekReportModel({required this.total, required this.detailReport});

  factory WeekReportModel.fromJson(Map<String, dynamic> json) =>
      WeekReportModel(
        total: double.parse(json['total'].toString()),
        detailReport: json['detailReport'] == null
            ? []
            : (json['detailReport'] as List<dynamic>)
                .map((e) => DataSf.fromJson(e as Map<String, dynamic>))
                .toList(),
      );

  @override
  String toString() {
    return 'WeekReportModel{total: $total, detailReport: $detailReport}';
  }
}
