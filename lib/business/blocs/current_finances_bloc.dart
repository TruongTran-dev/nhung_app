import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expensive_management/data/repository/wallet_repository.dart';
import 'package:expensive_management/data/response/base_get_response.dart';
import 'package:expensive_management/data/response/get_list_wallet_response.dart';
import 'package:expensive_management/presentation/screens/planning_screen/current_finances/current_finances_event.dart';
import 'package:expensive_management/presentation/screens/planning_screen/current_finances/current_finances_state.dart';
import 'package:expensive_management/utils/enum/api_error_result.dart';
import 'package:expensive_management/utils/screen_utilities.dart';

class CurrentFinancesBloc extends Bloc<CurrentFinancesEvent, CurrentFinancesState> {
  final _walletRepository = WalletRepository();
  final BuildContext context;

  CurrentFinancesBloc(this.context) : super(CurrentFinancesState()) {
    on((event, emit) async {
      if (event is CurrentFinancesInitEvent) {
        emit(state.copyWith(isLoading: true));
        // ConnectivityResult networkStatus = await Connectivity().onConnectivityChanged;
        // if (networkStatus == ConnectivityResult.none) {
        //   emit(state.copyWith(
        //     isLoading: false,
        //     apiError: ApiError.noInternetConnection,
        //   ));
        //   return;
        // }
        final response = await _walletRepository.getListWallet();
        if (response is GetListWalletResponse) {
          emit(state.copyWith(
            isLoading: false,
            listWallet: response.walletList,
            apiError: ApiError.noError,
          ));
        } else if (response is ExpiredTokenGetResponse && context.mounted) {
          logoutIfNeed(context);
        } else {
          emit(state.copyWith(
            isLoading: false,
            listWallet: [],
            apiError: ApiError.internalServerError,
          ));
        }
      }
    });
  }
}
