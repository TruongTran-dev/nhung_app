import 'dart:io';

import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:expensive_management/src/core/common/api_path.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/core/storage/shared_pref_storage.dart';
import 'package:expensive_management/src/core/utils/app_utils.dart';
import 'package:expensive_management/src/shared/utils/network_info.dart';

abstract class ExportDataSource {
  Future<Either<Failure, String>> exportData({required Map<String, dynamic> queryParams, required String savePath});
}

class ExportDataSourceImpl implements ExportDataSource {
  final DioProvider dioProvider;
  final NetworkInfo networkInfo;
  final AppPrefStorage appPrefStorage;

  ExportDataSourceImpl({
    required this.dioProvider,
    required this.networkInfo,
    required this.appPrefStorage,
  });

  @override
  Future<Either<Failure, String>> exportData(
      {required Map<String, dynamic> queryParams, required String savePath}) async {
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
        ApiPath.exportData,
        queryParameters: queryParams,
        options: Options(
          headers: headers,
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );
      if (response.isLeft) return Left(response.left);

      final right = response.right;
      final file = File(savePath);

      await file.writeAsBytes(right.data, flush: true);

      return Right(file.path);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
