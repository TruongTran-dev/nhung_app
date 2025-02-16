import 'package:equatable/equatable.dart';

class CurrentAnalyticEvent extends Equatable {
  final List<int> walletIDs;

  const CurrentAnalyticEvent({
    required this.walletIDs,
  });

  @override
  List<Object?> get props => [];
}
