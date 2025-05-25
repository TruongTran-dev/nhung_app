part of 'month_analytic_bloc.dart';

class MonthAnalyticEvent extends Equatable {
  final String fromMonth, toMonth;
  final List<int> walletIDs, categoryIDs;
  final TransactionType type;
  final int? groupId;

  const MonthAnalyticEvent({
    required this.fromMonth,
    required this.toMonth,
    required this.walletIDs,
    required this.categoryIDs,
    this.type = TransactionType.expense,
    this.groupId,
  });

  @override
  List<Object?> get props => [fromMonth, toMonth, walletIDs, categoryIDs, type, groupId];

  @override
  bool get stringify => true;
}
