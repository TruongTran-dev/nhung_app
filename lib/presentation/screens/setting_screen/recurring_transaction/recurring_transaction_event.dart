import 'package:equatable/equatable.dart';

abstract class RecurringTransactionEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class RecurringInit extends RecurringTransactionEvent {
  final Map<String, dynamic>? query;

  RecurringInit({this.query});
}
