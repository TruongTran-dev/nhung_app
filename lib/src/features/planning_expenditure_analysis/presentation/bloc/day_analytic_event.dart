part of 'day_analytic_bloc.dart';

class DayAnalyticEvent extends Equatable {
  final String fromDate, toDate;
  final List<int> walletIDs, categoryIDs;
  final TransactionType type;
  final int? groupId;

  const DayAnalyticEvent({
    required this.fromDate,
    required this.toDate,
    required this.walletIDs,
    required this.categoryIDs,
    required this.type,
    this.groupId,
  });

  @override
  List<Object?> get props => [fromDate, toDate, walletIDs, categoryIDs, type, groupId];

  @override
  bool get stringify => true;
}
