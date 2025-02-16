import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:expensive_management/data/models/wallet_report_model.dart';
import 'package:expensive_management/data/repository/report_repository.dart';
import 'package:expensive_management/presentation/screens/wallet_detail_screen/wallet_details_event.dart';
import 'package:expensive_management/presentation/screens/wallet_detail_screen/wallet_details_state.dart';
import 'package:expensive_management/utils/enum/api_error_result.dart';

class WalletDetailBloc extends Bloc<WalletDetailEvent, WalletDetailState> {
  final BuildContext context;

  final _reportRepository = ReportRepository();
  WalletDetailBloc(this.context) : super(WalletDetailState()) {
    on((event, emit) async {
      if (event is WalletDetailInit) {
        emit(state.copyWith(isLoading: true));

        final String toDate = (event.toDate != null) ? event.toDate! : DateFormat('yyyy-MM-dd').format(DateTime.now());
        final String fromDate = (event.fromDate != null) ? event.fromDate! : DateFormat('yyyy-MM-dd').format(DateTime(DateTime.now().year, DateTime.now().month - 1, DateTime.now().day));

        final Map<String, dynamic> queryParam = {'fromDate': fromDate, 'toDate': toDate, 'walletId': event.walletId};

        final response = await _reportRepository.getReportByWalletId(queryParam: queryParam);

        if (response is WalletReport) {
          emit(state.copyWith(isLoading: false, walletReport: response, apiError: ApiError.noError));
        } else {
          emit(state.copyWith(isLoading: false, walletReport: null, apiError: ApiError.internalServerError));
        }
      }
    });
  }
}
