class CategoryReport {
  final String time;
  final double totalAmount;

  CategoryReport({
    required this.time,
    required this.totalAmount,
  });

  factory CategoryReport.fromJson(Map<String, dynamic> json) {
    return CategoryReport(
      time: json['time'] as String,
      totalAmount: double.parse(json['totalAmount'].toString()),
    );
  }

  @override
  String toString() {
    return 'CategoryReport{time: $time, totalAmount: $totalAmount}';
  }
}

class AnalyticModel {
  final double totalAmount;
  final double mediumAmount;
  final List<CategoryReport> categoryReports;

  AnalyticModel({
    required this.totalAmount,
    required this.mediumAmount,
    required this.categoryReports,
  });

  factory AnalyticModel.fromJson(Map<String, dynamic> json) {
    return AnalyticModel(
      totalAmount: double.parse(json['totalAmount'].toString()),
      mediumAmount: double.parse(json['mediumAmount'].toString()),
      categoryReports: (json['categoryReports'] as List<dynamic>).map((report) => CategoryReport.fromJson(report as Map<String, dynamic>)).toList(),
    );
  }

  @override
  String toString() {
    return 'Report{totalAmount: $totalAmount, mediumAmount: $mediumAmount, categoryReports: $categoryReports}';
  }
}
