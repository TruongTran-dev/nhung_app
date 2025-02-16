import 'package:expensive_management/data/models/collection_model.dart';

import 'base_get_response.dart';

class CollectionResponse extends BaseGetResponse {
  final CollectionModel? data;

  CollectionResponse({
    this.data,
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

  factory CollectionResponse.fromJson(Map<String, dynamic> json) =>
      CollectionResponse(
        data: json[''],
        pageNumber: json['pageNumber'],
        pageSize: json['pageSize'],
        totalRecord: json['totalRecord'],
        status: json['status'],
        error: json['error'],
      );

  @override
  String toString() {
    return 'CollectionResponse{data: $data}';
  }
}
