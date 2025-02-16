class CategoryReportModel {
  final String categoryName;
  final double percent;

  CategoryReportModel({
    required this.categoryName,
    required this.percent,
  });

  factory CategoryReportModel.fromJson(Map<String, dynamic> json) =>
      CategoryReportModel(
        categoryName: json['categoryName'],
        percent: double.parse(json['percent'].toString()),
      );

  @override
  String toString() {
    return 'CategoryReportModel{categoryName: $categoryName, percent: $percent}';
  }
}
