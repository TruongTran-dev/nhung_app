import 'package:equatable/equatable.dart';
import 'package:expensive_management/src/core/common/api_result_state.dart';
import 'package:expensive_management/data/models/report_expenditure_revenue_model.dart';
import 'package:expensive_management/data/provider/analytic_provider.dart';
import 'package:expensive_management/src/shared/utils/enum/api_error_result.dart';
import 'package:expensive_management/src/shared/utils/network_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expensive_management/data/response/base_response.dart';
import 'package:expensive_management/data/response/report_expenditure_revenue_response.dart';
import 'package:expensive_management/src/shared/utils/screen_utilities.dart';

part 'current_event.dart';
part 'current_state.dart';

class CurrentAnalyticBloc extends Bloc<CurrentAnalyticEvent, CurrentAnalyticState> {
  final BuildContext context;
  CurrentAnalyticBloc(this.context) : super(CurrentAnalyticState()) {
    on((event, emit) async {
      if (event is CurrentAnalyticEvent) {
        emit(state.copyWith(isLoading: true));

        if (await NetworkInfo().isNotConnected) {
          emit(state.copyWith(
            isLoading: false,
            apiError: ApiError.noInternetConnection,
          ));
        } else {
          final Map<String, dynamic> query = {
            'type': 'CURRENT',
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
