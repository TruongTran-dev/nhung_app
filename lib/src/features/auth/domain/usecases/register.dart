import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/core/common/use_case_base.dart';
import 'package:expensive_management/src/features/auth/domain/repos/auth_repo.dart';

class RegisterUseCase extends UseCase<Map<String, dynamic>, RegisterParams> {
  final AuthRepo authRepo;

  RegisterUseCase({required this.authRepo});

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(RegisterParams params) async {
    return await authRepo.register(data: params.toMap());
  }
}

class RegisterParams extends Equatable {
  final String username;
  final String password;
  final String email;


  const RegisterParams({
    required this.username,
    required this.password,
    required this.email,
  });

  @override
  List<Object> get props => [username, password, email];
  @override
  bool get stringify => true;

  RegisterParams copyWith({
    String? username,
    String? password,
    String? email,
  }) {
    return RegisterParams(
      username: username ?? this.username,
      password: password ?? this.password,
      email: email ?? this.email,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
      'email': email,
    };
  }
}