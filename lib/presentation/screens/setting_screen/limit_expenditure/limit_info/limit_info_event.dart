import 'package:equatable/equatable.dart';

abstract class LimitInfoEvent extends Equatable {
  const LimitInfoEvent();

  @override
  List<Object?> get props => [];
}

class LimitInfoInitEvent extends LimitInfoEvent {}

class AddLimitEvent extends LimitInfoEvent {}

class UpdateLimitEvent extends LimitInfoEvent {}

class DeleteLimitEvent extends LimitInfoEvent {}
