import 'package:dio/dio.dart';
import 'package:expensive_management/src/shared/data/models/analytic_model.dart';
import 'package:expensive_management/src/shared/data/response/base_response.dart';

import 'package:expensive_management/src/core/common/api_path.dart';
import 'package:expensive_management/src/shared/data/response/error_response.dart';
import 'package:expensive_management/src/shared/data/response/report_expenditure_revenue_response.dart';
import 'provider_mixin.dart';

class AnalyticProvider with ProviderMixin {
  Future<dynamic> getDayEXAnalytic({
    required Map<String, dynamic> query,
    required Map<String, dynamic> data,
  }) async {
    if (await isExpiredToken()) {
      return ExpiredTokenResponse();
    }
    try {
      // print("📡 REQUEST [PUT]: ${dio.options.baseUrl + ApiPath.reportStatistic} - data: $data - param: $query");
      final response = await dio.put(
        ApiPath.apiDomain + ApiPath.reportStatistic,
        data: data,
        queryParameters: query,
        options: await defaultOptions(
          url: ApiPath.apiDomain + ApiPath.reportStatistic,
          contentType: 'application/json',
        ),
      );
      // print("📡 RESPONSE [PUT]: ${response.data}");

      return AnalyticModel.fromJson(response.data);
    } on DioException catch (error) {
      // print("error dio: ${error.response?.statusCode} - ${error.response?.data}");
      return BaseResponse(
        httpStatus: error.response?.statusCode,
        message: "Server error occurred. Please try again later.",
        errors: [
          Errors(
            errorCode: (error.response?.data['status'] ?? 404).toString(),
            errorMessage: error.response?.data['error'],
          ),
        ],
      );
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
      // print("📡 REQUEST [PUT]: ${dio.options.baseUrl + ApiPath.getReport} - data: $data - param: $query");
      final response = await dio.put(
        ApiPath.apiDomain + ApiPath.getReport,
        data: data,
        queryParameters: query,
        options: await defaultOptions(
          url: ApiPath.apiDomain + ApiPath.getReport,
          contentType: 'application/json',
        ),
      );
      // print("📡 RESPONSE [PUT]: ${response.data}");
      return ReportDataResponse.fromJson(response.data);
    } on DioException catch (error) {
      // print("error dio: ${error.response?.statusCode} - ${error.response?.data}");
      return BaseResponse(
        httpStatus: error.response?.statusCode,
        message: "Server error occurred. Please try again later.",
        errors: [
          Errors(
            errorCode: (error.response?.data['status'] ?? 404).toString(),
            errorMessage: error.response?.data['error'],
          ),
        ],
      );
    } catch (error, stacktrace) {
      // print("📡 ERROR [PUT]: ${error}");
      if (error is DioException) {
        return BaseResponse(
          httpStatus: error.response?.statusCode,
          message: "Server error occurred. Please try again later.",
          errors: [
            Errors(
              errorCode: (error.response?.data['status'] ?? 404).toString(),
              errorMessage: error.response?.data['error'],
            ),
          ],
        );
      }
      return errorResponse(error, stacktrace, ApiPath.getReport);
    }
  }
}
