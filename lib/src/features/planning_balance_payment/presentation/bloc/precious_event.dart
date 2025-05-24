part of 'precious_bloc.dart';
class PreciousAnalyticEvent extends Equatable {
  final List<int> walletIDs;
  final int year;
  final int? groupId;

  const PreciousAnalyticEvent({
    required this.year,
    required this.walletIDs,
    this.groupId,
  });

  @override
  List<Object?> get props => [year, walletIDs];
  @override
  bool get stringify => true;
}
