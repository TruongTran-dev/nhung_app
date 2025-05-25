part of 'year_analytic_bloc.dart';

class YearAnalyticEvent extends Equatable {
  final String fromYear, toYear;
  final List<int> walletIDs, categoryIDs;
  final TransactionType type;
  final int? groupId;
  const YearAnalyticEvent({
    required this.fromYear,
    required this.toYear,
    required this.walletIDs,
    required this.categoryIDs,
    this.type = TransactionType.expense,
    this.groupId,
  });

  @override
  List<Object?> get props => [fromYear, toYear, walletIDs, categoryIDs, type, groupId];
  @override
  bool get stringify => true;
}
