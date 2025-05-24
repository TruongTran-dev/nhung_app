part of 'custom_bloc.dart';


class CustomAnalyticEvent extends Equatable {
  final List<int> walletIDs;
  final String fromTime, toTime;
  final int? groupId;

  const CustomAnalyticEvent({
    required this.walletIDs,
    required this.fromTime,
    required this.toTime,
    this.groupId,
  });

  @override
  List<Object?> get props => [walletIDs, fromTime, toTime];

  @override
  bool get stringify => true;
}
