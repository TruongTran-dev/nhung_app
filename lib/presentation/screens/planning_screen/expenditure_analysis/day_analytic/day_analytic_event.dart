import 'package:equatable/equatable.dart';
import 'package:expensive_management/utils/enum/enum.dart';

class DayAnalyticEvent extends Equatable {
  final String fromDate, toDate;
  final List<int> walletIDs, categoryIDs;
  final TransactionType type;

  const DayAnalyticEvent({
    required this.fromDate,
    required this.toDate,
    required this.walletIDs,
    required this.categoryIDs,
    required this.type,
  });

  @override
  List<Object?> get props => [fromDate, toDate, walletIDs, categoryIDs, type];
}
