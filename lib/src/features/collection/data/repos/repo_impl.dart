import 'package:either_dart/either.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/features/collection/data/datasource/datasource.dart';
import 'package:expensive_management/src/features/collection/domain/repos/repo.dart';

class CollectionRepoImpl implements CollectionRepo {
  final CollectionDataSource dataSource;

  CollectionRepoImpl({required this.dataSource});

  @override
  Future<Either<Failure, Map<String, dynamic>>> addNewCollection(Map<String, dynamic> data) async {
    return await dataSource.addNewCollection(data);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> updateCollection(int id, Map<String, dynamic> data) async {
    return await dataSource.updateCollection(id, data);
  }

  @override
  Future<Either<Failure, bool>> deleteCollection(int id) async {
    return await dataSource.deleteCollection(id);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getCollectionById(int id) async {
    return await dataSource.getCollectionById(id);
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllCollections() async {
    return await dataSource.getAllCollections();
  }
}
