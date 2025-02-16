import 'package:expensive_management/business/blocs/api_result_state.dart';
import 'package:expensive_management/utils/enum/api_error_result.dart';

class NewPasswordState implements ApiResultState {
  final bool isLoading;
  final String? errorMessage;
  final ApiError _apiError;

  NewPasswordState({ApiError apiError = ApiError.noError, this.isLoading = false, this.errorMessage}) : _apiError = apiError;

  @override
  ApiError get apiError => _apiError;
}

extension NewPasswordStateExtension on NewPasswordState {
  NewPasswordState copyWith({bool? isLoading, String? errorMessage, ApiError? apiError}) => NewPasswordState(
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage ?? this.errorMessage,
        apiError: apiError ?? this.apiError,
      );
}
