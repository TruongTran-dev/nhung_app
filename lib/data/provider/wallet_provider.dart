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
      final response = await dio.get(
        ApiPath.apiDomain + ApiPath.wallet,
        options: await defaultOptions(url: ApiPath.apiDomain + ApiPath.wallet),
      );
      return GetListWalletResponse.fromJson(response.data);
    } catch (error, stacktrace) {
      return errorGetResponse(error, stacktrace, ApiPath.wallet);
    }
  }
}
