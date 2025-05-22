import 'dart:developer';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:expensive_management/src/features/categories/domain/models/category_model.dart';
import 'package:expensive_management/src/core/common/dio_provider.dart';
import 'package:expensive_management/src/core/common/extensions.dart';
import 'package:expensive_management/src/features/categories/domain/usecases/add_category.dart';
import 'package:expensive_management/src/features/categories/domain/usecases/delete_category.dart';
import 'package:expensive_management/src/features/categories/domain/usecases/get_categories.dart';
import 'package:expensive_management/src/features/categories/domain/usecases/update_category.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'event.dart';
part 'state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetCategoriesUseCase getCategoriesUseCase;
  final AddCategoryUseCase addCategoryUseCase;
  final UpdateCategoryUseCase updateCategoryUseCase;
  final DeleteCategoryUseCase deleteCategoryUseCase;

  CategoryBloc({
    required this.getCategoriesUseCase,
    required this.addCategoryUseCase,
    required this.updateCategoryUseCase,
    required this.deleteCategoryUseCase,
  }) : super(CategoryInitial()) {
    on<GetCategoriesEvent>(_onGetCategoriesEvent, transformer: droppable());
    on<AddCategoryEvent>(_onAddCategoryEvent, transformer: droppable());
    on<UpdateCategoryEvent>(_onUpdateCategoryEvent, transformer: droppable());
    on<DeleteCategoryEvent>(_onDeleteCategoryEvent, transformer: droppable());
  }

  Future<void> _onGetCategoriesEvent(GetCategoriesEvent event, Emitter<CategoryState> emit) async {
    GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
      emit(CategoryLoading());
    });

    final response = await getCategoriesUseCase.call(event.type.toUpperCase());

    if (response.isLeft) {
      final error = response.left;
      GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
        emit(GetCategoriesFailureState(message: error.message, key: error is ServerError ? error.key : null));
      });
    } else {
      final data = response.right['content'];
      if (data != null && data is List) {
        final categories = data.map((e) => CategoryModel.fromJson(e)).toList();
        GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
          emit(GetCategoriesSuccessState(categories: categories));
        });
      } else {
        GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
          emit(GetCategoriesFailureState(message: 'No data found'));
        });
      }
    }
  }

  Future<void> _onAddCategoryEvent(AddCategoryEvent event, Emitter<CategoryState> emit) async {
    GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
      emit(CategoryLoading());
    });

    final response = await addCategoryUseCase.call(event.data);

    if (response.isLeft) {
      final error = response.left;
      GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
        emit(AddCategoryFailureState(message: error.message, key: error is ServerError ? error.key : null));
      });
      return;
    }
    final data = response.right;
    log('Add category data: $data');
    final category = CategoryModel.fromJson(data);
    GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
      emit(AddCategorySuccessState(category: category));
    });
  }

  Future<void> _onUpdateCategoryEvent(UpdateCategoryEvent event, Emitter<CategoryState> emit) async {
    GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
      emit(CategoryLoading());
    });

    final response = await updateCategoryUseCase.call(
      UpdateCategoryParams(categoryId: event.categoryId.toString(), data: event.data),
    );

    if (response.isLeft) {
      final error = response.left;
      GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
        emit(UpdateCategoryFailureState(message: error.message, key: error is ServerError ? error.key : null));
      });
      return;
    }
    final data = response.right;
    log('Update category data: $data');
    final category = CategoryModel.fromJson(data);
    GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
      emit(UpdateCategorySuccessState(category: category));
    });
  }

  Future<void> _onDeleteCategoryEvent(DeleteCategoryEvent event, Emitter<CategoryState> emit) async {
    GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
      emit(CategoryLoading());
    });

    final response = await deleteCategoryUseCase.call(event.categoryId.toString());

    if (response.isLeft) {
      final error = response.left;
      GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
        emit(DeleteCategoryFailureState(message: error.message, key: error is ServerError ? error.key : null));
      });
      return;
    }
    final data = response.right;
    log('Delete category data: $data');

    GlobalExtensions.runEmitterBlocSafe(emit, (emit) {
      emit(
        data
            ? DeleteCategorySuccessState()
            : DeleteCategoryFailureState(message: 'Xóa danh mục thất bại. Vui lòng thử lại.'),
      );
    });
  }
}
