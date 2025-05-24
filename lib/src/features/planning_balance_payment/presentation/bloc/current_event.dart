part of 'current_bloc.dart';

class CurrentAnalyticEvent extends Equatable {
  final List<int> walletIDs;
  final int? groupId;

  const CurrentAnalyticEvent({
    required this.walletIDs,
    this.groupId,
  });

  @override
  List<Object?> get props => [walletIDs];
  @override
  bool get stringify => true;
}
