
import 'package:expensive_management/src/shared/data/models/analytic_model.dart';
import 'package:expensive_management/src/shared/data/response/base_response.dart';

import 'package:expensive_management/src/core/common/api_path.dart';
import 'package:expensive_management/src/shared/data/response/report_expenditure_revenue_response.dart';
import 'provider_mixin.dart';

class AnalyticProvider with ProviderMixin {
  Future<Object> getDayEXAnalytic({
    required Map<String, dynamic> query,
    required Map<String, dynamic> data,
  }) async {
    if (await isExpiredToken()) {
      return ExpiredTokenResponse();
    }
    try {
      final response = await dio.put(
        ApiPath.apiDomain + ApiPath.reportStatistic,
        data: data,
        queryParameters: query,
        options: await defaultOptions(
          url: ApiPath.apiDomain + ApiPath.reportStatistic,
          contentType: 'application/json',
        ),
      );

      return AnalyticModel.fromJson(response.data);
    } catch (error, stacktrace) {
      return errorResponse(error, stacktrace, ApiPath.reportStatistic);
    }
  }

  Future<BaseResponse> getBalanceAnalytic({
    required Map<String, dynamic> query,
    required Map<String, dynamic> data,
  }) async {
    if (await isExpiredToken()) {
      return ExpiredTokenResponse();
    }
    try {
      final response = await dio.put(
        ApiPath.apiDomain + ApiPath.getReport,
        data: data,
        queryParameters: query,
        options: await defaultOptions(
          url: ApiPath.apiDomain + ApiPath.getReport,
          contentType: 'application/json',
        ),
      );
      return ReportDataResponse.fromJson(response.data);
    } catch (error, stacktrace) {
      return errorResponse(error, stacktrace, ApiPath.getReport);
    }
  }
}
