import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/core/common/use_case_base.dart';
import 'package:expensive_management/src/features/recurring_transaction/domain/repos/recurring_repo.dart';

class UpdateRecurringParams extends Equatable {
  final int id;
  final Map<String, dynamic> data;
  const UpdateRecurringParams({
    required this.id,
    required this.data,
  });
  @override
  List<Object?> get props => [id, data];
  @override
  bool get stringify => true;
}

class UpdateRecurringUseCase extends UseCase<Map<String, dynamic>, UpdateRecurringParams> {
  final RecurringRepo repository;
  UpdateRecurringUseCase({required this.repository});

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(UpdateRecurringParams params) async {
    return await repository.updateRecurringTransaction(
      id: params.id,
      params: params.data,
    );
  }
}
