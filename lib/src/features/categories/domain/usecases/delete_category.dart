import 'package:either_dart/either.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/core/common/use_case_base.dart';
import 'package:expensive_management/src/features/categories/domain/repos/repo.dart';

class DeleteCategoryUseCase extends UseCase<bool, String> {
  final CategoryRepo repository;

  DeleteCategoryUseCase({required this.repository});

  @override
  Future<Either<Failure, bool>> call(String params) async {
    return await repository.deleteCategory(params);
  }
}
