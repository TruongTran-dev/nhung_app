import 'package:either_dart/either.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';

abstract class CollectionRepo {
  Future<Either<Failure, Map<String, dynamic>>> addNewCollection(Map<String, dynamic> data);
  Future<Either<Failure, Map<String, dynamic>>> updateCollection(int id, Map<String, dynamic> data);
  Future<Either<Failure, bool>> deleteCollection(int id);
  Future<Either<Failure, Map<String, dynamic>>> getCollectionById(int id);
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllCollections();
}
