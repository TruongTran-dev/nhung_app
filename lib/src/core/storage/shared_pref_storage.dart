import 'dart:developer';

import 'package:expensive_management/src/features/auth/domain/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expensive_management/data/models/refresh_token_model.dart';

import '../../shared/utils/app_constants.dart';

class AppPrefStorage {
  final SharedPreferences pref;
  AppPrefStorage({required this.pref});

  Future<bool> setLoggedOutStatus(bool value) {
    return pref.setBool(AppConstants.isLoggedOut, value);
  }

  bool getLoggedOutStatus() {
    return pref.getBool(AppConstants.isLoggedOut) ?? true;
  }

  ///save user info
  Future<void> setSaveUserInfo(UserModel data) async {
    print("====save user info: ${data.toJson()}");
    log("====token: ${data.accessToken}");
    await pref.setString(AppConstants.accessTokenKey, data.accessToken);
    await pref.setString(AppConstants.refreshTokenKey, data.refreshToken);

    await pref.setString(AppConstants.accessTokenExpiredTimeKey, data.expiredAccessToken);

    await pref.setString(AppConstants.refreshTokenExpiredKey, data.expiredRefreshToken);

    await pref.setString(AppConstants.usernameKey, data.username);
    await pref.setString(AppConstants.emailKey, data.email);
    await pref.setString(AppConstants.userIdKey, data.id.toString());
  }

  Future<void> saveUserInfoRefresh({required RefreshTokenModel? data}) async {
    //write accessToken, refreshToken to secureStorage
    if (data != null) {
      await pref.setString(AppConstants.accessTokenKey, data.accessToken);
      await pref.setString(AppConstants.refreshTokenKey, data.refreshToken);
      await pref.setString(AppConstants.accessTokenExpiredTimeKey, data.accessTokenExpired);
    }
  }

  Future<String> getRefreshToken() async {
    String? refreshToken = pref.getString(AppConstants.refreshTokenKey);
    return refreshToken ?? '';
  }

  ///*****User
  String getUserName() => pref.getString(AppConstants.usernameKey) ?? '';

  String getUserId() => pref.getString(AppConstants.userIdKey) ?? '';

  String getUserEmail() => pref.getString(AppConstants.emailKey) ?? '';

  String getAccessTokenExpired() {
    return pref.getString(AppConstants.accessTokenExpiredTimeKey) ?? '';
  }

  String getAccessToken() => pref.getString(AppConstants.accessTokenKey) ?? '';

  String getRefreshTokenExpired() {
    return pref.getString(AppConstants.refreshTokenExpiredKey) ?? '';
  }

  ///************
  Future<void> setCurrency({required String currency}) async {
    await pref.setString(AppConstants.currencyKey, currency);
  }

  String getCurrency() => pref.getString(AppConstants.currencyKey) ?? 'VND';

  Future<void> setHiddenAmount(bool value) async {
    await pref.setBool(AppConstants.isHiddenAmount, value);
  }

  bool getHiddenAmount() => pref.getBool(AppConstants.isHiddenAmount) ?? false;

  ///logout
  void resetDataWhenLogout() {
    pref.remove(AppConstants.isLoggedOut);
    pref.remove(AppConstants.accessTokenKey);
    pref.remove(AppConstants.refreshTokenKey);
    pref.remove(AppConstants.accessTokenExpiredTimeKey);
    pref.remove(AppConstants.refreshTokenExpiredKey);
  }
}
