import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/core/common/use_case_base.dart';
import 'package:expensive_management/src/features/limit_expenditure/domain/repos/repo.dart';

class UpdateLimitParams extends Equatable {
  final int limitId;
  final Map<String, dynamic> data;

  const UpdateLimitParams({
    required this.limitId,
    required this.data,
  });

  @override
  List<Object?> get props => [limitId, data];

  @override
  bool get stringify => true;
}

class UpdateLimitUseCase extends UseCase<Map<String, dynamic>, UpdateLimitParams> {
  final LimitRepo repository;

  UpdateLimitUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(UpdateLimitParams params) async {
    return await repository.updateLimit(params.limitId, params.data);
  }
}
