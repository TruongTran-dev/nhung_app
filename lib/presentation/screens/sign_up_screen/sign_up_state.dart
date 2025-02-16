import 'package:equatable/equatable.dart';

abstract class SignUpState extends Equatable {
  const SignUpState();

  @override
  List<Object> get props => [];
}

class InitialSignUp extends SignUpState {}

class LoadingState extends SignUpState {}

class SignUpSuccess extends SignUpState {}

class SignUpFailed extends SignUpState {
  final String errorMessage;

  const SignUpFailed({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}
