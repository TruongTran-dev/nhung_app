
import 'package:either_dart/either.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';

abstract class ExportRepo {
  Future<Either<Failure, String>> exportData({required Map<String, dynamic> params, required String savePath});
}
