part of 'day_analytic_bloc.dart';

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

  @override
  bool get stringify => true;
}
