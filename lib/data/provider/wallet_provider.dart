import 'package:dio/dio.dart';
import 'package:expensive_management/data/response/get_list_wallet_response.dart';

import '../api/api_path.dart';
import '../response/base_get_response.dart';
import 'provider_mixin.dart';

class WalletProvider with ProviderMixin {
  Future<BaseGetResponse> getListWallet() async {
    if (await isExpiredToken()) {
      return ExpiredTokenGetResponse();
    }

    try {
      final response = await dio.get(ApiPath.getListWallet, options: await defaultOptions(url: ApiPath.getListWallet));
      return GetListWalletResponse.fromJson(response.data);
    } catch (error, stacktrace) {
      return errorGetResponse(error, stacktrace, ApiPath.getListWallet);
    }
  }

  Future<BaseGetResponse> createNewWallet({
    required Object data,
  }) async {
    if (await isExpiredToken()) {
      return ExpiredTokenGetResponse();
    }
    try {
      Options options = await defaultOptions(url: ApiPath.getListWallet);

      final response = await dio.post(ApiPath.getListWallet, data: data, options: options);

      return GetListWalletResponse.fromJson(response.data);
    } catch (error, stacktrace) {
      return errorGetResponse(error, stacktrace, ApiPath.getListWallet);
    }
  }

  Future<BaseGetResponse> updateNewWallet({required int? walletId, required Object data}) async {
    String apiUpdateWallet = '${ApiPath.getListWallet}/$walletId';
    if (await isExpiredToken()) {
      return ExpiredTokenGetResponse();
    }
    try {
      Options options = await defaultOptions(url: apiUpdateWallet);

      final response = await dio.put(apiUpdateWallet, data: data, options: options);

      return GetListWalletResponse.fromJson(response.data);
    } catch (error, stacktrace) {
      return errorGetResponse(error, stacktrace, apiUpdateWallet);
    }
  }

  Future<Object> removeWalletWithId({required int walletId}) async {
    String apiRemoveWallet = '${ApiPath.getListWallet}/$walletId';

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
