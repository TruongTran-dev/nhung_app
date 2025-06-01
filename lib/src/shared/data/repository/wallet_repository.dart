import 'package:expensive_management/src/shared/data/provider/wallet_provider.dart';
import 'package:expensive_management/src/shared/data/response/base_get_response.dart';

class WalletRepository {
  final WalletProvider _walletProvider = WalletProvider();

  Future<BaseGetResponse> getListWallet() async => await _walletProvider.getListWallet();
}
