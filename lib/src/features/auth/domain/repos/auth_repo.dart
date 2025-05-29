import 'package:either_dart/either.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';

abstract class AuthRepo {
  Future<Either<Failure, Map<String, dynamic>>> login({required Map<String, dynamic> data});
  Future<Either<Failure, Map<String, dynamic>>> register({required Map<String, dynamic> data});
  Future<Either<Failure, bool>> getOtpForgotPwd({required Map<String, dynamic> data});
  Future<Either<Failure, bool>> verifyOtp({required Map<String, dynamic> data});
  Future<Either<Failure, bool>> updateNewPassword({required Map<String, dynamic> data});
  Future<Either<Failure, bool>> changePassword({required Map<String, dynamic> data});
}
