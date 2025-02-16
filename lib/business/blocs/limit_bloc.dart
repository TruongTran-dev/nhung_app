import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expensive_management/data/provider/limit_provider.dart';
import 'package:expensive_management/data/response/base_get_response.dart';
import 'package:expensive_management/data/response/list_limit_response.dart';
import 'package:expensive_management/presentation/screens/setting_screen/limit_expenditure/limit_event.dart';
import 'package:expensive_management/presentation/screens/setting_screen/limit_expenditure/limit_state.dart';
import 'package:expensive_management/utils/enum/api_error_result.dart';
import 'package:expensive_management/utils/screen_utilities.dart';

class LimitBloc extends Bloc<LimitEvent, LimitState> {
  final BuildContext context;

  final _limitProvider = LimitProvider();
  LimitBloc(this.context) : super(LimitState()) {
    on((event, emit) async {
      if (event is GetListLimitEvent) {
        emit(state.copyWith(isLoading: true));
        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult == ConnectivityResult.none) {
          emit(
            state.copyWith(
              isLoading: false,
              apiError: ApiError.noInternetConnection,
            ),
          );
        } else {
          final response = await _limitProvider.getListLimit(
            status: event.status,
          );
          if (response is ListLimitResponse) {
            emit(state.copyWith(
              isLoading: false,
              apiError: ApiError.noError,
              listLimit: response.listLimit,
            ));
          } else if (response is ExpiredTokenGetResponse && context.mounted) {
            logoutIfNeed(context);
          } else {
            emit(state.copyWith(
              isLoading: false,
              apiError: ApiError.internalServerError,
              listLimit: [],
            ));
          }
        }
      }
    });
  }
}
