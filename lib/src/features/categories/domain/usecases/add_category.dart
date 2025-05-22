import 'package:either_dart/either.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/core/common/use_case_base.dart';
import 'package:expensive_management/src/features/categories/domain/repos/repo.dart';

class AddCategoryUseCase extends UseCase<Map<String, dynamic>, Map<String, dynamic>> {
  final CategoryRepo repository;

  AddCategoryUseCase({required this.repository});

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(Map<String, dynamic> params) async {
    return await repository.addCategory(params);
  }
}
