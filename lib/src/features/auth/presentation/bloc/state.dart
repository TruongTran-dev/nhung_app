part of 'bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class AuthInitial extends AuthState {}

class LoadingState extends AuthState {}

class LoginSuccessState extends AuthState {}

class LoginFailedState extends AuthState {
  final String errorMessage;

  const LoginFailedState({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];

  @override
  bool get stringify => true;
}

class RegisterSuccessState extends AuthState {}

class RegisterFailedState extends AuthState {
  final String errorMessage;

  const RegisterFailedState({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];

  @override
  bool get stringify => true;
}

class GetOTPSuccessState extends AuthState {}

class GetOTPFailedState extends AuthState {
  final String errorMessage;

  const GetOTPFailedState({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];

  @override
  bool get stringify => true;
}

class OTPVerifySuccessState extends AuthState {}

class OTPVerifyFailedState extends AuthState {
  final String errorCode;
  final String errorMessage;

  const OTPVerifyFailedState({required this.errorCode, required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];

  @override
  bool get stringify => true;
}

class UpdateNewPasswordSuccessState extends AuthState {}

class UpdateNewPasswordFailedState extends AuthState {
  final String errorMessage;
  final String key;
  const UpdateNewPasswordFailedState({required this.errorMessage, required this.key});

  @override
  List<Object> get props => [errorMessage, key];

  @override
  bool get stringify => true;
}

class ChangePasswordSuccessState extends AuthState {}

class ChangePasswordFailedState extends AuthState {
  final String errorMessage;
  final String key;

  const ChangePasswordFailedState({required this.errorMessage, required this.key});

  @override
  List<Object> get props => [errorMessage, key];

  @override
  bool get stringify => true;
}
