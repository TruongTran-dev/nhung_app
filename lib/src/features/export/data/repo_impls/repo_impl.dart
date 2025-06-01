import 'package:either_dart/either.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/features/export/data/datasource/datasource.dart';
import 'package:expensive_management/src/features/export/domain/repos/repo.dart';

class ExportRepoImpl implements ExportRepo {
  final ExportDataSource dataSource;
  ExportRepoImpl({
    required this.dataSource,
  });

  @override
  Future<Either<Failure, String>> exportData({required Map<String, dynamic> params, required String savePath}) async {
    return await dataSource.exportData(queryParams: params, savePath: savePath);
  }
}
