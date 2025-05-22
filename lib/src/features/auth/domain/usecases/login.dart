import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/core/common/extensions.dart';
import 'package:expensive_management/src/core/common/use_case_base.dart';
import 'package:expensive_management/src/features/auth/domain/repos/auth_repo.dart';

class LoginUseCase extends UseCase<Map<String, dynamic>, LoginParams> {
  final AuthRepo authRepo;

  LoginUseCase({required this.authRepo});

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(LoginParams param) async {
    return await authRepo.login(data: param.data);
  }
}

class LoginParams extends Equatable {
  final String username;
  final String password;
  final String? fcmToken;

  const LoginParams({
    required this.username,
    required this.password,
    this.fcmToken,
  });
  @override
  List<Object?> get props => [username, password, fcmToken];

  @override
  bool get stringify => true;

  LoginParams copyWith({
    String? username,
    String? password,
    String? fcmToken,
  }) {
    return LoginParams(
      username: username ?? this.username,
      password: password ?? this.password,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  Map<String, dynamic> get data => {
        'username': username,
        'password': password,
        if (!fcmToken.isNullOrEmpty) 'fcm_token': fcmToken,
      };
}
