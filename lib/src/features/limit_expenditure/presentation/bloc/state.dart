part of 'bloc.dart';

class LimitExpenditureState extends Equatable {
  const LimitExpenditureState();
  @override
  List<Object?> get props => [];
  @override
  bool get stringify => true;
}

class LimitExpenditureInitialState extends LimitExpenditureState {}

class LimitExpenditureLoadingState extends LimitExpenditureState {}

class GetLimitsSuccessState extends LimitExpenditureState {
  final List<LimitModel> limits;
  const GetLimitsSuccessState(this.limits);
  @override
  List<Object?> get props => [limits];
}

class GetLimitsErrorState extends LimitExpenditureState {
  final String message;
  final String? key;
  const GetLimitsErrorState(this.message, {this.key});
  @override
  List<Object?> get props => [message, key];
}

class AddLimitSuccessState extends LimitExpenditureState {}

class AddLimitErrorState extends LimitExpenditureState {
  final String message;
  final String? key;
  const AddLimitErrorState(this.message, {this.key});
  @override
  List<Object?> get props => [message, key];
}

class UpdateLimitSuccessState extends LimitExpenditureState {}

class UpdateLimitErrorState extends LimitExpenditureState {
  final String message;
  final String? key;
  const UpdateLimitErrorState(this.message, {this.key});
  @override
  List<Object?> get props => [message, key];
}

class DeleteLimitSuccessState extends LimitExpenditureState {}

class DeleteLimitErrorState extends LimitExpenditureState {
  final String message;
  final String? key;
  const DeleteLimitErrorState(this.message, {this.key});
  @override
  List<Object?> get props => [message, key];
}
