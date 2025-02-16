import 'package:expensive_management/data/models/logo_category_model.dart';
import 'package:expensive_management/utils/utils.dart';

import 'base_get_response.dart';

class ListLogoCategoryResponse extends BaseGetResponse {
  List<LogoCategoryModel>? listLogo;

  ListLogoCategoryResponse({
    this.listLogo,
    int? pageNumber,
    int? pageSize,
    int? totalRecord,
    int? status,
    String? error,
  }) : super(
          pageNumber: pageNumber,
          pageSize: pageSize,
          totalRecord: totalRecord,
          status: status,
          error: error,
        );

  factory ListLogoCategoryResponse.fromJson(Map<String, dynamic> json) {
    return ListLogoCategoryResponse(
      listLogo: isNullOrEmpty(json['content'])
          ? []
          : List<LogoCategoryModel>.generate(
              json['content'].length,
              (index) => LogoCategoryModel.fromJson(json['content'][index]),
            ),
      pageNumber: json['pageNumber'],
      pageSize: json['pageSize'],
      totalRecord: json['totalRecord'],
      status: json['status'],
      error: json['error'],
    );
  }
}
