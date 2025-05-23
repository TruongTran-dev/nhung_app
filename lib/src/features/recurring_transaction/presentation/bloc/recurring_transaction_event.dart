part of 'recurring_transaction_bloc.dart';

abstract class RecurringTransactionEvent extends Equatable {
  const RecurringTransactionEvent();

  @override
  List<Object?> get props => [];
  @override
  bool get stringify => true;
}

class RecurringInit extends RecurringTransactionEvent {
  final Map<String, dynamic>? query;

  const RecurringInit({this.query});
  @override
  List<Object?> get props => [query];
  @override
  bool get stringify => true;
}
