import 'package:expensive_management/data/provider/wallet_provider.dart';
import 'package:expensive_management/data/response/base_get_response.dart';

class WalletRepository {
  final WalletProvider _walletProvider = WalletProvider();

  Future<BaseGetResponse> getListWallet() async => await _walletProvider.getListWallet();

  Future<BaseGetResponse> createNewWallet({
    required int accountBalance,
    required String accountType,
    required String currency,
    required String description,
    required String name,
    // required bool report,
  }) async {
    final data = {
      "accountBalance": accountBalance,
      "accountType": accountType,
      "currency": currency,
      "description": description,
      "name": name,
      // "report": report
    };

    return await _walletProvider.createNewWallet(data: data);
  }

  Future<BaseGetResponse> updateNewWallet({
    required int? walletId,
    required int accountBalance,
    required String accountType,
    required String currency,
    required String description,
    required String name,
    // required bool report,
  }) async {
    final data = {
      "accountBalance": accountBalance,
      "accountType": accountType,
      "currency": currency,
      "description": description,
      "name": name,
      // "report": report
    };

    return await _walletProvider.updateNewWallet(walletId: walletId, data: data);
  }

  Future<Object> removeWalletWithID({required int walletId}) async => await _walletProvider.removeWalletWithId(walletId: walletId);
}
