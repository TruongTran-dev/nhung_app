part of 'month_bloc.dart';

class MonthAnalyticEvent extends Equatable {
  final List<int> walletIDs;
  final int year;
  final int? groupId;

  const MonthAnalyticEvent({
    required this.walletIDs,
    required this.year,
    this.groupId,
  });

  @override
  List<Object?> get props => [walletIDs, year, groupId];
  @override
  bool get stringify => true;
}
