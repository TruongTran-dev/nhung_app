import 'package:either_dart/either.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/core/common/use_case_base.dart';
import 'package:expensive_management/src/features/limit_expenditure/domain/repos/repo.dart';

class DeleteLimitUseCase extends UseCase<bool, int> {
  final LimitRepo repository;

  DeleteLimitUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(int params) async {
    return await repository.deleteLimit(params);
  }
}