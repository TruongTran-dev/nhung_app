part of 'bloc.dart';

class LimitExpenditureEvent extends Equatable {
  const LimitExpenditureEvent();
  @override
  List<Object?> get props => [];
  @override
  bool get stringify => true;
}

class GetLimitsEvent extends LimitExpenditureEvent {
  final Map<String, dynamic> data;
  const GetLimitsEvent(this.data);
  @override
  List<Object?> get props => [data];

  @override
  bool get stringify => true;
}

class AddLimitEvent extends LimitExpenditureEvent {
  final Map<String, dynamic> data;
  const AddLimitEvent(this.data);
  @override
  List<Object?> get props => [data];
  @override
  bool get stringify => true;
}

class UpdateLimitEvent extends LimitExpenditureEvent {
  final int id;
  final Map<String, dynamic> data;
  const UpdateLimitEvent(this.id, this.data);
  @override
  List<Object?> get props => [id, data];
  @override
  bool get stringify => true;
}

class DeleteLimitEvent extends LimitExpenditureEvent {
  final int id;
  const DeleteLimitEvent(this.id);
  @override
  List<Object?> get props => [id];
  @override
  bool get stringify => true;
}
