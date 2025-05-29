import 'package:either_dart/either.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';

abstract class RecurringRepo {
  Future<Either<Failure, Map<String, dynamic>>> addRecurringTransaction({required Map<String, dynamic> params});
  Future<Either<Failure, Map<String, dynamic>>> updateRecurringTransaction({
    required int id,
    required Map<String, dynamic> params,
  });
  Future<Either<Failure, bool>> deleteRecurringTransaction({required int id});
}
