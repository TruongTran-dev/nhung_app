import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/core/common/use_case_base.dart';
import 'package:expensive_management/src/features/collection/domain/repos/repo.dart';

class UpdateCollectionParams extends Equatable {
  final int collectionId;
  final Map<String, dynamic> data;

  const UpdateCollectionParams({
    required this.collectionId,
    required this.data,
  });

  @override
  List<Object?> get props => [collectionId, data];

  @override
  bool get stringify => true;
}

class UpdateCollectionUseCase extends UseCase<Map<String, dynamic>, UpdateCollectionParams> {
  final CollectionRepo repository;

  UpdateCollectionUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(UpdateCollectionParams params) async {
    return await repository.updateCollection(params.collectionId, params.data);
  }
}
