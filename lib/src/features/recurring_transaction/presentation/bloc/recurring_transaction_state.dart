part of 'recurring_transaction_bloc.dart';

class RecurringTransactionState implements ApiResultState {
  final bool isLoading;
  final ApiError _apiError;
  final List<RecurringListModel>? listRecurring;

  RecurringTransactionState({this.isLoading = false, ApiError apiError = ApiError.noError, this.listRecurring})
      : _apiError = apiError;

  @override
  ApiError get apiError => _apiError;
}

extension RecurringTransactionStateEx on RecurringTransactionState {
  RecurringTransactionState copyWith({
    bool? isLoading,
    ApiError? apiError,
    List<RecurringListModel>? listRecurring,
  }) =>
      RecurringTransactionState(
        isLoading: isLoading ?? this.isLoading,
        apiError: apiError ?? this.apiError,
        listRecurring: listRecurring ?? this.listRecurring,
      );
}
