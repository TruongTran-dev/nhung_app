import 'package:either_dart/either.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/features/recurring_transaction/data/datasources/datasource.dart';
import 'package:expensive_management/src/features/recurring_transaction/domain/repos/recurring_repo.dart';

class RecurringRepoImpl extends RecurringRepo {
  final RecurringDataSource dataSource;
  RecurringRepoImpl({required this.dataSource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> addRecurringTransaction({required Map<String, dynamic> params}) async {
    return await dataSource.addRecurringTransaction(params: params);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updateRecurringTransaction({
    required int id,
    required Map<String, dynamic> params,
  }) async {
    return await dataSource.updateRecurringTransaction(id: id, params: params);
  }

  @override
  Future<Either<Failure, bool>> deleteRecurringTransaction({required int id}) async {
    return await dataSource.deleteRecurringTransaction(id: id);
  }
}
