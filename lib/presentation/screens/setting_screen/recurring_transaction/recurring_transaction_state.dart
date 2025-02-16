import 'package:expensive_management/business/blocs/api_result_state.dart';
import 'package:expensive_management/data/models/recurring_list_model.dart';
import 'package:expensive_management/utils/enum/api_error_result.dart';

class RecurringTransactionState implements ApiResultState {
  final bool isLoading;
  final ApiError _apiError;
  final List<RecurringListModel>? listRecurring;

  RecurringTransactionState({this.isLoading = false, ApiError apiError = ApiError.noError, this.listRecurring}) : _apiError = apiError;

  @override
  ApiError get apiError => _apiError;
}

extension RecurringTransactionStateEx on RecurringTransactionState {
  RecurringTransactionState copyWith({bool? isLoading, ApiError? apiError, List<RecurringListModel>? listRecurring}) => RecurringTransactionState(
        isLoading: isLoading ?? this.isLoading,
        apiError: apiError ?? this.apiError,
        listRecurring: listRecurring ?? this.listRecurring,
      );
}
