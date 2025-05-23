part of 'custom_bloc.dart';


class CustomAnalyticEvent extends Equatable {
  final List<int> walletIDs;
  final String fromTime, toTime;

  const CustomAnalyticEvent({
    required this.walletIDs,
    required this.fromTime,
    required this.toTime,
  });

  @override
  List<Object?> get props => [walletIDs, fromTime, toTime];

  @override
  bool get stringify => true;
}
