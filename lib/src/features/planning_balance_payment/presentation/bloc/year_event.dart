part of 'year_bloc.dart';
class YearAnalyticEvent extends Equatable {
  final List<int> walletIDs;
  final int year, toYear;

  const YearAnalyticEvent({
    required this.walletIDs,
    required this.year,
    required this.toYear,
  });

  @override
  List<Object?> get props => [walletIDs, year, toYear];
  @override
  bool get stringify => true;
}
