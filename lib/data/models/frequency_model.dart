import 'package:expensive_management/utils/enum/enum.dart';

class Frequency {
  final String title;
  final FrequencyType frequencyType;

  Frequency({
    required this.title,
    required this.frequencyType,
  });

  @override
  String toString() {
    return 'Frequency{title: $title, frequencyType: $frequencyType}';
  }
}

class DayOfWeek {
  final int index;
  final String title;
  final String en;

  DayOfWeek(this.index, this.title, this.en);

  @override
  String toString() {
    return 'DayOfWeek{index: $index, title: $title, en: $en}';
  }
}

List<DayOfWeek> listDayOfWeek = [
  DayOfWeek(1, 'Thứ 2', 'Monday'),
  DayOfWeek(2, 'Thứ 3', 'Tuesday'),
  DayOfWeek(3, 'Thứ 4', 'Wednesday'),
  DayOfWeek(4, 'Thứ 5', 'Thursday'),
  DayOfWeek(5, 'Thứ 6', 'Friday'),
  DayOfWeek(6, 'Thứ 7', 'Saturday'),
  DayOfWeek(7, 'Chủ nhật', 'Sunday'),
];

List<Frequency> listFrequency = [
  Frequency(title: 'Hàng ngày', frequencyType: FrequencyType.daily),
  Frequency(title: 'Hàng tuần', frequencyType: FrequencyType.week),
  Frequency(title: 'Hàng tháng', frequencyType: FrequencyType.monthly),
  Frequency(title: 'Hàng quý', frequencyType: FrequencyType.quarterly),
  Frequency(title: 'Hàng năm', frequencyType: FrequencyType.yearly),
  Frequency(title: 'Ngày trong tuần', frequencyType: FrequencyType.weekday),
];
