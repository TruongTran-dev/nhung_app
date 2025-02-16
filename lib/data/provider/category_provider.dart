import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:expensive_management/data/provider/provider_mixin.dart';
import '../../utils/enum/enum.dart';
import '../api/api_path.dart';
import '../models/category_model.dart';
import '../response/base_get_response.dart';
import '../response/base_response.dart';
import '../response/category_report_response.dart';
import '../response/delete_category_response.dart';
import '../response/get_list_category_response.dart';
import '../response/logo_category_response.dart';
import '../response/week_report_response.dart';

class CategoryProvider with ProviderMixin {
  Future<BaseGetResponse> getAllListCategory({required String param}) async {
    if (await isExpiredToken()) {
      return ExpiredTokenGetResponse();
    }

    try {
      Options options = await defaultOptions(
        url: ApiPath.getAllListCategory,
      );

      final response = await dio.get(
        ApiPath.getAllListCategory,
        queryParameters: {"type": param},
        options: options,
      );

      return GetCategoryResponse.fromJson(response.data);
    } catch (error, stacktrace) {
      log(error.toString());
      return errorGetResponse(error, stacktrace, ApiPath.getAllListCategory);
    }
  }

  Future<Object> addNewCategory({required Map<String, dynamic> data}) async {
    if (await isExpiredToken()) {
      return ExpiredTokenGetResponse();
    }
    try {
      final response = await dio.post(
        ApiPath.apiCategory,
        data: data,
        options: await defaultOptions(url: ApiPath.apiCategory),
      );

      return CategoryModel.fromJson(response.data);
    } catch (error, stacktrace) {
      return errorGetResponse(error, stacktrace, ApiPath.apiCategory);
    }
  }

  Future<Object> updateCategory({
    required int categoryId,
    required Map<String, dynamic> data,
  }) async {
    final String apiUpdateCategory = '${ApiPath.apiCategory}/$categoryId';

    if (await isExpiredToken()) {
      return ExpiredTokenGetResponse();
    }
    try {
      final response = await dio.put(
        apiUpdateCategory,
        data: data,
        options: await defaultOptions(url: apiUpdateCategory),
      );

      return CategoryModel.fromJson(response.data);
    } catch (error, stacktrace) {
      return errorGetResponse(error, stacktrace, apiUpdateCategory);
    }
  }

  Future<Object> deleteCategory({required int categoryId}) async {
    final String apiDeleteCategory = '${ApiPath.apiCategory}/$categoryId';

    if (await isExpiredToken()) {
      return ExpiredTokenResponse();
    }
    try {
      final response = await dio.delete(
        apiDeleteCategory,
        options: await defaultOptions(url: apiDeleteCategory),
      );
      return DeleteCategoryResponse.fromJson(response.data);
    } catch (error, stacktrace) {
      return errorResponse(error, stacktrace, apiDeleteCategory);
    }
  }

  Future<BaseGetResponse> getLogoCategory() async {
    if (await isExpiredToken()) {
      return ExpiredTokenGetResponse();
    }

    try {
      Options options = await defaultOptions(
        url: ApiPath.apiLogoCategory,
      );

      final response = await dio.get(
        ApiPath.apiLogoCategory,
        options: options,
      );

      return ListLogoCategoryResponse.fromJson(response.data);
    } catch (error, stacktrace) {
      return errorGetResponse(error, stacktrace, ApiPath.apiLogoCategory);
    }
  }

  Future<BaseResponse> getDataReport({required TransactionType type}) async {
    if (await isExpiredToken()) {
      return ExpiredTokenResponse();
    }
    try {
      final response = await dio.get(
        ApiPath.categoryReport,
        queryParameters: {'type': type.name.toUpperCase()},
        options: await defaultOptions(url: ApiPath.categoryReport),
      );

      return CategoryReportResponse.fromJson(response.data);
    } catch (error, stacktrace) {
      return errorResponse(error, stacktrace, ApiPath.categoryReport);
    }
  }

  Future<BaseResponse> getWeekReport() async {
    if (await isExpiredToken()) {
      return ExpiredTokenResponse();
    }
    try {
      final response = await dio.get(
        ApiPath.weekReport,
        options: await defaultOptions(url: ApiPath.weekReport),
      );
      return WeekReportResponse.fromJson(response.data);
    } catch (error, stacktrace) {
      return errorResponse(error, stacktrace, ApiPath.weekReport);
    }
  }
}
