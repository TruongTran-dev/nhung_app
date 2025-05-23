part of 'recurring_info_bloc.dart';

abstract class RecurringInfoEvent extends Equatable {
  const RecurringInfoEvent();
  @override
  List<Object?> get props => [];
  @override
  bool get stringify => true;
}

class RecurringInfoInit extends RecurringInfoEvent {}

class AddRecurringEvent extends RecurringInfoEvent {
  final Map<String, dynamic> data;

  const AddRecurringEvent(this.data);
  @override
  List<Object?> get props => [data];
  @override
  bool get stringify => true;
}
