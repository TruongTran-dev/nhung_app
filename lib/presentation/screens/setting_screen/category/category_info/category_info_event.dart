import 'package:equatable/equatable.dart';

abstract class CategoryInfoEvent extends Equatable {
  const CategoryInfoEvent();

  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryInfoEvent {}

class AddCategoryEvent extends CategoryInfoEvent {
  final Map<String, dynamic> data;

  const AddCategoryEvent({required this.data});
}

class UpdateCategoryEvent extends CategoryInfoEvent {
  final int categoryId;
  final Map<String, dynamic> data;

  const UpdateCategoryEvent({
    required this.categoryId,
    required this.data,
  });
}

class DeleteCategoryEvent extends CategoryInfoEvent {
  final int categoryId;

  const DeleteCategoryEvent({required this.categoryId});
}
