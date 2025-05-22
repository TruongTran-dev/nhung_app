import 'package:either_dart/either.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/features/limit_expenditure/data/datasource/datasource.dart';
import 'package:expensive_management/src/features/limit_expenditure/domain/repos/repo.dart';

class LimitRepoImpl implements LimitRepo {
  final LimitDataSource dataSource;

  LimitRepoImpl({required this.dataSource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getLimits(Map<String, dynamic> data) async {
    return await dataSource.getLimits(data);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addLimit(Map<String, dynamic> data) async {
    return await dataSource.addLimit(data);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updateLimit(int id, Map<String, dynamic> data) async {
    return await dataSource.updateLimit(id, data);
  }

  @override
  Future<Either<Failure, bool>> deleteLimit(int id) async {
    return await dataSource.deleteLimit(id);
  }
}
