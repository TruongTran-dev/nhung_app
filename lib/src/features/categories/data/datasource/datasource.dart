import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:expensive_management/data/api/api_path.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/core/storage/shared_pref_storage.dart';
import 'package:expensive_management/src/core/utils/app_utils.dart';
import 'package:expensive_management/src/shared/utils/network_info.dart';

abstract class CategoryDataSource {
  Future<Either<Failure, Map<String, dynamic>>> getCategories({required String type});
  Future<Either<Failure, Map<String, dynamic>>> addCategory(Map<String, dynamic> data);
  Future<Either<Failure, Map<String, dynamic>>> updateCategory(String categoryId, Map<String, dynamic> data);
  Future<Either<Failure, bool>> deleteCategory(String categoryId);
}

class CategoryDataSourceImpl implements CategoryDataSource {
  final DioProvider dioProvider;
  final NetworkInfo networkInfo;
  final AppPrefStorage appPrefStorage;
  CategoryDataSourceImpl({
    required this.dioProvider,
    required this.networkInfo,
    required this.appPrefStorage,
  });

  @override
  Future<Either<Failure, Map<String, dynamic>>> getCategories({required String type}) async {
    try {
      if (await networkInfo.isNotConnected) {
        return Left(Failure('Không có kết nối mạng. Vui lòng kiểm tra lại.'));
      }
      if (!await AppUtils.isValidToken()) {
        return Left(ServerError(key: "token_expired", message: "Token expired"));
      }
      final token = appPrefStorage.getAccessToken();
      final headers = {
        "Authorization": token,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final String url = "${ApiPath.apiDomain}${ApiPath.getAllListCategory}";
      final response = await dioProvider.get(
        url,
        queryParameters: {'type': type},
        options: Options(headers: headers),
      );
      if (response.isLeft) return Left(response.left);
      return Right(response.right.data);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addCategory(Map<String, dynamic> data) async {
    try {
      if (await networkInfo.isNotConnected) {
        return Left(Failure('Không có kết nối mạng. Vui lòng kiểm tra lại.'));
      }
      if (!await AppUtils.isValidToken()) {
        return Left(ServerError(key: "token_expired", message: "Token expired"));
      }
      final token = appPrefStorage.getAccessToken();
      final headers = {
        "Authorization": token,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final response = await dioProvider.post(
        ApiPath.apiCategory,
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
  Future<Either<Failure, Map<String, dynamic>>> updateCategory(String categoryId, Map<String, dynamic> data) async {
    try {
      if (await networkInfo.isNotConnected) {
        return Left(Failure('Không có kết nối mạng. Vui lòng kiểm tra lại.'));
      }
      if (!await AppUtils.isValidToken()) {
        return Left(ServerError(key: "token_expired", message: "Token expired"));
      }
      final token = appPrefStorage.getAccessToken();
      final headers = {
        "Authorization": token,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final response = await dioProvider.put(
        '${ApiPath.apiCategory}/$categoryId',
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
  Future<Either<Failure, bool>> deleteCategory(String categoryId) async {
    try {
      if (await networkInfo.isNotConnected) {
        return Left(Failure('Không có kết nối mạng. Vui lòng kiểm tra lại.'));
      }
      if (!await AppUtils.isValidToken()) {
        return Left(ServerError(key: "token_expired", message: "Token expired"));
      }
      final token = appPrefStorage.getAccessToken();
      final headers = {
        "Authorization": token,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final response = await dioProvider.delete(
        '${ApiPath.apiCategory}/$categoryId',
        options: Options(headers: headers),
      );
      if (response.isLeft) return Left(response.left);
      return Right(response.right.statusCode == 200);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
