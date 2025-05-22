import 'package:equatable/equatable.dart';

class WeekReportModel extends Equatable {
  final double total;
  final List<DataSf> detailReport;

  const WeekReportModel({required this.total, required this.detailReport});

  @override
  List<Object?> get props => [total, detailReport];

  @override
  bool get stringify => true;

  factory WeekReportModel.fromJson(Map<String, dynamic> json) => WeekReportModel(
        total: double.parse(json['total'].toString()),
        detailReport:
            (json['detailReport'] as List<dynamic>?)?.map((e) => DataSf.fromJson(e as Map<String, dynamic>)).toList() ??
                [],
      );

  WeekReportModel copyWith({
    double? total,
    List<DataSf>? detailReport,
  }) =>
      WeekReportModel(
        total: total ?? this.total,
        detailReport: detailReport ?? this.detailReport,
      );
}

class DataSf extends Equatable {
  final String title;
  final double value;

  const DataSf({required this.title, required this.value});

  @override
  List<Object?> get props => [title, value];

  @override
  bool get stringify => true;

  factory DataSf.fromJson(Map<String, dynamic> json) => DataSf(
        title: json['time'] as String,
        value: double.parse(json['totalAmount'].toString()),
      );

  DataSf copyWith({
    String? title,
    double? value,
  }) =>
      DataSf(
        title: title ?? this.title,
        value: value ?? this.value,
      );
}
