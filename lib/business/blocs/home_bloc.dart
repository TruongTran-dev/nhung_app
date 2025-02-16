import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expensive_management/data/provider/category_provider.dart';
import 'package:expensive_management/data/repository/wallet_repository.dart';
import 'package:expensive_management/data/response/base_get_response.dart';
import 'package:expensive_management/data/response/get_list_wallet_response.dart';
import 'package:expensive_management/data/response/week_report_response.dart';
import 'package:expensive_management/presentation/screens/home_screen/home_event.dart';
import 'package:expensive_management/presentation/screens/home_screen/home_state.dart';
import 'package:expensive_management/utils/app_constants.dart';
import 'package:expensive_management/utils/screen_utilities.dart';

class HomePageBloc extends Bloc<HomePageEvent, HomePageState> {
  final BuildContext context;
  final _walletRepository = WalletRepository();

  HomePageBloc(this.context) : super(InitializedState()) {
    on((event, emit) async {
      if (event is InitializedEvent) {
        emit(LoadingState());

        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult == ConnectivityResult.none) {
          emit(const FailureState(errorMessage: AppConstants.noInternetContent));
        } else {
          final response = await _walletRepository.getListWallet();
          final weekResponse = await CategoryProvider().getWeekReport();

          if (response is GetListWalletResponse && weekResponse is WeekReportResponse) {
            emit(SuccessState(
              listWallet: response.walletList,
              amount: response.moneyTotal,
              weekReport: weekResponse.data,
            ));
          } else if ((response is ExpiredTokenGetResponse || weekResponse is ExpiredTokenGetResponse) && context.mounted) {
            logoutIfNeed(context);
          } else {
            emit(const FailureState(errorMessage: AppConstants.wrong));
          }
        }
      }
    });
  }
}
