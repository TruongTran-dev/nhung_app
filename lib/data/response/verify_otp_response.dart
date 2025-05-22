import 'package:expensive_management/data/response/base_response.dart';
import 'package:expensive_management/src/shared/utils/utils.dart';

import 'error_response.dart';
class VerifyOtpResponse extends BaseResponse {
  VerifyOtpResponse({
    super.httpStatus,
    super.message,
    super.errors,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    List<Errors> errors = [];
    if (isNotNullOrEmpty(json["errors"])) {
      final List<dynamic> errorsJson = json["errors"];
      errors = errorsJson.map((errorJson) => Errors.fromJson(errorJson)).toList();
    }

    return VerifyOtpResponse(
      httpStatus: json['httpStatus'],
      message: json['message'],
      errors: errors,
    );
  }
}
