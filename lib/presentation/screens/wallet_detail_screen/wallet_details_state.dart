import 'package:expensive_management/business/blocs/api_result_state.dart';
import 'package:expensive_management/data/models/wallet_report_model.dart';
import 'package:expensive_management/utils/enum/api_error_result.dart';

class WalletDetailState implements ApiResultState {
  final bool isLoading;
  final ApiError _apiError;
  final WalletReport? walletReport;

  WalletDetailState({ApiError apiError = ApiError.noError, this.isLoading = false, this.walletReport}) : _apiError = apiError;

  @override
  ApiError get apiError => _apiError;
}

extension WalletDetailsStateExtension on WalletDetailState {
  WalletDetailState copyWith({bool? isLoading, ApiError? apiError, WalletReport? walletReport}) => WalletDetailState(
        isLoading: isLoading ?? this.isLoading,
        apiError: apiError ?? this.apiError,
        walletReport: walletReport ?? this.walletReport,
      );
}
