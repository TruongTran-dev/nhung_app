import 'package:expensive_management/business/blocs/api_result_state.dart';
import 'package:expensive_management/data/models/category_model.dart';
import 'package:expensive_management/utils/enum/api_error_result.dart';

class OptionCategoryState implements ApiResultState {
  final bool isLoading;
  final ApiError _apiError;
  final bool isNoInternet;
  final List<CategoryModel>? listExpenseCategory;
  final List<CategoryModel>? listIncomeCategory;

  OptionCategoryState({
    this.isLoading = true,
    ApiError apiError = ApiError.noError,
    this.isNoInternet = false,
    this.listExpenseCategory,
    this.listIncomeCategory,
  }) : _apiError = apiError;

  @override
  ApiError get apiError => _apiError;
}

extension OptionCategoryStateEx on OptionCategoryState {
  OptionCategoryState copyWith({
    bool? isLoading,
    ApiError? apiError,
    bool? isNoInternet,
    List<CategoryModel>? listExpenseCategory,
    List<CategoryModel>? listIncomeCategory,
  }) =>
      OptionCategoryState(
        isLoading: isLoading ?? this.isLoading,
        apiError: apiError ?? this.apiError,
        isNoInternet: isNoInternet ?? this.isNoInternet,
        listExpenseCategory: listExpenseCategory ?? this.listExpenseCategory,
        listIncomeCategory: listIncomeCategory ?? this.listIncomeCategory,
      );
}
