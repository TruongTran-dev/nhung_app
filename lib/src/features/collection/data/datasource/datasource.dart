import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:expensive_management/data/api/api_path.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/core/storage/shared_pref_storage.dart';
import 'package:expensive_management/src/core/utils/app_utils.dart';
import 'package:expensive_management/src/shared/utils/network_info.dart';

abstract class CollectionDataSource {
  Future<Either<Failure, Map<String, dynamic>>> addNewCollection(Map<String, dynamic> data);
  Future<Either<Failure, Map<String, dynamic>>> updateCollection(int id, Map<String, dynamic> data);
  Future<Either<Failure, bool>> deleteCollection(int id);
  Future<Either<Failure, Map<String, dynamic>>> getCollectionById(int id);
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllCollections();
}

class CollectionDataSourceImpl implements CollectionDataSource {
  final DioProvider dioProvider;
  final NetworkInfo networkInfo;
  final AppPrefStorage appPrefStorage;

  CollectionDataSourceImpl({
    required this.dioProvider,
    required this.networkInfo,
    required this.appPrefStorage,
  });
  @override
  Future<Either<Failure, Map<String, dynamic>>> addNewCollection(Map<String, dynamic> data) async {
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
        ApiPath.transaction,
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
  Future<Either<Failure, Map<String, dynamic>>> updateCollection(int id, Map<String, dynamic> data) async {
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
        '${ApiPath.transaction}/$id',
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
  Future<Either<Failure, bool>> deleteCollection(int id) async {
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
      final response = await dioProvider.delete('${ApiPath.transaction}/$id', options: Options(headers: headers));
      if (response.isLeft) return Left(response.left);
      return Right(response.right.statusCode == 200);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getCollectionById(int id) async {
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

      final response = await dioProvider.get('/collections/$id', options: Options(headers: headers));
      if (response.isLeft) return Left(response.left);
      return Right(response.right.data);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllCollections() async {
    try {
      if (!await networkInfo.isNotConnected) {
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

      final response = await dioProvider.get('/collections', options: Options(headers: headers));
      if (response.isLeft) return Left(response.left);
      return Right(response.right.data);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
