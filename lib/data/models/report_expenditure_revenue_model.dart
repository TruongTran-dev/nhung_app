import '../../utils/utils.dart';

class ReportData {
  final String name;
  final double incomeTotal;
  final double expenseTotal;
  final double remainTotal;

  ReportData({
    required this.name,
    required this.incomeTotal,
    required this.expenseTotal,
    required this.remainTotal,
  });

  factory ReportData.fromJson(Map<String, dynamic> json) {
    return ReportData(
      name: isNotNullOrEmpty(json['name']) ? (json['name'] as String) : '',
      incomeTotal: double.parse(json['incomeTotal'].toString()),
      expenseTotal: double.parse(json['expenseTotal'].toString()),
      remainTotal: double.parse(json['remainTotal'].toString()),
    );
  }

  @override
  String toString() {
    return 'ReportData{name: $name, incomeTotal: $incomeTotal, expenseTotal: $expenseTotal, remainTotal: $remainTotal}';
  }
}
