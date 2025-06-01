import 'package:expensive_management/src/core/common/api_path.dart';
import 'package:expensive_management/src/shared/data/models/recurring_post_model.dart';
import 'package:expensive_management/src/shared/data/response/base_get_response.dart';
import 'package:expensive_management/src/shared/data/response/recurring_response.dart';

import 'provider_mixin.dart';

class RecurringProvider with ProviderMixin {
  Future<BaseGetResponse> getListRecurring(Map<String, dynamic> query) async {
    if (await isExpiredToken()) {
      return ExpiredTokenGetResponse();
    }
    try {
      final response = await dio.get(
       ApiPath.apiDomain +   ApiPath.recurring,
        queryParameters: query,
        options: await defaultOptions(url: ApiPath.apiDomain +  ApiPath.recurring),
      );
      return RecurringResponse.fromJson(response.data);
    } catch (error, stacktrace) {
      return errorGetResponse(error, stacktrace, ApiPath.recurring);
    }
  }

  Future<Object> addRecurring(Map<String, dynamic> data) async {
    if (await isExpiredToken()) {
      return ExpiredTokenGetResponse();
    }
    try {
      final response = await dio.post(
        ApiPath.apiDomain +  ApiPath.recurring,
        data: data,
        options: await defaultOptions(url: ApiPath.apiDomain +  ApiPath.recurring),
      );
      return RecurringPost.fromJson(response.data);
    } catch (error, stacktrace) {
      return errorGetResponse(error, stacktrace, ApiPath.recurring);
    }
  }

  Future<Object> updateRecurring(recurringID, Map<String, dynamic> data) async {
    if (await isExpiredToken()) {
      return ExpiredTokenGetResponse();
    }
    String apiUpdate =  '${ApiPath.apiDomain}${ApiPath.recurring}/${recurringID.toString()}';
    try {
      final response = await dio.put(
        apiUpdate,
        data: data,
        options: await defaultOptions(url: apiUpdate),
      );

      return RecurringPost.fromJson(response.data);
    } catch (error, stacktrace) {
      return errorGetResponse(error, stacktrace, apiUpdate);
    }
  }

  Future<Object> deleteRecurring(int recurringID) async {
    if (await isExpiredToken()) {
      return ExpiredTokenGetResponse();
    }
    String apiDelete = '${ApiPath.apiDomain}${ApiPath.recurring}/${recurringID.toString()}';
    try {
      final response = await dio.delete(apiDelete, options: await defaultOptions(url: apiDelete));
      return response;
    } catch (error, stacktrace) {
      return errorGetResponse(error, stacktrace, apiDelete);
    }
  }
}
