import 'package:expensive_management/data/models/limit_expenditure_model.dart';
import 'package:expensive_management/data/response/base_get_response.dart';

class ListLimitResponse extends BaseGetResponse {
  final List<LimitModel>? listLimit;

  ListLimitResponse({
    int? pageNumber,
    int? pageSize,
    int? totalRecord,
    int? status,
    String? error,
    this.listLimit,
  }) : super(
          pageNumber: pageNumber,
          pageSize: pageSize,
          totalRecord: totalRecord,
          status: status,
          error: error,
        );
  factory ListLimitResponse.fromJson(Map<String, dynamic> json) {
    return ListLimitResponse(
      listLimit: json['content'] == null
          ? []
          : List.generate(
              json['content'].length,
              (index) => LimitModel.fromJson(json['content'][index]),
            ),
      pageNumber: json['pageNumber'],
      pageSize: json['pageSize'],
      totalRecord: json['totalRecord'],
      status: json['status'],
      error: json['error'],
    );
  }

  @override
  String toString() {
    return 'ListLimitResponse{listLimit: $listLimit}';
  }
}
