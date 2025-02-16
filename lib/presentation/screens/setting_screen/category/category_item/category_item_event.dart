import 'package:equatable/equatable.dart';

abstract class CategoryItemEvent extends Equatable {
  const CategoryItemEvent();

  @override
  List<Object?> get props => [];
}

class CategoryInit extends CategoryItemEvent {}
