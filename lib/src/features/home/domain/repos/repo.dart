import 'package:either_dart/either.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';

abstract class HomeRepo {
  Future<Either<Failure, Map<String, dynamic>>> getHomeData();
}