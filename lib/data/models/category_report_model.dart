import 'package:equatable/equatable.dart';


class DailyReportModel extends Equatable {
  final String time;
  final double totalAmount;

  const DailyReportModel({
    required this.time,
    required this.totalAmount,
  });

  factory DailyReportModel.fromJson(Map<String, dynamic> json) => DailyReportModel(
        time: json['time'],
        totalAmount: double.parse(json['totalAmount'].toString()),
      );

  @override
  List<Object?> get props => [time, totalAmount];

  @override
  String toString() {
    return 'DailyReportModel{time: $time, totalAmount: $totalAmount}';
  }
}

class WeeklyReportModel extends Equatable {
  final double total;
  final List<DailyReportModel> detailReport;

  const WeeklyReportModel({
    required this.total,
    required this.detailReport,
  });

  factory WeeklyReportModel.fromJson(Map<String, dynamic> json) => WeeklyReportModel(
        total: double.parse(json['total'].toString()),
        detailReport: List<DailyReportModel>.from(
          (json['detailReport'] as List).map((item) => DailyReportModel.fromJson(item)),
        ),
      );

  @override
  List<Object?> get props => [total, detailReport];

  @override
  String toString() {
    return 'WeeklyReportModel{total: $total, detailReport: $detailReport}';
  }
}
