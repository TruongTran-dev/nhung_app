import 'package:equatable/equatable.dart';

class PreciousAnalyticEvent extends Equatable {
  final List<int> walletIDs;
  final int year;

  const PreciousAnalyticEvent({
    required this.year,
    required this.walletIDs,
  });

  @override
  List<Object?> get props => [year, walletIDs];
}
