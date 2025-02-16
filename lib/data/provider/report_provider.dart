import 'package:expensive_management/data/models/wallet_report_model.dart';

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
        ApiPath.getReportByWalletId,
        queryParameters: queryParam,
        options: await defaultOptions(url: ApiPath.getReportByWalletId),
      );
      return WalletReport.fromJson(response.data);
    } catch (error, stacktrace) {
      return errorGetResponse(error, stacktrace, ApiPath.getReportByWalletId);
    }
  }
}
