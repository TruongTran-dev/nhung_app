import 'package:expensive_management/src/shared/data/models/report_expenditure_revenue_model.dart';
import 'package:expensive_management/src/shared/data/response/base_response.dart';
import 'package:expensive_management/src/shared/utils/utils.dart';

import 'error_response.dart';

class ReportDataResponse extends BaseResponse {
  final List<ReportData> data;

  ReportDataResponse({
    required this.data,
    super.httpStatus,
    String? message,
    super.errors,
  });

  factory ReportDataResponse.fromJson(Map<String, dynamic> json) {
    List<Errors> errors = [];
    if (isNotNullOrEmpty(json["errors"])) {
      final List<dynamic> errorsJson = json["errors"];
      errors = errorsJson.map((errorJson) => Errors.fromJson(errorJson)).toList();
    }

    List<ReportData> reportDataList = (json['data'] as List<dynamic>).map((data) => ReportData.fromJson(data as Map<String, dynamic>)).toList();

    return ReportDataResponse(
      httpStatus: json["httpStatus"],
      message: json["message"],
      data: json["data"] == null ? [] : reportDataList,
      errors: errors,
    );
  }
}
