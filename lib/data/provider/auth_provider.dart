import 'package:dio/dio.dart';
import 'package:expensive_management/data/api/api_path.dart';
import 'package:expensive_management/data/models/refresh_token_model.dart';
import 'package:expensive_management/data/response/base_response.dart';
import 'package:expensive_management/data/response/forgot_password_response.dart';
import 'package:expensive_management/data/response/sign_in_response.dart';
import 'package:expensive_management/data/response/sign_up_response.dart';
import 'package:expensive_management/data/response/verify_otp_response.dart';
import 'package:expensive_management/utils/app_constants.dart';
import 'package:expensive_management/utils/secure_storage.dart';
import 'package:expensive_management/utils/shared_preferences_storage.dart';
import 'package:expensive_management/utils/utils.dart';

import 'provider_mixin.dart';

class AuthProvider with ProviderMixin {
  final SecureStorage _secureStorage = SecureStorage();
  final SharedPreferencesStorage _pref = SharedPreferencesStorage();

  Future<bool> checkAuthenticationStatus() async {
    String accessTokenExpired = _pref.getAccessTokenExpired();
    if (isNullOrEmpty(accessTokenExpired)) {
      return false;
    }

    if (DateTime.parse(accessTokenExpired).isBefore(DateTime.now())) {
      String refreshTokenExpired = _pref.getRefreshTokenExpired();

      if (DateTime.parse(refreshTokenExpired).isAfter(DateTime.now())) {
        String refreshToken = await _secureStorage.readSecureData(
          AppConstants.refreshTokenKey,
        );
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

  Future<SignUpResponse> signUp({required Map<String, dynamic> data}) async {
    try {
      final response = await dio.post(ApiPath.signup, data: data);

      return SignUpResponse.fromJson(response.data);
    } catch (error, stacktrace) {
      showErrorLog(error, stacktrace, ApiPath.signup);
      if (error is DioError) {
        return SignUpResponse.fromJson(error.response?.data);
      }
      return SignUpResponse();
    }
  }

  Future<SignInResponse> signIn({
    required String username,
    required String password,
  }) async {
    try {
      // String fcmToken = await AwesomeNotification().requestFirebaseToken();

      final data = {'deviceToken': '', "password": password, "username": username};

      final response = await dio.post(ApiPath.signIn, data: data, options: Options(receiveTimeout: const Duration(seconds: 10), sendTimeout: const Duration(seconds: 10)));
      return SignInResponse.fromJson(response.data);
    } catch (error, stacktrace) {
      showErrorLog(error, stacktrace, ApiPath.signIn);
      if (error is DioError) {
        return SignInResponse.fromJson(error.response?.data);
      }
      return SignInResponse();
    }
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

  Future<ForgotPasswordResponse> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await dio.post(
        ApiPath.forgotPassword,
        data: {"email": email},
      );
      return ForgotPasswordResponse.fromJson(response.data);
    } catch (error) {
      if (error is DioError) {
        return ForgotPasswordResponse.fromJson(error.response?.data);
      }
      return ForgotPasswordResponse();
    }
  }

  Future<VerifyOtpResponse> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    try {
      final data = {"email": email, "otp": otpCode};

      final response = await dio.post(
        ApiPath.sendOtp,
        data: data,
        //options: AppConstants.options,
      );
      return VerifyOtpResponse.fromJson(response.data);
    } catch (error) {
      //showErrorLog(error, stacktrace, ApiPath.sendOtp);
      if (error is DioError) {
        return VerifyOtpResponse.fromJson(error.response?.data);
      }
      return VerifyOtpResponse();
    }
  }

  Future<BaseResponse> newPassword({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final data = {"confirm_password": confirmPassword, "email": email, "password": confirmPassword};

      final response = await dio.post(
        ApiPath.newPassword,
        data: data,
      );
      return BaseResponse.fromJson(response.data);
    } catch (error, stacktrace) {
      showErrorLog(error, stacktrace, ApiPath.newPassword);
      return BaseResponse();
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
        ApiPath.changePassword,
        data: data,
        options: await defaultOptions(url: ApiPath.changePassword),
      );
      return BaseResponse.fromJson(response.data);
    } catch (error, stacktrace) {
      showErrorLog(error, stacktrace, ApiPath.changePassword);
      return BaseResponse();
    }
  }
}
