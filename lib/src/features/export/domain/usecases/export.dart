
import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/core/common/use_case_base.dart';
import 'package:expensive_management/src/features/export/domain/repos/repo.dart';

class ExportUseCaseParams extends Equatable {
  final String savePath;
  final Map<String, dynamic> queryParams;
  const ExportUseCaseParams({
    required this.savePath,
    required this.queryParams,
  });
  @override
  List<Object?> get props => [savePath, queryParams];
  @override
  bool get stringify => true;
}

class ExportUseCase extends UseCase<String, ExportUseCaseParams> {
  final ExportRepo repository;

  ExportUseCase({required this.repository});

  @override
  Future<Either<Failure, String>> call(ExportUseCaseParams params) async {
    return await repository.exportData(
      params: params.queryParams,
      savePath: params.savePath,
    );
  }
}
