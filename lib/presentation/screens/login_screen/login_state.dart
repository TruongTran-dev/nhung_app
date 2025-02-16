import 'package:equatable/equatable.dart';
import 'package:expensive_management/business/blocs/api_result_state.dart';
import 'package:expensive_management/utils/enum/api_error_result.dart';

abstract class LoginState extends Equatable{
  const LoginState();

  @override
  List<Object> get props => [];
}

class InitialLogin extends LoginState{}

class LoadingState extends LoginState{}

class LoginSuccess extends LoginState{}

class LoginFailed extends LoginState{
  final String errorMessage;

  const LoginFailed({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}

class LogInState implements ApiResultState {
  final bool isLoading;
  final bool isSuccess;
  final bool isError;
  final String? errorMessage;
  final ApiError _apiError;

  LogInState({
    ApiError apiError = ApiError.noError,
    this.isLoading = false,
    this.errorMessage,
    this.isSuccess = false,
    this.isError = false,
  }) : _apiError = apiError;


  @override
  String toString() {
    return 'LogInState{isLoading: $isLoading, isSuccess: $isSuccess, isError: $isError, errorMessage: $errorMessage, _apiError: $_apiError}';
  }

  @override
  ApiError get apiError => _apiError;

  LogInState copyWith({
    bool? isLoading,
    String? errorMessage,
    ApiError? apiError,
    bool? isSuccess,
    bool? isError,
  }) =>
      LogInState(
        isLoading: isLoading ?? this.isLoading,
        isSuccess: isSuccess ?? this.isSuccess,
        isError: isError ?? this.isError,
        errorMessage: errorMessage ?? this.errorMessage,
        apiError: apiError ?? this.apiError,
      );
}
