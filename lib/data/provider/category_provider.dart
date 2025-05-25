import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:expensive_management/data/provider/provider_mixin.dart';
import '../api/api_path.dart';
import '../response/base_get_response.dart';
import '../response/get_list_category_response.dart';

class CategoryProvider with ProviderMixin {
  Future<BaseGetResponse> getAllListCategory({required String param}) async {
    if (await isExpiredToken()) {
      return ExpiredTokenGetResponse();
    }

    try {
      Options options = await defaultOptions(
        url: ApiPath.apiDomain + ApiPath.getAllListCategory,
      );

      final response = await dio.get(
        ApiPath.apiDomain + ApiPath.getAllListCategory,
        queryParameters: {"type": param},
        options: options,
      );

      return GetCategoryResponse.fromJson(response.data);
    } catch (error, stacktrace) {
      log(error.toString());
      return errorGetResponse(error, stacktrace, ApiPath.getAllListCategory);
    }
  }

  
}
