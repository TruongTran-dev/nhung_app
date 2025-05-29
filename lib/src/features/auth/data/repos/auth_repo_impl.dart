import 'package:either_dart/either.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/features/auth/data/datasource/auth_datasoure.dart';
import 'package:expensive_management/src/features/auth/domain/repos/auth_repo.dart';

class AuthRepoImpl implements AuthRepo {
  final AuthDataSource dataSource;
  AuthRepoImpl({required this.dataSource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> login({required Map<String, dynamic> data}) async {
    return await dataSource.login(data: data);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> register({required Map<String, dynamic> data}) async {
    return await dataSource.register(data: data);
  }

  @override
  Future<Either<Failure, bool>> getOtpForgotPwd({required Map<String, dynamic> data}) async {
    return await dataSource.getOtpForgotPwd(data: data);
  }

  @override
  Future<Either<Failure, bool>> verifyOtp({required Map<String, dynamic> data}) async {
    return await dataSource.verifyOtp(data: data);
  }

  @override
  Future<Either<Failure, bool>> updateNewPassword({required Map<String, dynamic> data}) async {
    return await dataSource.updateNewPassword(data: data);
  }

  @override
  Future<Either<Failure,bool>> changePassword({required Map<String, dynamic> data}) async {
    return await dataSource.changePassword(data: data);
  }
  
}
