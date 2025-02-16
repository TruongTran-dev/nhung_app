import 'package:equatable/equatable.dart';

abstract class NewPasswordEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class Validate extends NewPasswordEvent {
  final bool isValidated;

  Validate({this.isValidated = false});
}

class DisplayLoading extends NewPasswordEvent {}

class OnSuccess extends NewPasswordEvent {}

class OnFailure extends NewPasswordEvent {
  final String? errorMessage;

  OnFailure({this.errorMessage});
}
