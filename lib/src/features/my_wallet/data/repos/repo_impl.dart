import 'package:either_dart/either.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/features/my_wallet/data/datasource/datasource.dart';
import 'package:expensive_management/src/features/my_wallet/domain/repos/repo.dart';

class WalletRepoImpl implements WalletRepo {
  final WalletDataSource dataSource;

  WalletRepoImpl({
    required this.dataSource,
  });

  @override
  Future<Either<Failure, Map<String, dynamic>>> getListWallets() async {
    return await dataSource.getListWallets();
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> createWallet(Map<String, dynamic> data) async {
    return await dataSource.createWallet(data);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updateWallet(int walletId, Map<String, dynamic> data) async {
    return await dataSource.updateWallet(walletId, data);
  }

  @override
  Future<Either<Failure, bool>> deleteWallet(int walletId) async {
    return await dataSource.deleteWallet(walletId);
  }
}
