import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/core/common/use_case_base.dart';
import 'package:expensive_management/src/features/auth/domain/repos/auth_repo.dart';

class ChangePwdUseCase extends UseCase<bool, ChangePwdParams> {
  final AuthRepo repository;

  ChangePwdUseCase({required this.repository});

  @override
  Future<Either<Failure, bool>> call(ChangePwdParams params) async {
    return await repository.changePassword(data: params.toJson());
  }
}

class ChangePwdParams extends Equatable {
  final String oldPassword;
  final String newPassword;

  const ChangePwdParams({
    required this.oldPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [oldPassword, newPassword];

  @override
  bool get stringify => true;

  Map<String, dynamic> toJson() {
    return {
      "confirm_password": newPassword,
      "current_password": oldPassword,
      "password": newPassword,
    };
  }
}
