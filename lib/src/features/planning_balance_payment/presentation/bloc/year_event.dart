part of 'year_bloc.dart';
class YearAnalyticEvent extends Equatable {
  final List<int> walletIDs;
  final int year, toYear;
  final int? groupId;

  const YearAnalyticEvent({
    required this.walletIDs,
    required this.year,
    required this.toYear,
    this.groupId,
  });

  @override
  List<Object?> get props => [walletIDs, year, toYear , groupId];
  @override
  bool get stringify => true;
}
