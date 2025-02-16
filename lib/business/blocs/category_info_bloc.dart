import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expensive_management/data/models/category_model.dart';
import 'package:expensive_management/data/provider/category_provider.dart';
import 'package:expensive_management/data/response/get_list_category_response.dart';
import 'package:expensive_management/data/response/logo_category_response.dart';
import 'package:expensive_management/presentation/screens/setting_screen/category/category_info/category_info_event.dart';
import 'package:expensive_management/presentation/screens/setting_screen/category/category_info/category_info_state.dart';

class CategoryInfoBloc extends Bloc<CategoryInfoEvent, CategoryInfoState> {
  final BuildContext context;

  final _categoryProvider = CategoryProvider();

  CategoryInfoBloc(this.context) : super(CategoryInfoInitial()) {
    on<CategoryInfoEvent>((event, emit) async {
      if (event is CategoryInitial) {
        emit(LoadingState());

        final responseLogo = await _categoryProvider.getLogoCategory();
        final responseEx = await _categoryProvider.getAllListCategory(param: "EXPENSE");
        final responseCo = await _categoryProvider.getAllListCategory(param: "INCOME");

        if (responseLogo is ListLogoCategoryResponse && responseEx is GetCategoryResponse && responseCo is GetCategoryResponse) {
          emit(OnSuccessState(listLogo: responseLogo.listLogo, listEx: responseEx.listCategory, listCo: responseCo.listCategory));
        } else {
          emit(OnFailureState());
        }
      }
      if (event is AddCategoryEvent) {
        emit(LoadingState());
        final addResponse = await _categoryProvider.addNewCategory(data: event.data);
        if (addResponse is CategoryModel) {
          emit(const OnSuccessState());
        }
      }
      if (event is UpdateCategoryEvent) {
        emit(LoadingState());
        final updateResponse = await _categoryProvider.updateCategory(categoryId: event.categoryId, data: event.data);
        if (updateResponse is CategoryModel) {
          emit(const OnSuccessState());
        }
      }
      if (event is DeleteCategoryEvent) {
        emit(LoadingState());
        await _categoryProvider.deleteCategory(categoryId: event.categoryId);
      }
    });
  }
}
