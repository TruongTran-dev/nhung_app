import 'dart:convert';
import 'dart:developer';

import 'package:expensive_management/src/core/common/api_path.dart';
import 'package:expensive_management/src/shared/data/models/refresh_token_model.dart';
import 'package:expensive_management/src/core/storage/shared_pref_storage.dart';
import 'package:expensive_management/src/core/common/extensions.dart';
import 'package:expensive_management/src/core/di/injection_container.dart';
import 'package:expensive_management/src/shared/routes/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

class AppUtils {
  static final _sharedPref = serviceLocator<AppPrefStorage>();

  static Future<bool> isLoggedIn() async {
    final accessToken = _sharedPref.getAccessToken();
    log("===========Access Token: $accessToken");
    final isLoggedOut = _sharedPref.getLoggedOutStatus();
    final accessTokenExpiry = _sharedPref.getAccessTokenExpired();

    if (accessTokenExpiry.isNullOrEmpty) {
      return false;
    }

    try {
      final isAccessTokenValid = DateTime.parse(accessTokenExpiry).isAfter(DateTime.now());

      if (isAccessTokenValid && !isLoggedOut) {
        final accessToken = _sharedPref.getAccessToken();
        log("===========Access Token: $accessToken");
        return true;
      }

      // Access token expired, try refresh
      return await _refreshToken();
    } catch (_) {
      return false;
    }
  }

  static Future<bool> _refreshToken() async {
    try {
      final refreshTokenExpiry = _sharedPref.getRefreshTokenExpired();

      // If refresh token is expired or missing
      if (refreshTokenExpiry.isNullOrEmpty || DateTime.parse(refreshTokenExpiry).isBefore(DateTime.now())) {
        return false;
      }

      final refreshToken = await _sharedPref.getRefreshToken();
      final url = Uri.parse(ApiPath.apiDomain + ApiPath.refreshToken);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"refreshToken": refreshToken}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final tokenData = RefreshTokenModel.fromJson(jsonResponse['data']);
        await _sharedPref.saveUserInfoRefresh(data: tokenData);
        return true;
      }

      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isValidToken() async {
    final accessTokenExpiry = _sharedPref.getAccessTokenExpired();

    if (accessTokenExpiry.isNullOrEmpty) {
      return false;
    }

    try {
      // If access token is still valid
      if (DateTime.parse(accessTokenExpiry).isAfter(DateTime.now())) {
        return true;
      }

      // Access token expired, try to refresh
      return await _refreshToken();
    } catch (_) {
      return false;
    }
  }

  static void logout({BuildContext? context}) {
    _sharedPref.resetDataWhenLogout();
    if (context != null && context.mounted) {
      context.replace(AppRoutes.login);
    }
  }

  static void checkLogoutWhenTokenExpired(BuildContext context, {String? errorKey}) {
    if (errorKey == "token_expired" || errorKey == "token_invalid") {
      _sharedPref.resetDataWhenLogout();
      logout(context: context);
      showSnackBar(context, "Token expired. Please log in again.");
    }
  }

  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black54.withOpacity(0.8),
      ),
    );
  }

  static int parseDynamicToInt(dynamic value) {
    if (value is int) {
      return value;
    } else if (value is double || value is num) {
      return value.toInt();
    } else if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}
