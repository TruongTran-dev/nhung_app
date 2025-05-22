import 'package:expensive_management/data/provider/analytic_provider.dart';
import 'package:expensive_management/presentation/screens/planning_screen/expenditure_analysis/analytics.dart';
import 'package:expensive_management/src/shared/utils/network_info.dart';

class YearAnalyticBloc extends Bloc<YearAnalyticEvent, YearAnalyticState> {
  final BuildContext context;
  YearAnalyticBloc(this.context) : super(YearAnalyticState()) {
    on((event, emit) async {
      if (event is YearAnalyticEvent) {
        // emit(state.copyWith(isLoading: true));

        if (await NetworkInfo().isNotConnected) {
          emit(state.copyWith(
            isLoading: false,
            apiError: ApiError.noInternetConnection,
          ));
        } else {
          final Map<String, dynamic> query = {
            'fromTime': event.fromYear,
            'timeType': 'YEAR',
            'toTime': event.toYear,
            'type': event.type.name.toUpperCase()
          };

          final Map<String, dynamic> data = {
            if (event.walletIDs.isNotEmpty) 'walletIds': event.walletIDs,
            if (event.categoryIDs.isNotEmpty) 'categoryIds': event.categoryIDs,
          };

          final response = await AnalyticProvider().getDayEXAnalytic(query: query, data: data);

          if (response is AnalyticModel) {
            emit(state.copyWith(isLoading: false, apiError: ApiError.noError, data: response));
          } else if (response is ExpiredTokenResponse && context.mounted) {
            logoutIfNeed(context);
          } else {
            emit(state.copyWith(isLoading: false, apiError: ApiError.internalServerError));
          }
        }
      }
    });
  }
}
