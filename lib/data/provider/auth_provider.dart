
import 'package:dio/dio.dart';
import 'package:expensive_management/data/api/api_path.dart';
import 'package:expensive_management/data/models/refresh_token_model.dart';
import 'package:expensive_management/data/response/base_response.dart';
import 'package:expensive_management/presentation/screens/planning_screen/balance_payments/balance_payment.dart';
import 'package:expensive_management/src/core/di/injection_container.dart';

import 'provider_mixin.dart';

class AuthProvider with ProviderMixin {
  // final SecureStorage _secureStorage = SecureStorage();
  final AppPrefStorage _pref = serviceLocator<AppPrefStorage>();

  Future<bool> checkAuthenticationStatus() async {
    String accessTokenExpired = _pref.getAccessTokenExpired();
    if (isNullOrEmpty(accessTokenExpired)) {
      return false;
    }

    if (DateTime.parse(accessTokenExpired).isBefore(DateTime.now())) {
      String refreshTokenExpired = _pref.getRefreshTokenExpired();

      if (DateTime.parse(refreshTokenExpired).isAfter(DateTime.now())) {
        String refreshToken = await _pref.getRefreshToken();
        final response = await AuthProvider().refreshToken(
          refreshToken: refreshToken,
        );
        await _pref.saveUserInfoRefresh(data: response);
        return true;
      }
      return false;
    }
    return true;
  }

  Future<RefreshTokenModel?> refreshToken({
    required String refreshToken,
  }) async {
    try {
      Response response = await dio.post(
        ApiPath.refreshToken,
        data: {"refreshToken": refreshToken},
      );

      return RefreshTokenModel.fromJson(response.data['data']);
    } catch (error, stacktrace) {
      showErrorLog(error, stacktrace, ApiPath.refreshToken);
      return null;
    }
  }

  Future<BaseResponse> changePassword({
    required String oldPass,
    required String newPass,
    required String confPass,
  }) async {
    final data = {"confirm_password": confPass, "current_password": oldPass, "password": newPass};
    if (await isExpiredToken()) {
      return ExpiredTokenResponse();
    }
    try {
      final response = await dio.post(
        ApiPath.apiDomain + ApiPath.changePassword,
        data: data,
        options: await defaultOptions(url: ApiPath.apiDomain + ApiPath.changePassword),
      );
      return BaseResponse.fromJson(response.data);
    } catch (error, stacktrace) {
      showErrorLog(error, stacktrace, ApiPath.changePassword);
      return BaseResponse();
    }
  }
}
