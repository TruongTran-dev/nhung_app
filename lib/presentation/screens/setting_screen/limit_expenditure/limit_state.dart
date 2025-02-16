import 'package:expensive_management/business/blocs/api_result_state.dart';
import 'package:expensive_management/data/models/limit_expenditure_model.dart';
import 'package:expensive_management/utils/enum/api_error_result.dart';

class LimitState implements ApiResultState {
  final bool isLoading;
  final ApiError _apiError;
  final List<LimitModel>? listLimit;

  LimitState({this.isLoading = false, ApiError apiError = ApiError.noError, this.listLimit}) : _apiError = apiError;

  @override
  ApiError get apiError => _apiError;
}

extension LimitStateEx on LimitState {
  LimitState copyWith({bool? isLoading, ApiError? apiError, List<LimitModel>? listLimit}) => LimitState(
        isLoading: isLoading ?? this.isLoading,
        apiError: apiError ?? this.apiError,
        listLimit: listLimit ?? listLimit,
      );
}
