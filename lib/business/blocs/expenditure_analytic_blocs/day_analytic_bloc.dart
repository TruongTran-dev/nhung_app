import 'package:expensive_management/presentation/screens/planning_screen/expenditure_analysis/analytics.dart';

class DayAnalyticBloc extends Bloc<DayAnalyticEvent, DayAnalyticState> {
  final BuildContext context;
  DayAnalyticBloc(this.context) : super(DayAnalyticState()) {
    on((event, emit) async {
      if (event is DayAnalyticEvent) {
        // emit(state.copyWith(isLoading: true));

        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult == ConnectivityResult.none) {
          emit(state.copyWith(
            isLoading: false,
            apiError: ApiError.noInternetConnection,
          ));
        } else {
          final Map<String, dynamic> query = {'fromTime': event.fromDate, 'timeType': 'DAY', 'toTime': event.toDate, 'type': event.type.name.toUpperCase()};

          final Map<String, dynamic> data = {
            if (event.walletIDs.isNotEmpty) 'walletIds': event.walletIDs,
            if (event.categoryIDs.isNotEmpty) 'categoryIds': event.categoryIDs,
          };

          final response = await AnalyticProvider().getDayEXAnalytic(
            query: query,
            data: data,
          );

          if (response is AnalyticModel) {
            emit(state.copyWith(
              isLoading: false,
              apiError: ApiError.noError,
              data: response,
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
