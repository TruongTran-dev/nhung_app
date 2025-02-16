import 'package:dio/dio.dart';
import 'package:expensive_management/data/models/limit_expenditure_model.dart';
import 'package:expensive_management/data/response/list_limit_response.dart';
import 'package:expensive_management/utils/enum/enum.dart';
import '../api/api_path.dart';
import '../response/base_get_response.dart';
import '../response/base_response.dart';
import '../response/limit_by_id_response.dart';
import 'provider_mixin.dart';

class LimitProvider with ProviderMixin {
  Future<BaseGetResponse> getListLimit({required TransactionStatus status}) async {
    if (await isExpiredToken()) {
      return ExpiredTokenGetResponse();
    }

    try {
      final response = await dio.get(
        ApiPath.expenseLimit,
        queryParameters: {'status': status.name.toUpperCase()},
        options: await defaultOptions(url: ApiPath.expenseLimit),
      );
      return ListLimitResponse.fromJson(response.data);
    } catch (error, stacktrace) {
      return errorGetResponse(error, stacktrace, ApiPath.expenseLimit);
    }
  }

  Future<BaseResponse> getListLimitByID(int limitID) async {
    if (await isExpiredToken()) {
      return ExpiredTokenResponse();
    }
    final apiGetLimitByID = '${ApiPath.expenseLimit}/${limitID.toString()}';
    try {
      final response = await dio.get(
        apiGetLimitByID,
        options: await defaultOptions(url: apiGetLimitByID),
      );

      return LimitByIDResponse.fromJson(response.data);
    } catch (error, stacktrace) {
      return errorResponse(error, stacktrace, apiGetLimitByID);
    }
  }

  Future<Object> addLimit({required Object data}) async {
    if (await isExpiredToken()) {
      return ExpiredTokenGetResponse();
    }
    try {
      Options options = await defaultOptions(url: ApiPath.expenseLimit);

      final response = await dio.post(ApiPath.expenseLimit, data: data, options: options);

      return LimitModel.fromJson(response.data);
    } catch (error, stacktrace) {
      return errorGetResponse(error, stacktrace, ApiPath.getListWallet);
    }
  }

  Future<Object> editLimit({required int? limitId, required Object data}) async {
    String apiUpdateWallet = '${ApiPath.expenseLimit}/$limitId';
    if (await isExpiredToken()) {
      return ExpiredTokenGetResponse();
    }
    try {
      Options options = await defaultOptions(url: apiUpdateWallet);

      final response = await dio.put(apiUpdateWallet, data: data, options: options);

      return LimitModel.fromJson(response.data);
    } catch (error, stacktrace) {
      return errorGetResponse(error, stacktrace, apiUpdateWallet);
    }
  }

  Future<Object> deleteLimit({required int limitId}) async {
    String apiRemoveWallet = '${ApiPath.expenseLimit}/$limitId';

    if (await isExpiredToken()) {
      return ExpiredTokenGetResponse();
    }
    try {
      Options options = await defaultOptions(url: apiRemoveWallet);

      return await dio.delete(apiRemoveWallet, options: options);
    } catch (error, stacktrace) {
      return errorGetResponse(error, stacktrace, apiRemoveWallet);
    }
  }
}
