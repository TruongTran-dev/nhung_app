import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/core/common/use_case_base.dart';
import 'package:expensive_management/src/features/my_wallet/domain/repos/repo.dart';

class UpdateWalletUseCaseParams extends Equatable {
  final int walletId;
  final Map<String, dynamic> data;

  const UpdateWalletUseCaseParams({required this.walletId, required this.data});

  @override
  List<Object?> get props => [walletId, data];

  @override
  bool get stringify => true;
}

class UpdateWalletUseCase extends UseCase<Map<String, dynamic>, UpdateWalletUseCaseParams> {
  final WalletRepo repository;

  UpdateWalletUseCase({required this.repository});

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(UpdateWalletUseCaseParams params) async {
    return await repository.updateWallet(params.walletId, params.data);
  }
}
