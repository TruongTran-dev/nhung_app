import 'package:either_dart/either.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/core/common/use_case_base.dart';
import 'package:expensive_management/src/features/collection/domain/repos/repo.dart';

class DeleteCollectionUseCase extends UseCase<bool, int> {
  final CollectionRepo repository;

  DeleteCollectionUseCase(this.repository);

  @override
  Future<Either<Failure, bool>> call(int params) async {
    return await repository.deleteCollection(params);
  }
}