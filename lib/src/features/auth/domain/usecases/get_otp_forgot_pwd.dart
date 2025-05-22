import 'package:either_dart/either.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/core/common/use_case_base.dart';
import 'package:expensive_management/src/features/auth/domain/repos/auth_repo.dart';

class GetOtpForgotPwdUseCase extends UseCase<bool, String> {
  final AuthRepo authRepo;
  GetOtpForgotPwdUseCase({required this.authRepo});
  @override
  Future<Either<Failure, bool>> call(String email) async {
    return await authRepo.getOtpForgotPwd(data: {'email': email});
  }
}
