import 'package:either_dart/either.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/core/common/use_case_base.dart';
import 'package:expensive_management/src/features/categories/domain/repos/repo.dart';

class GetCategoriesUseCase extends UseCase<Map<String, dynamic>, String> {
  final CategoryRepo repository;

  GetCategoriesUseCase({required this.repository});

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String type) async {
    return await repository.getCategories(type: type);
  }
}