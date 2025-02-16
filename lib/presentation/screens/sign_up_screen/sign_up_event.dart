import 'package:equatable/equatable.dart';

abstract class SignUpEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ValidateForm extends SignUpEvent {
}

class SignUpSubmitted extends SignUpEvent {
  final String username;
  final String email;
  final String password;

  SignUpSubmitted({required this.username, required this.email, required this.password});

  @override
  List<Object> get props => [username, email, password];
}

