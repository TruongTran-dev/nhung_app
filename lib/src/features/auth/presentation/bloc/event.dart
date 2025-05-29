part of 'bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object> get props => [];
  @override
  bool get stringify => true;
}

class ReValidateFormEvent extends AuthEvent {}

class SubmitLoginEvent extends AuthEvent {
  final String username;
  final String password;
  final String? deviceToken;

  const SubmitLoginEvent({
    required this.username,
    required this.password,
    this.deviceToken,
  });

  @override
  List<Object> get props => [username, password , deviceToken ?? ''];

  @override
  bool get stringify => true;

  SubmitLoginEvent copyWith({
    String? username,
    String? password,
  }) {
    return SubmitLoginEvent(
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }
}

class RegisterEvent extends AuthEvent {
  final String username;
  final String password;
  final String email;

  const RegisterEvent({
    required this.username,
    required this.password,
    required this.email,
  });

  @override
  List<Object> get props => [username, password, email];

  @override
  bool get stringify => true;

  RegisterEvent copyWith({
    String? username,
    String? password,
    String? email,
  }) {
    return RegisterEvent(
      username: username ?? this.username,
      password: password ?? this.password,
      email: email ?? this.email,
    );
  }
}

class GetOTPForgotPasswordEvent extends AuthEvent {
  final String email;

  const GetOTPForgotPasswordEvent({required this.email});

  @override
  List<Object> get props => [email];

  @override
  bool get stringify => true;

  GetOTPForgotPasswordEvent copyWith({
    String? email,
  }) {
    return GetOTPForgotPasswordEvent(
      email: email ?? this.email,
    );
  }
}

class SubmitVerifyOtpEvent extends AuthEvent {
  final String email;
  final String otp;

  const SubmitVerifyOtpEvent({required this.email, required this.otp});

  @override
  List<Object> get props => [email, otp];

  @override
  bool get stringify => true;

  SubmitVerifyOtpEvent copyWith({
    String? email,
    String? otp,
  }) {
    return SubmitVerifyOtpEvent(
      email: email ?? this.email,
      otp: otp ?? this.otp,
    );
  }
}

class SubmitNewPasswordEvent extends AuthEvent {
  final String email;
  final String password;

  const SubmitNewPasswordEvent({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];

  @override
  bool get stringify => true;

  SubmitNewPasswordEvent copyWith({
    String? email,
    String? password,
  }) {
    return SubmitNewPasswordEvent(
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}

class ChangePasswordEvent extends AuthEvent {
  final String oldPassword;
  final String newPassword;

  const ChangePasswordEvent({
    required this.oldPassword,
    required this.newPassword,
  });

  @override
  List<Object> get props => [oldPassword, newPassword];

  @override
  bool get stringify => true;

  ChangePasswordEvent copyWith({
    String? oldPassword,
    String? newPassword,
  }) {
    return ChangePasswordEvent(
      oldPassword: oldPassword ?? this.oldPassword,
      newPassword: newPassword ?? this.newPassword,
    );
  }
}
