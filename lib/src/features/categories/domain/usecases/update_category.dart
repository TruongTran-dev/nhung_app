import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/core/common/use_case_base.dart';
import 'package:expensive_management/src/features/categories/domain/repos/repo.dart';

class UpdateCategoryParams extends Equatable {
  final String categoryId;
  final Map<String, dynamic> data;

  const UpdateCategoryParams({
    required this.categoryId,
    required this.data,
  });

  @override
  List<Object?> get props => [categoryId, data];

  @override
  bool get stringify => true;
}

class UpdateCategoryUseCase extends UseCase<Map<String, dynamic>, UpdateCategoryParams> {
  final CategoryRepo repository;

  UpdateCategoryUseCase({required this.repository});

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(UpdateCategoryParams params) async {
    return await repository.updateCategory(params.categoryId, params.data);
  }
}
