import 'package:expensive_management/data/models/analytic_model.dart';
import 'package:expensive_management/data/response/base_response.dart';

import '../api/api_path.dart';
import '../response/report_expenditure_revenue_response.dart';
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
        ApiPath.analyticReport,
        data: data,
        queryParameters: query,
        options: await defaultOptions(
          url: ApiPath.analyticReport,
          contentType: 'application/json',
        ),
      );
      return AnalyticModel.fromJson(response.data);
    } catch (error, stacktrace) {
      return errorResponse(error, stacktrace, ApiPath.analyticReport);
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
        ApiPath.getReport,
        data: data,
        queryParameters: query,
        options: await defaultOptions(
          url: ApiPath.getReport,
          contentType: 'application/json',
        ),
      );
      return ReportDataResponse.fromJson(response.data);
    } catch (error, stacktrace) {
      return errorResponse(error, stacktrace, ApiPath.getReport);
    }
  }
}
