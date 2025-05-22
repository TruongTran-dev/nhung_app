import 'package:expensive_management/data/provider/wallet_provider.dart';
import 'package:expensive_management/data/response/base_get_response.dart';

class WalletRepository {
  final WalletProvider _walletProvider = WalletProvider();

  Future<BaseGetResponse> getListWallet() async => await _walletProvider.getListWallet();
}
