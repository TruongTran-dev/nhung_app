import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expensive_management/data/models/category_report_model.dart';
import 'package:expensive_management/data/provider/category_provider.dart';
import 'package:expensive_management/data/response/base_response.dart';
import 'package:expensive_management/data/response/category_report_response.dart';
import 'package:expensive_management/presentation/screens/report_screen/revenue_report/revenue_report_event.dart';
import 'package:expensive_management/presentation/screens/report_screen/revenue_report/revenue_report_state.dart';
import 'package:expensive_management/utils/app_constants.dart';
import 'package:expensive_management/utils/enum/enum.dart';
import 'package:expensive_management/utils/screen_utilities.dart';

class RevenueReportBloc extends Bloc<RevenueReportEvent, RevenueReportState> {
  final BuildContext context;

  RevenueReportBloc(this.context) : super(LoadingState()) {
    on<RevenueReportEvent>((event, emit) async {
      emit(LoadingState());

      final response = await CategoryProvider().getDataReport(type: TransactionType.income);

      if (response is CategoryReportResponse) {
        List<CategoryReportModel> listReport = response.listReport ?? [];
        listReport.sort((a, b) => b.percent.compareTo(a.percent));

        emit(SuccessState(revenueReports: listReport));
      } else if (response is ExpiredTokenResponse && context.mounted) {
        logoutIfNeed(context);
      } else {
        emit(const FailureState(errorMessage: AppConstants.wrong));
      }
    });
  }
}
