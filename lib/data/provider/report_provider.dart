import 'package:expensive_management/src/features/my_wallet/domain/models/wallet_report_model.dart';

import '../api/api_path.dart';
import '../response/base_get_response.dart';
import 'provider_mixin.dart';

class ReportProvider with ProviderMixin {
  Future<Object> getReportByWalletId({
    required Map<String, dynamic> queryParam,
  }) async {
    if (await isExpiredToken()) {
      return ExpiredTokenGetResponse();
    }
    try {
      final response = await dio.get(
        ApiPath.apiDomain + ApiPath.getReportByWalletId,
        queryParameters: queryParam,
        options: await defaultOptions(url: ApiPath.apiDomain +  ApiPath.getReportByWalletId),
      );
      return WalletReportData.fromJson(response.data);
    } catch (error, stacktrace) {
      return errorGetResponse(error, stacktrace, ApiPath.getReportByWalletId);
    }
  }
}
