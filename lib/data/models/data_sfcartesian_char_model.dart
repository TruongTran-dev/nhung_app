class DataSf {
  final String title;
  final double value;

  DataSf({required this.title, required this.value});

  factory DataSf.fromJson(Map<String, dynamic> json) => DataSf(
        title: json['time'],
        value: double.parse(json['totalAmount'].toString()),
      );

  @override
  String toString() {
    return 'DataSf{title: $title, value: $value}';
  }
}
