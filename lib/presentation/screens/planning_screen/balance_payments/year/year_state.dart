import '../balance_payment.dart';

class YearAnalyticState implements ApiResultState {
  final bool isLoading;
  final ApiError _apiError;
  final List<ReportData>? data;

  YearAnalyticState({
    this.isLoading = false,
    ApiError apiError = ApiError.noError,
    this.data,
  }) : _apiError = apiError;

  @override
  ApiError get apiError => _apiError;
}

extension YearAnalyticEx on YearAnalyticState {
  YearAnalyticState copyWith({
    bool? isLoading,
    ApiError? apiError,
    List<ReportData>? data,
  }) =>
      YearAnalyticState(
        isLoading: isLoading ?? this.isLoading,
        apiError: apiError ?? this.apiError,
        data: data ?? this.data,
      );
}
