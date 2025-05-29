import 'package:either_dart/either.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/core/common/use_case_base.dart';
import 'package:expensive_management/src/features/recurring_transaction/domain/repos/recurring_repo.dart';

class AddRecurringUseCase extends UseCase<Map<String, dynamic>, Map<String, dynamic>> {
  final RecurringRepo repository;
  AddRecurringUseCase({required this.repository});

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(Map<String, dynamic> params) async {
    return await repository.addRecurringTransaction(params: params);
  }
}
