part of 'recurring_info_bloc.dart';

abstract class RecurringInfoState extends Equatable {
  const RecurringInfoState();

  @override
  List<Object?> get props => [];

  @override
  bool get stringify => true;
}

class RecurringInfoInitial extends RecurringInfoState {}

class RecurringInfoLoading extends RecurringInfoState {}

class AddRecurringSuccessState extends RecurringInfoState {}

class AddRecurringFailureState extends RecurringInfoState {
  final String message;
  final String? key;

  const AddRecurringFailureState({
    required this.message,
    this.key,
  });

  @override
  List<Object?> get props => [message, key];

  @override
  bool get stringify => true;
}

class UpdateRecurringSuccessState extends RecurringInfoState {}

class UpdateRecurringFailureState extends RecurringInfoState {
  final String message;
  final String? key;

  const UpdateRecurringFailureState({
    required this.message,
    this.key,
  });

  @override
  List<Object?> get props => [message, key];

  @override
  bool get stringify => true;
}

class DeleteRecurringSuccessState extends RecurringInfoState {}

class DeleteRecurringFailureState extends RecurringInfoState {
  final String message;
  final String? key;

  const DeleteRecurringFailureState({
    required this.message,
    this.key,
  });

  @override
  List<Object?> get props => [message, key];

  @override
  bool get stringify => true;
}
