import 'package:expensive_management/business/blocs/api_result_state.dart';
import 'package:expensive_management/data/models/analytic_model.dart';
import 'package:expensive_management/utils/enum/api_error_result.dart';

class YearAnalyticState implements ApiResultState {
  final bool isLoading;
  final ApiError _apiError;
  final AnalyticModel? data;

  YearAnalyticState({
    this.isLoading = false,
    ApiError apiError = ApiError.noError,
    this.data,
  }) : _apiError = apiError;

  @override
  ApiError get apiError => _apiError;
}

extension YearAnalyticStateEx on YearAnalyticState {
  YearAnalyticState copyWith({
    bool? isLoading,
    ApiError? apiError,
    AnalyticModel? data,
  }) =>
      YearAnalyticState(
        isLoading: isLoading ?? this.isLoading,
        apiError: apiError ?? this.apiError,
        data: data ?? this.data,
      );
}
