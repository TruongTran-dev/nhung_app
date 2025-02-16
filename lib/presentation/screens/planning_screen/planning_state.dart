import 'package:expensive_management/business/blocs/api_result_state.dart';
import 'package:expensive_management/data/models/category_model.dart';
import 'package:expensive_management/data/models/wallet.dart';
import 'package:expensive_management/utils/enum/api_error_result.dart';

class PlanningState implements ApiResultState {
  final bool isLoading;
  final ApiError _apiError;
  final List<CategoryModel>? listExCategory;
  final List<CategoryModel>? listCoCategory;
  final List<Wallet>? listWallet;

  PlanningState({
    this.isLoading = false,
    ApiError apiError = ApiError.noError,
    this.listExCategory,
    this.listCoCategory,
    this.listWallet,
  }) : _apiError = apiError;

  @override
  ApiError get apiError => _apiError;
}

extension PlanningStateEx on PlanningState {
  PlanningState copyWith({
    bool? isLoading,
    ApiError? apiError,
    List<CategoryModel>? listExCategory,
    List<CategoryModel>? listCoCategory,
    List<Wallet>? listWallet,
  }) =>
      PlanningState(
        isLoading: isLoading ?? this.isLoading,
        apiError: apiError ?? this.apiError,
        listExCategory: listExCategory ?? this.listExCategory,
        listCoCategory: listCoCategory ?? this.listCoCategory,
        listWallet: listWallet ?? this.listWallet,
      );
}
