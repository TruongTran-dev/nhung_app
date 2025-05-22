import 'package:either_dart/either.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';

abstract class WalletRepo {
  Future<Either<Failure, Map<String, dynamic>>> getListWallets();
  Future<Either<Failure, Map<String, dynamic>>> createWallet(Map<String, dynamic> data);
  Future<Either<Failure, Map<String, dynamic>>> updateWallet(int walletId, Map<String, dynamic> data);
  Future<Either<Failure, bool>> deleteWallet(int walletId);
}
