import 'package:expensive_management/data/models/week_report_model.dart';
import 'package:expensive_management/data/response/base_response.dart';
import 'package:expensive_management/utils/utils.dart';

import 'error_response.dart';

class WeekReportResponse extends BaseResponse {
  final WeekReportModel data;

  WeekReportResponse({
    required this.data,
    int? httpStatus,
    String? message,
    List<Errors>? errors,
  }) : super(httpStatus: httpStatus, errors: errors);

  factory WeekReportResponse.fromJson(Map<String, dynamic> json) {
    List<Errors> errors = [];
    if (isNotNullOrEmpty(json["errors"])) {
      final List<dynamic> errorsJson = json["errors"];
      errors = errorsJson.map((errorJson) => Errors.fromJson(errorJson)).toList();
    }

    return WeekReportResponse(
      httpStatus: json["httpStatus"],
      message: json["message"],
      data: WeekReportModel.fromJson(json['data']),
      errors: errors,
    );
  }
}
