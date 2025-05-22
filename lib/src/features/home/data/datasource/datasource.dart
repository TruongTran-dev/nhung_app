import 'package:either_dart/either.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/shared/utils/network_info.dart';

abstract class HomeDataSource {
  Future<Either<Failure, Map<String, dynamic>>> getHomeData();
}

class HomeDataSourceImpl implements HomeDataSource {
  final DioProvider dioProvider;
  final NetworkInfo networkInfo;
  HomeDataSourceImpl({required this.dioProvider, required this.networkInfo});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getHomeData() async {
    try {
      final response = await dioProvider.get('');
      if (response.isLeft) return Left(response.left);
      return Right(response.right.data);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
