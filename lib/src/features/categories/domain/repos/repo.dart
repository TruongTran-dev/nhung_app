import 'package:either_dart/either.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';

abstract class CategoryRepo {
  Future<Either<Failure, Map<String, dynamic>>> getCategories({required String type});
  Future<Either<Failure, Map<String, dynamic>>> addCategory(Map<String, dynamic> data);
  Future<Either<Failure, Map<String, dynamic>>> updateCategory(String categoryId, Map<String, dynamic> data);
  Future<Either<Failure, bool>> deleteCategory(String categoryId);
}
