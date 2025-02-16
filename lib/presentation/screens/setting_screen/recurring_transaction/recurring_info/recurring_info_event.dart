import 'package:equatable/equatable.dart';

abstract class RecurringInfoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class RecurringInfoInit extends RecurringInfoEvent {}

class AddRecurringEvent extends RecurringInfoEvent {
  final Map<String, dynamic> data;

  AddRecurringEvent(this.data);
  @override
  List<Object?> get props => [data];
}
