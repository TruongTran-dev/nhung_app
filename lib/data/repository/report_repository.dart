import '../provider/report_provider.dart';

class ReportRepository {
  final _reportProvider = ReportProvider();

  Future<Object> getReportByWalletId({required Map<String, dynamic> queryParam}) async => await _reportProvider.getReportByWalletId(queryParam: queryParam);
}
