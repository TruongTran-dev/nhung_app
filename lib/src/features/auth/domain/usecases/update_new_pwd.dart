import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/core/common/use_case_base.dart';
import 'package:expensive_management/src/features/auth/domain/repos/auth_repo.dart';

class UpdateNewPwdUseCase extends UseCase<bool, UpdateNewPwdParams> {
  final AuthRepo repository;

  UpdateNewPwdUseCase({required this.repository});

  @override
  Future<Either<Failure, bool>> call(UpdateNewPwdParams params) async {
    return await repository.updateNewPassword(data: params.toMap());
  }
}

class UpdateNewPwdParams extends Equatable {
  final String email;
  final String password;

  const UpdateNewPwdParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];

  @override
  bool get stringify => true;

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'password': password,
      'confirm_password': password,
    };
  }
}
