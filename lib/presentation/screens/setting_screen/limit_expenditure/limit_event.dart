import 'package:equatable/equatable.dart';
import 'package:expensive_management/utils/enum/enum.dart';

abstract class LimitEvent extends Equatable {
  const LimitEvent();

  @override
  List<Object?> get props => [];
}

class GetListLimitEvent extends LimitEvent {
  final TransactionStatus status;

  const GetListLimitEvent({this.status = TransactionStatus.on_going});

  @override
  List<Object?> get props => [status];
}
