import 'package:either_dart/either.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/core/common/use_case_base.dart';
import 'package:expensive_management/src/features/recurring_transaction/domain/repos/recurring_repo.dart';

class DeleteRecurringUseCase extends UseCase<bool, int> {
  final RecurringRepo repository;
  DeleteRecurringUseCase({required this.repository});

  @override
  Future<Either<Failure, bool>> call(int params) async {
    return await repository.deleteRecurringTransaction(id: params);
  }
}
