import 'package:either_dart/either.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/core/common/use_case_base.dart';
import 'package:expensive_management/src/features/my_wallet/domain/repos/repo.dart';

class GetWalletsUseCase extends UseCase<Map<String, dynamic>, NoParam> {
  final WalletRepo repository;

  GetWalletsUseCase({required this.repository});

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(NoParam param) {
    return repository.getListWallets();
  }
}
