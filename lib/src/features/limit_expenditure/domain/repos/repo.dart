import 'package:either_dart/either.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';

abstract class LimitRepo {

  Future<Either<Failure, Map<String, dynamic>>> getLimits(Map<String, dynamic> data);
  Future<Either<Failure, Map<String, dynamic>>> addLimit(Map<String, dynamic> data);
  Future<Either<Failure, Map<String, dynamic>>> updateLimit(int id, Map<String, dynamic> data);
  Future<Either<Failure, bool>> deleteLimit(int id);
}
