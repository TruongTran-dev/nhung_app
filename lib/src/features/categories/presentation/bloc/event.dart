part of 'bloc.dart';

class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];

  @override
  bool get stringify => true;
}

class GetCategoriesEvent extends CategoryEvent {
  const GetCategoriesEvent({required this.type});
  final String type;

  @override
  List<Object?> get props => [type];

  @override
  bool get stringify => true;
}

class AddCategoryEvent extends CategoryEvent {
  const AddCategoryEvent({required this.data});
  final Map<String, dynamic> data;

  @override
  List<Object?> get props => [data];

  @override
  bool get stringify => true;
}
class UpdateCategoryEvent extends CategoryEvent {
  const UpdateCategoryEvent({required this.categoryId, required this.data});
  final int categoryId;
  final Map<String, dynamic> data;

  @override
  List<Object?> get props => [categoryId, data];

  @override
  bool get stringify => true;
}
class DeleteCategoryEvent extends CategoryEvent {
  const DeleteCategoryEvent({required this.categoryId});
  final int categoryId;

  @override
  List<Object?> get props => [categoryId];

  @override
  bool get stringify => true;
}
