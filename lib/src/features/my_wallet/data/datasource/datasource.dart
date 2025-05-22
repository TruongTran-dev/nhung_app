import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:expensive_management/data/api/api_path.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/core/storage/shared_pref_storage.dart';
import 'package:expensive_management/src/core/utils/app_utils.dart';
import 'package:expensive_management/src/shared/utils/network_info.dart';

abstract class WalletDataSource {
  Future<Either<Failure, Map<String, dynamic>>> getListWallets();
  Future<Either<Failure, Map<String, dynamic>>> createWallet(Map<String, dynamic> data);
  Future<Either<Failure, Map<String, dynamic>>> updateWallet(int walletId, Map<String, dynamic> data);
  Future<Either<Failure, bool>> deleteWallet(int walletId);
}

class WalletDataSourceImpl implements WalletDataSource {
  final DioProvider dioProvider;
  final NetworkInfo networkInfo;
  final AppPrefStorage appPrefStorage;
  WalletDataSourceImpl({
    required this.dioProvider,
    required this.networkInfo,
    required this.appPrefStorage,
  });

  @override
  Future<Either<Failure, Map<String, dynamic>>> getListWallets() async {
    if (await networkInfo.isNotConnected) {
      return Left(Failure('No internet connection'));
    }

    if (!await AppUtils.isValidToken()) {
      return Left(ServerError(key: "token_expired", message: "Token expired"));
    }

    try {
      final token = appPrefStorage.getAccessToken();

      final headers = {
        "Authorization": token,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final response = await dioProvider.get(
        ApiPath.wallet,
        options: Options(headers: headers),
      );
      if (response.isLeft) return Left(response.left);
      return Right(response.right.data);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> createWallet(Map<String, dynamic> data) async {
    try {
      if (await networkInfo.isNotConnected) {
        return Left(Failure('No internet connection'));
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
        ApiPath.wallet,
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
  Future<Either<Failure, Map<String, dynamic>>> updateWallet(int walletId, Map<String, dynamic> data) async {
    if (await networkInfo.isNotConnected) {
      return Left(Failure('No internet connection'));
    }

    if (!await AppUtils.isValidToken()) {
      return Left(ServerError(key: "token_expired", message: "Token expired"));
    }

    try {
      final token = appPrefStorage.getAccessToken();

      final headers = {
        "Authorization": token,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
      final response = await dioProvider.put(
        '${ApiPath.wallet}/$walletId',
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
  Future<Either<Failure, bool>> deleteWallet(int walletId) async {
    if (await networkInfo.isNotConnected) {
      return Left(Failure('No internet connection'));
    }

    if (!await AppUtils.isValidToken()) {
      return Left(ServerError(key: "token_expired", message: "Token expired"));
    }

    try {
      final token = appPrefStorage.getAccessToken();

      final headers = {
        "Authorization": token,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final response = await dioProvider.delete(
        '${ApiPath.wallet}/$walletId',
        options: Options(headers: headers),
      );
      if (response.isLeft) return Left(response.left);
      return Right(response.right.statusCode == 200);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
