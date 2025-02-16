import 'package:expensive_management/data/models/sign_in_model.dart';
import 'package:expensive_management/data/response/base_response.dart';
import 'package:expensive_management/data/response/error_response.dart';
import 'package:expensive_management/utils/utils.dart';

class SignInResponse extends BaseResponse {
  final SignInModel? data;

  SignInResponse({
    this.data,
    int? httpStatus,
    String? message,
    List<Errors>? errors,
  }) : super(httpStatus: httpStatus, errors: errors);

  factory SignInResponse.fromJson(Map<String, dynamic> json) {
    List<Errors> errors = [];
    if (isNotNullOrEmpty(json["errors"])) {
      final List<dynamic> errorsJson = json["errors"];
      errors = errorsJson.map((errorJson) => Errors.fromJson(errorJson)).toList();
    }

    return SignInResponse(
      httpStatus: json["httpStatus"],
      message: json["message"],
      data: json["data"] == null ? null : SignInModel.fromJson(json["data"]),
      errors: errors,
    );
  }
}
