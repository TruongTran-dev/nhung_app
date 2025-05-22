import 'package:expensive_management/src/features/categories/domain/models/category_model.dart';
import 'package:expensive_management/src/shared/utils/utils.dart';

import 'base_get_response.dart';

class GetCategoryResponse extends BaseGetResponse {
  List<CategoryModel>? listCategory;

  GetCategoryResponse({
    this.listCategory,
    super.pageNumber,
    super.pageSize,
    super.totalRecord,
    super.status,
    super.error,
  });

  factory GetCategoryResponse.fromJson(Map<String, dynamic> json) {
    return GetCategoryResponse(
      listCategory: isNullOrEmpty(json['content'])
          ? []
          : List<CategoryModel>.generate(
              json['content'].length,
              (index) => CategoryModel.fromJson(json['content'][index]),
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
    return 'GetCategoryResponse{listCategory: $listCategory}';
  }
}
