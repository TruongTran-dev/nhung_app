import 'package:expensive_management/data/models/wallet.dart';
import 'package:expensive_management/data/response/base_get_response.dart';

class GetListWalletResponse extends BaseGetResponse {
  final double moneyTotal;
  final List<Wallet> walletList;

  GetListWalletResponse({
    int? pageNumber,
    int? pageSize,
    int? totalRecord,
    int? status,
    String? error,
    required this.moneyTotal,
    required this.walletList,
  }) : super(
          pageNumber: pageNumber,
          pageSize: pageSize,
          totalRecord: totalRecord,
          status: status,
          error: error,
        );
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
