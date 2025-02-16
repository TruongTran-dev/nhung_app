import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expensive_management/data/models/refresh_token_model.dart';
import 'package:expensive_management/data/models/sign_in_model.dart';
import 'package:expensive_management/utils/secure_storage.dart';

import 'app_constants.dart';

class SharedPreferencesStorage {
  static late SharedPreferences _preferences;
  final SecureStorage _secureStorage = SecureStorage();

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  Future<bool> setLoggedOutStatus(bool value) {
    return _preferences.setBool(AppConstants.isLoggedOut, value);
  }

  bool getLoggedOutStatus() {
    return _preferences.getBool(AppConstants.isLoggedOut) ?? true;
  }

  ///save user info
  Future<void> setSaveUserInfo(SignInModel? data) async {
    if (data != null) {
      await _secureStorage.writeSecureData(
          AppConstants.accessTokenKey, data.accessToken);
      await _secureStorage.writeSecureData(
          AppConstants.refreshTokenKey, data.refreshToken);

      await _preferences.setString(
        AppConstants.accessTokenExpiredTimeKey,
        data.expiredAccessToken,
      );

      await _preferences.setString(
          AppConstants.refreshTokenExpiredKey, data.expiredRefreshToken);

      await _preferences.setString(AppConstants.usernameKey, data.username);
      await _preferences.setString(AppConstants.emailKey, data.email);
    } else {
      if (kDebugMode) {
        print('no data save');
      }
    }
  }

  Future<void> saveUserInfoRefresh({required RefreshTokenModel? data}) async {
    //write accessToken, refreshToken to secureStorage
    if (data != null) {
      await _secureStorage.writeSecureData(
          AppConstants.accessTokenKey, data.accessToken);
      await _secureStorage.writeSecureData(
          AppConstants.refreshTokenKey, data.refreshToken);
      await _preferences.setString(
          AppConstants.accessTokenExpiredTimeKey, data.accessTokenExpired);
    }
  }

  ///*****User
  String getUserName() =>
      _preferences.getString(AppConstants.usernameKey) ?? '';

  String getUserEmail() => _preferences.getString(AppConstants.emailKey) ?? '';

  String getAccessTokenExpired() {
    return _preferences.getString(AppConstants.accessTokenExpiredTimeKey) ?? '';
  }

  String? getAccessToken() =>
      _preferences.getString(AppConstants.accessTokenKey);

  String getRefreshTokenExpired() {
    return _preferences.getString(AppConstants.refreshTokenExpiredKey) ?? '';
  }

  ///************
  Future<void> setCurrency({required String currency}) async {
    await _preferences.setString(AppConstants.currencyKey, currency);
  }

  String getCurrency() =>
      _preferences.getString(AppConstants.currencyKey) ?? 'VND';

  Future<void> setHiddenAmount(bool value) async {
    await _preferences.setBool(AppConstants.isHiddenAmount, value);
  }

  bool getHiddenAmount() =>
      _preferences.getBool(AppConstants.isHiddenAmount) ?? false;

  ///logout
  void resetDataWhenLogout() {
    _preferences.setBool(AppConstants.isLoggedOut, false);
    _preferences.setBool(AppConstants.isRememberInfo, false);
  }

  ///save fcm_token
  Future<void> setFCMToken(String token) async =>
      await _preferences.setString(AppConstants.fcmTokenKey, token);

  String getFCMToken() =>
      _preferences.getString(AppConstants.fcmTokenKey) ?? '';
}
