import 'package:expensive_management/data/models/limit_expenditure_model.dart';
import 'package:expensive_management/data/response/base_response.dart';
import 'package:expensive_management/utils/utils.dart';

import 'error_response.dart';

class LimitByIDResponse extends BaseResponse {
  final LimitModel? data;

  LimitByIDResponse({
    this.data,
    int? httpStatus,
    String? message,
    List<Errors>? errors,
  }) : super(httpStatus: httpStatus, errors: errors);

  factory LimitByIDResponse.fromJson(Map<String, dynamic> json) {
    List<Errors> errors = [];
    if (isNotNullOrEmpty(json["errors"])) {
      final List<dynamic> errorsJson = json["errors"];
      errors = errorsJson.map((errorJson) => Errors.fromJson(errorJson)).toList();
    }

    return LimitByIDResponse(
      httpStatus: json["httpStatus"],
      message: json["message"],
      data: json["data"] == null ? null : LimitModel.fromJson(json["data"]),
      errors: errors,
    );
  }
}
