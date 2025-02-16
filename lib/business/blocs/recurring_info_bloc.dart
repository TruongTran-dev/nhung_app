import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expensive_management/data/models/recurring_post_model.dart';
import 'package:expensive_management/data/provider/category_provider.dart';
import 'package:expensive_management/data/provider/wallet_provider.dart';
import 'package:expensive_management/data/repository/recurring_repository.dart';
import 'package:expensive_management/data/response/base_get_response.dart';
import 'package:expensive_management/data/response/get_list_category_response.dart';
import 'package:expensive_management/data/response/get_list_wallet_response.dart';
import 'package:expensive_management/presentation/screens/setting_screen/recurring_transaction/recurring_info/recurring_info_event.dart';
import 'package:expensive_management/presentation/screens/setting_screen/recurring_transaction/recurring_info/recurring_info_state.dart';
import 'package:expensive_management/utils/enum/api_error_result.dart';
import 'package:expensive_management/utils/screen_utilities.dart';

class RecurringInfoBloc extends Bloc<RecurringInfoEvent, RecurringInfoState> {
  final BuildContext context;

  final _categoryProvider = CategoryProvider();
  final _walletProvider = WalletProvider();
  final _recurringRepository = RecurringRepository();

  RecurringInfoBloc(this.context) : super(RecurringInfoState()) {
    on((event, emit) async {
      if (event is RecurringInfoEvent) {
        emit(state.copyWith(isLoading: true));

        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult == ConnectivityResult.none) {
          emit(state.copyWith(isLoading: false, apiError: ApiError.noInternetConnection));
        } else {
          final response = await _categoryProvider.getAllListCategory(param: "EXPENSE");
          if (response is GetCategoryResponse) {
            emit(state.copyWith(isLoading: false, apiError: ApiError.noError, listExCategory: response.listCategory));
          } else if (response is ExpiredTokenGetResponse && context.mounted) {
            logoutIfNeed(context);
          } else {
            emit(state.copyWith(isLoading: false, apiError: ApiError.internalServerError, listExCategory: []));
          }

          final walletResponse = await _walletProvider.getListWallet();

          if (walletResponse is GetListWalletResponse) {
            emit(state.copyWith(isLoading: false, apiError: ApiError.noError, listWallet: walletResponse.walletList));
          } else if (response is ExpiredTokenGetResponse && context.mounted) {
            logoutIfNeed(context);
          } else {
            emit(state.copyWith(isLoading: false, apiError: ApiError.internalServerError, listWallet: []));
          }
        }
      }

      if (event is AddRecurringEvent) {
        emit(state.copyWith(isLoading: true));

        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult == ConnectivityResult.none) {
          emit(state.copyWith(isLoading: false, apiError: ApiError.noInternetConnection));
        } else {
          final response = await _recurringRepository.addRecurring(event.data);

          if (response is RecurringPost) {
            emit(state.copyWith(isLoading: false, apiError: ApiError.noError, addSuccess: true));
          } else if (response is ExpiredTokenGetResponse && context.mounted) {
            logoutIfNeed(context);
          } else {
            emit(state.copyWith(isLoading: false, addSuccess: false, apiError: ApiError.noError));
          }
        }
      }
    });
  }
}
