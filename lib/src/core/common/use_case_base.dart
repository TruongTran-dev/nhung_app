import 'package:either_dart/either.dart';
import 'package:equatable/equatable.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';

/// Created by: 7-Productions
/// - Author: hieubh
/// - Contact: hieuitdevs@gmail.com
/// - Description: Base class for use cases in the application.
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params param);
}

abstract class BaseParam extends Equatable {
  @override
  List<Object?> get props => [];
}

class NoParam extends BaseParam {
  @override
  List<Object?> get props => [];
}
