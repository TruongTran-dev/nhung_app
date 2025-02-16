import 'package:expensive_management/business/blocs/api_result_state.dart';
import 'package:expensive_management/data/models/report_expenditure_revenue_model.dart';
import 'package:expensive_management/utils/enum/api_error_result.dart';


class CustomAnalyticState implements ApiResultState {
  final bool isLoading;
  final ApiError _apiError;
  final List<ReportData>? data;

  CustomAnalyticState({
    this.isLoading = false,
    ApiError apiError = ApiError.noError,
    this.data,
  }) : _apiError = apiError;

  @override
  ApiError get apiError => _apiError;
}

extension CustomAnalyticEx on CustomAnalyticState {
  CustomAnalyticState copyWith({
    bool? isLoading,
    ApiError? apiError,
    List<ReportData>? data,
  }) =>
      CustomAnalyticState(
        isLoading: isLoading ?? this.isLoading,
        apiError: apiError ?? this.apiError,
        data: data ?? this.data,
      );
}
