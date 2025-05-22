import 'package:either_dart/either.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/features/categories/data/datasource/datasource.dart';
import 'package:expensive_management/src/features/categories/domain/repos/repo.dart';

class CategoryRepoImpl implements CategoryRepo {
  final CategoryDataSource dataSource;
  CategoryRepoImpl({required this.dataSource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getCategories({required String type}) async {
    return await dataSource.getCategories(type: type);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addCategory(Map<String, dynamic> data) async {
    return await dataSource.addCategory(data);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updateCategory(String categoryId, Map<String, dynamic> data) async {
    return await dataSource.updateCategory(categoryId, data);
  }

  @override
  Future<Either<Failure, bool>> deleteCategory(String categoryId) async {
    return await dataSource.deleteCategory(categoryId);
  }
}
