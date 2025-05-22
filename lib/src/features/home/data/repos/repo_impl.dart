import 'package:either_dart/either.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/features/home/data/datasource/datasource.dart';
import 'package:expensive_management/src/features/home/domain/repos/repo.dart';

class HomeRepoImpl implements HomeRepo {
  final HomeDataSource dataSource;
  HomeRepoImpl({required this.dataSource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getHomeData() async {
    return await dataSource.getHomeData();
  }
}
