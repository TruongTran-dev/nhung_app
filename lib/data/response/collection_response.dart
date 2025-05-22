import 'package:expensive_management/src/features/my_wallet/domain/models/collection_model.dart';

import 'base_get_response.dart';

class CollectionResponse extends BaseGetResponse {
  final CollectionModel? data;

  CollectionResponse({
    this.data,
    super.pageNumber,
    super.pageSize,
    super.totalRecord,
    super.status,
    super.error,
  });

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
