import 'package:either_dart/either.dart';
import 'package:expensive_management/src/core/common/api_path.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/shared/utils/network_info.dart';
import 'package:flutter/cupertino.dart';

abstract class AuthDataSource {
  Future<Either<Failure, Map<String, dynamic>>> login({required Map<String, dynamic> data});
  Future<Either<Failure, Map<String, dynamic>>> register({required Map<String, dynamic> data});
  Future<Either<Failure, bool>> getOtpForgotPwd({required Map<String, dynamic> data});
  Future<Either<Failure, bool>> verifyOtp({required Map<String, dynamic> data});
  Future<Either<Failure, bool>> updateNewPassword({required Map<String, dynamic> data});
  Future<Either<Failure, bool>> changePassword({required Map<String, dynamic> data});
}

class AuthDataSourceImpl implements AuthDataSource {
  final DioProvider dioProvider;
  final NetworkInfo networkInfo;
  AuthDataSourceImpl({required this.dioProvider, required this.networkInfo});

  @override
  Future<Either<Failure, Map<String, dynamic>>> login({required Map<String, dynamic> data}) async {
    try {
      debugPrint('Login data: $data');
      if (await networkInfo.isNotConnected) {
        return Left(Failure('Không có kết nối mạng. Vui lòng kiểm tra lại.'));
      }
      final response = await dioProvider.post(ApiPath.signIn, data: data);

      if (response.isLeft) return Left(response.left);

      return Right(response.right.data);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> register({required Map<String, dynamic> data}) async {
    try {
      if (await networkInfo.isNotConnected) {
        return Left(Failure('Không có kết nối mạng. Vui lòng kiểm tra lại.'));
      }
      final response = await dioProvider.post(ApiPath.signup, data: data);

      if (response.isLeft) return Left(response.left);

      return Right(response.right.data);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> getOtpForgotPwd({required Map<String, dynamic> data}) async {
    try {
      if (await networkInfo.isNotConnected) {
        return Left(Failure('Không có kết nối mạng. Vui lòng kiểm tra lại.'));
      }
      final response = await dioProvider.post(ApiPath.forgotPassword, data: data);

      if (response.isLeft) return Left(response.left);

      return Right(response.right.data['httpStatus'] == 200);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyOtp({required Map<String, dynamic> data}) async {
    try {
      if (await networkInfo.isNotConnected) {
        return Left(Failure('Không có kết nối mạng. Vui lòng kiểm tra lại.'));
      }
      final response = await dioProvider.post(ApiPath.sendOtp, data: data);

      if (response.isLeft) return Left(response.left);

      return Right(response.right.data['httpStatus'] == 200);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateNewPassword({required Map<String, dynamic> data}) async {
    try {
      if (await networkInfo.isNotConnected) {
        return Left(Failure('Không có kết nối mạng. Vui lòng kiểm tra lại.'));
      }
      final response = await dioProvider.post(ApiPath.newPassword, data: data);

      if (response.isLeft) return Left(response.left);

      return Right(response.right.data['httpStatus'] == 200);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> changePassword({required Map<String, dynamic> data}) async {
    try {
      if (await networkInfo.isNotConnected) {
        return Left(Failure('Không có kết nối mạng. Vui lòng kiểm tra lại.'));
      }
      final response = await dioProvider.post(ApiPath.changePassword, data: data);

      if (response.isLeft) return Left(response.left);

      return Right(response.right.data['httpStatus'] == 200);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
