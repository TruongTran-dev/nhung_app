import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:expensive_management/data/api/api_path.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/core/storage/shared_pref_storage.dart';
import 'package:expensive_management/src/core/utils/app_utils.dart';
import 'package:expensive_management/src/shared/utils/network_info.dart';

abstract class RecurringDataSource {
  Future<Either<Failure, Map<String, dynamic>>> addRecurringTransaction({required Map<String, dynamic> params});

  Future<Either<Failure, Map<String, dynamic>>> updateRecurringTransaction({
    required int id,
    required Map<String, dynamic> params,
  });
  Future<Either<Failure, bool>> deleteRecurringTransaction({required int id});
}

class RecurringDataSourceImpl implements RecurringDataSource {
  final DioProvider dioProvider;
  final NetworkInfo networkInfo;
  final AppPrefStorage appPrefStorage;

  RecurringDataSourceImpl({required this.dioProvider, required this.networkInfo, required this.appPrefStorage});

  @override
  Future<Either<Failure, Map<String, dynamic>>> addRecurringTransaction({required Map<String, dynamic> params}) async {
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
        ApiPath.recurring,
        data: params,
        options: Options(headers: headers),
      );
      if (response.isLeft) return Left(response.left);
      return Right(response.right.data);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updateRecurringTransaction({
    required int id,
    required Map<String, dynamic> params,
  }) async {
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
        '${ApiPath.recurring}/$id',
        data: params,
        options: Options(headers: headers),
      );
      if (response.isLeft) return Left(response.left);
      return Right(response.right.data);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteRecurringTransaction({required int id}) async {
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
        '${ApiPath.recurring}/$id',
        options: Options(headers: headers),
      );
      if (response.isLeft) return Left(response.left);
      return Right(response.right.statusCode == 200);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
