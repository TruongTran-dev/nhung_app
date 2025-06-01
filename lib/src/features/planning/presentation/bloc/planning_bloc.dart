import 'package:equatable/equatable.dart';
import 'package:expensive_management/src/core/common/api_result_state.dart';
import 'package:expensive_management/src/shared/data/provider/category_provider.dart';
import 'package:expensive_management/src/shared/data/provider/wallet_provider.dart';
import 'package:expensive_management/src/features/categories/domain/models/category_model.dart';
import 'package:expensive_management/src/features/my_wallet/domain/models/wallet.dart';
import 'package:expensive_management/src/shared/utils/network_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expensive_management/src/shared/data/response/base_get_response.dart';
import 'package:expensive_management/src/shared/data/response/get_list_category_response.dart';
import 'package:expensive_management/src/shared/data/response/get_list_wallet_response.dart';
import 'package:expensive_management/src/shared/utils/enum/api_error_result.dart';
import 'package:expensive_management/src/shared/utils/screen_utilities.dart';

part 'planning_event.dart';
part 'planning_state.dart';

class PlanningBloc extends Bloc<PlanningEvent, PlanningState> {
  final BuildContext context;
  final _categoryProvider = CategoryProvider();
  final _walletProvider = WalletProvider();

  PlanningBloc(this.context) : super(PlanningState()) {
    on((event, emit) async {
      if (event is PlanningEvent) {
        emit(state.copyWith(isLoading: true));

        if (await NetworkInfo().isNotConnected) {
          emit(
            state.copyWith(
              isLoading: false,
              apiError: ApiError.noInternetConnection,
            ),
          );
        } else {
          final responseExpense = await _categoryProvider.getAllListCategory(param: "EXPENSE");
          if (responseExpense is GetCategoryResponse) {
            emit(state.copyWith(
              isLoading: false,
              apiError: ApiError.noError,
              listExCategory: responseExpense.listCategory,
            ));
          } else {
            emit(state.copyWith(
              isLoading: false,
              apiError: ApiError.internalServerError,
              listExCategory: [],
            ));
          }

          final responseIncome = await _categoryProvider.getAllListCategory(param: "INCOME");
          if (responseIncome is GetCategoryResponse) {
            emit(
              state.copyWith(
                isLoading: false,
                apiError: ApiError.noError,
                listCoCategory: responseIncome.listCategory,
              ),
            );
          } else {
            emit(state.copyWith(
              isLoading: false,
              apiError: ApiError.internalServerError,
              listCoCategory: [],
            ));
          }

          final walletResponse = await _walletProvider.getListWallet();
          if (walletResponse is GetListWalletResponse) {
            emit(
              state.copyWith(
                isLoading: false,
                apiError: ApiError.noError,
                listWallet: walletResponse.walletList,
              ),
            );
          } else if (walletResponse is ExpiredTokenGetResponse && context.mounted) {
            logoutIfNeed(context);
          } else {
            emit(state.copyWith(
              isLoading: false,
              apiError: ApiError.internalServerError,
              listCoCategory: [],
            ));
          }
        }
      }
    });
  }
}
