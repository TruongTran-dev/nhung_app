import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expensive_management/data/provider/category_provider.dart';
import 'package:expensive_management/data/response/get_list_category_response.dart';

import '../../presentation/screens/option_category_screen/option_category_event.dart';
import '../../presentation/screens/option_category_screen/option_category_state.dart';

class OptionCategoryBloc extends Bloc<OptionCategoryEvent, OptionCategoryState> {
  final BuildContext context;
  final _categoryProvider = CategoryProvider();

  OptionCategoryBloc(this.context) : super(OptionCategoryState()) {
    on((event, emit) async {
      if (event is GetOptionCategoryEvent) {
        emit(state.copyWith(isLoading: true));

        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult == ConnectivityResult.none) {
          emit(state.copyWith(isLoading: false, isNoInternet: true));
        } else {
          emit(state.copyWith(isLoading: true, isNoInternet: false));
          final responseExpense = await _categoryProvider.getAllListCategory(param: "EXPENSE");
          if (responseExpense is GetCategoryResponse) {
            emit(state.copyWith(isLoading: false, listExpenseCategory: responseExpense.listCategory));
          }

          final responseIncome = await _categoryProvider.getAllListCategory(param: "INCOME");
          if (responseIncome is GetCategoryResponse) {
            emit(state.copyWith(isLoading: false, listIncomeCategory: responseIncome.listCategory));
          }
        }
      }
    });
  }
}
