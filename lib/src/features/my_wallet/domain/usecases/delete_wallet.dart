import 'package:either_dart/either.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/core/common/use_case_base.dart';
import 'package:expensive_management/src/features/my_wallet/domain/repos/repo.dart';

class DeleteWalletUseCase extends UseCase<bool, int> {
  final WalletRepo repository;

  DeleteWalletUseCase({required this.repository});

  @override
  Future<Either<Failure, bool>> call(int walletId) async {
    return await repository.deleteWallet(walletId);
  }
}
