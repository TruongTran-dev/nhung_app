import 'package:expensive_management/src/features/my_wallet/domain/models/wallet.dart';
import 'package:expensive_management/src/shared/data/response/base_get_response.dart';

class GetListWalletResponse extends BaseGetResponse {
  final double moneyTotal;
  final List<Wallet> walletList;

  GetListWalletResponse({
    super.pageNumber,
    super.pageSize,
    super.totalRecord,
    super.status,
    super.error,
    required this.moneyTotal,
    required this.walletList,
  });
  factory GetListWalletResponse.fromJson(Map<String, dynamic> json) {
    return GetListWalletResponse(
      moneyTotal: double.tryParse(json['moneyTotal'].toString()) ?? 0.0,
      walletList: json['walletList'] == null
          ? []
          : List.generate(
              json['walletList'].length,
              (index) => Wallet.fromJson(json['walletList'][index]),
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
    return 'GetListWalletResponse{moneyTotal: $moneyTotal, walletList: $walletList}';
  }
}
