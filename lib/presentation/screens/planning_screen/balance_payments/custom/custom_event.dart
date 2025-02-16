import 'package:equatable/equatable.dart';

class CustomAnalyticEvent extends Equatable {
  final List<int> walletIDs;
  final String fromTime, toTime;

  const CustomAnalyticEvent({
    required this.walletIDs,
    required this.fromTime,
    required this.toTime,
  });

  @override
  List<Object?> get props => [];
}
