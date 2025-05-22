part of 'bloc.dart';

class CategoryState extends Equatable {
  const CategoryState();
  @override
  List<Object?> get props => [];
  @override
  bool get stringify => true;
}

class CategoryInitial extends CategoryState {}

class CategoryLoading extends CategoryState {}

class GetCategoriesSuccessState extends CategoryState {
  final List<CategoryModel> categories;
  const GetCategoriesSuccessState({required this.categories});
  @override
  List<Object?> get props => [categories];
  @override
  bool get stringify => true;
}

class GetCategoriesFailureState extends CategoryState {
  final String message;
  final String? key;
  const GetCategoriesFailureState({required this.message, this.key });
  @override
  List<Object?> get props => [message, key];
  @override
  bool get stringify => true;
}

class AddCategorySuccessState extends CategoryState {
  final CategoryModel category;
  const AddCategorySuccessState({required this.category});
  @override
  List<Object?> get props => [category];
  @override
  bool get stringify => true;
}

class AddCategoryFailureState extends CategoryState {
  final String message;
  final String? key;
  const AddCategoryFailureState({required this.message, this.key });
  @override
  List<Object?> get props => [message, key];
  @override
  bool get stringify => true;
}

class UpdateCategorySuccessState extends CategoryState {
  final CategoryModel category;
  const UpdateCategorySuccessState({required this.category});
  @override
  List<Object?> get props => [category];
  @override
  bool get stringify => true;
}

class UpdateCategoryFailureState extends CategoryState {
  final String message;
  final String? key;
  const UpdateCategoryFailureState({required this.message, this.key });
  @override
  List<Object?> get props => [message, key];
  @override
  bool get stringify => true;
}

class DeleteCategorySuccessState extends CategoryState {

}

class DeleteCategoryFailureState extends CategoryState {
  final String message;
  final String? key;
  const DeleteCategoryFailureState({required this.message, this.key });
  @override
  List<Object?> get props => [message, key];
  @override
  bool get stringify => true;
}
