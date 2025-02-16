import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expensive_management/data/provider/analytic_provider.dart';
import 'package:expensive_management/data/response/base_response.dart';
import 'package:expensive_management/data/response/report_expenditure_revenue_response.dart';
import 'package:expensive_management/presentation/screens/planning_screen/balance_payments/balance_payment.dart';
import 'package:expensive_management/utils/screen_utilities.dart';

class PreciousAnalyticBloc
    extends Bloc<PreciousAnalyticEvent, PreciousAnalyticState> {
  final BuildContext context;
  PreciousAnalyticBloc(this.context) : super(PreciousAnalyticState()) {
    on((event, emit) async {
      if (event is PreciousAnalyticEvent) {
        emit(state.copyWith(isLoading: true));

        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult == ConnectivityResult.none) {
          emit(state.copyWith(
            isLoading: false,
            apiError: ApiError.noInternetConnection,
          ));
        } else {
          final Map<String, dynamic> query = {
            'type': 'QUARTER',
          };

          final Map<String, dynamic> data = {
            if (event.walletIDs.isNotEmpty) 'walletIds': event.walletIDs,
          };

          final response = await AnalyticProvider().getBalanceAnalytic(
            query: query,
            data: data,
          );

          if (response is ReportDataResponse) {
            emit(state.copyWith(
              isLoading: false,
              apiError: ApiError.noError,
              data: response.data,
            ));
          } else if (response is ExpiredTokenResponse && context.mounted) {
            logoutIfNeed(context);
          } else {
            emit(state.copyWith(
              isLoading: false,
              apiError: ApiError.internalServerError,
            ));
          }
        }
      }
    });
  }
}
