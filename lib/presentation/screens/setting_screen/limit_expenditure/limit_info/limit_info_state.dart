
import 'package:expensive_management/business/blocs/api_result_state.dart';
import 'package:expensive_management/data/models/category_model.dart';
import 'package:expensive_management/data/models/wallet.dart';
import 'package:expensive_management/utils/enum/api_error_result.dart';

class LimitInfoState implements ApiResultState {
  final bool isLoading;
  final ApiError _apiError;
  final List<CategoryModel>? listExCategory;
  final List<Wallet>? listWallet;

  LimitInfoState({
    this.isLoading = false,
    ApiError apiError = ApiError.noError,
    this.listExCategory,
    this.listWallet,
  }) : _apiError = apiError;

  @override
  ApiError get apiError => _apiError;
}

extension LimitInfoStateEx on LimitInfoState {
  LimitInfoState copyWith({
    bool? isLoading,
    ApiError? apiError,
    List<CategoryModel>? listExCategory,
    List<Wallet>? listWallet,
  }) =>
      LimitInfoState(
        isLoading: isLoading ?? this.isLoading,
        apiError: apiError ?? this.apiError,
        listExCategory: listExCategory ?? this.listExCategory,
        listWallet: listWallet ?? this.listWallet,
      );
}
