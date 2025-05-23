part of 'month_bloc.dart';

class MonthAnalyticEvent extends Equatable {
  final List<int> walletIDs;
  final int year;

  const MonthAnalyticEvent({
    required this.walletIDs,
    required this.year,
  });

  @override
  List<Object?> get props => [walletIDs, year];
  @override
  bool get stringify => true;
}
