part of 'recurring_info_bloc.dart';

abstract class RecurringInfoEvent extends Equatable {
  const RecurringInfoEvent();
  @override
  List<Object?> get props => [];
  @override
  bool get stringify => true;
}

class AddRecurringEvent extends RecurringInfoEvent {
  final Map<String, dynamic> data;

  const AddRecurringEvent(this.data);
  @override
  List<Object?> get props => [data];
  @override
  bool get stringify => true;
}

class UpdateRecurringEvent extends RecurringInfoEvent {
  final int id;
  final Map<String, dynamic> data;

  const UpdateRecurringEvent(this.id, this.data);
  @override
  List<Object?> get props => [id, data];
  @override
  bool get stringify => true;
}

class DeleteRecurringEvent extends RecurringInfoEvent {
  final int id;

  const DeleteRecurringEvent(this.id);
  @override
  List<Object?> get props => [id];
  @override
  bool get stringify => true;
}
