import 'package:expensive_management/data/response/base_response.dart';
import 'package:expensive_management/data/response/error_response.dart';
import 'package:expensive_management/utils/utils.dart';

class DeleteCategoryResponse extends BaseResponse {
  final bool isDelete;
  final String? messages;

  DeleteCategoryResponse({
    this.isDelete = false,
    this.messages,
    int? httpStatus,
    String? message,
    List<Errors>? errors,
  }) : super(httpStatus: httpStatus, errors: errors);

  factory DeleteCategoryResponse.fromJson(Map<String, dynamic> json) {
    List<Errors> errors = [];
    if (isNotNullOrEmpty(json["errors"])) {
      final List<dynamic> errorsJson = json["errors"];
      errors = errorsJson.map((errorJson) => Errors.fromJson(errorJson)).toList();
    }

    return DeleteCategoryResponse(
      httpStatus: json["httpStatus"],
      message: json["message"],
      messages: json["message"],
      isDelete: json["isDelete"] ?? false,
      errors: errors,
    );
  }

  @override
  String toString() {
    return 'DeleteCategoryResponse{isDelete: $isDelete, messages: $messages}';
  }
}
