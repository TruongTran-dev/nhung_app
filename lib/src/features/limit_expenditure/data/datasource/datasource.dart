import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:expensive_management/src/core/common/api_path.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/core/storage/shared_pref_storage.dart';
import 'package:expensive_management/src/core/utils/app_utils.dart';
import 'package:expensive_management/src/shared/utils/network_info.dart';

abstract class LimitDataSource {
  Future<Either<Failure, Map<String, dynamic>>> getLimits(Map<String, dynamic> data);
  Future<Either<Failure, Map<String, dynamic>>> addLimit(Map<String, dynamic> data);
  Future<Either<Failure, Map<String, dynamic>>> updateLimit(int id, Map<String, dynamic> data);
  Future<Either<Failure, bool>> deleteLimit(int id);
}

class LimitDataSourceImpl implements LimitDataSource {
  final DioProvider dioProvider;
  final NetworkInfo networkInfo;
  final AppPrefStorage appPrefStorage;

  LimitDataSourceImpl({
    required this.dioProvider,
    required this.networkInfo,
    required this.appPrefStorage,
  });
  @override
  Future<Either<Failure, Map<String, dynamic>>> getLimits(Map<String, dynamic> data) async {
    try {
      if (await networkInfo.isNotConnected) {
        return Left(Failure('No internet connection'));
      }
      if (!await AppUtils.isValidToken()) {
        return Left(ServerError(key: 'token_expired', message: 'Token expired'));
      }
      final token = appPrefStorage.getAccessToken();
      final headers = {
        'Authorization': token,
        'Content-Type': 'application/json',
      };

      final response = await dioProvider.get(
        ApiPath.expenseLimit,
        // data: data,
        queryParameters: data,
        options: Options(headers: headers),
      );
      if (response.isLeft) return Left(response.left);
      return Right(response.right.data);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addLimit(Map<String, dynamic> data) async {
    try {
      if (await networkInfo.isNotConnected) {
        return Left(Failure('No internet connection'));
      }
      if (!await AppUtils.isValidToken()) {
        return Left(ServerError(key: 'token_expired', message: 'Token expired'));
      }
      final token = appPrefStorage.getAccessToken();
      final headers = {
        'Authorization': token,
        'Content-Type': 'application/json',
      };

      final response = await dioProvider.post(
        ApiPath.expenseLimit,
        data: data,
        options: Options(headers: headers),
      );
      if (response.isLeft) return Left(response.left);
      return Right(response.right.data);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updateLimit(int id, Map<String, dynamic> data) async {
    try {
      if (await networkInfo.isNotConnected) {
        return Left(Failure('No internet connection'));
      }
      if (!await AppUtils.isValidToken()) {
        return Left(ServerError(key: 'token_expired', message: 'Token expired'));
      }
      final token = appPrefStorage.getAccessToken();
      final headers = {
        'Authorization': token,
        'Content-Type': 'application/json',
      };
      final response = await dioProvider.put(
        '${ApiPath.expenseLimit}/$id',
        data: data,
        options: Options(headers: headers),
      );
      if (response.isLeft) return Left(response.left);
      return Right(response.right.data);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteLimit(int id) async {
    try {
      if (await networkInfo.isNotConnected) {
        return Left(Failure('No internet connection'));
      }
      if (!await AppUtils.isValidToken()) {
        return Left(ServerError(key: 'token_expired', message: 'Token expired'));
      }
      final token = appPrefStorage.getAccessToken();
      final headers = {
        'Authorization': token,
        'Content-Type': 'application/json',
      };
      final response = await dioProvider.delete(
        '${ApiPath.expenseLimit}/$id',
        options: Options(headers: headers),
      );
      if (response.isLeft) return Left(response.left);
      return Right(response.right.statusCode == 200);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
