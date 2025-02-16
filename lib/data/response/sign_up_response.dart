import 'package:expensive_management/data/response/base_response.dart';
import 'package:expensive_management/utils/utils.dart';

import 'error_response.dart';

class SignUpResponse extends BaseResponse {
  SignUpResponse({
    httpStatus,
    String? message,
    List<Errors>? errors,
  }) : super(httpStatus: httpStatus, message: message, errors: errors);

  factory SignUpResponse.fromJson(Map<String, dynamic> json) {
    List<Errors> errors = [];
    if (isNotNullOrEmpty(json["errors"])) {
      final List<dynamic> errorsJson = json["errors"];
      errors = errorsJson.map((errorJson) => Errors.fromJson(errorJson)).toList();
    }

    return SignUpResponse(
      httpStatus: json['httpStatus'],
      message: json['message'],
      errors: errors,
    );
  }
}
