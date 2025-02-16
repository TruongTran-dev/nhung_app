import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:expensive_management/utils/app_constants.dart';
import 'package:expensive_management/utils/secure_storage.dart';
import '../response/base_get_response.dart';
import '../response/base_response.dart';
import 'auth_provider.dart';

mixin ProviderMixin {
  late Dio _dio;
  AuthProvider? _authProvider;

  Dio get dio {
    _dio = Dio()..httpClientAdapter = HttpClientAdapter();
    return _dio;
  }

  void showErrorLog(error, stacktrace, apiPath) {
    if (kDebugMode) {
      if (apiPath != null) {
        print("EXCEPTION OCCURRED: ${apiPath.toString()}");
      }
      if (error is DioError) {
        print("\nEXCEPTION RESPONSE: ${error.response}");
      }
      print("\nEXCEPTION WITH: $error\nSTACKTRACE: $stacktrace");
    }
  }

  BaseResponse errorResponse(error, stacktrace, apiPath) {
    showErrorLog(error, stacktrace, apiPath);
    debugPrint('error: ${error.toString()}');

    return BaseResponse.withHttpError(
      message: error.toString(),
      httpStatus: error.response?.statusCode ,
      errors:  error.response?.data,
    );
  }

  BaseGetResponse errorGetResponse(error, stacktrace, apiPath) {
    showErrorLog(error, stacktrace, apiPath);
    return BaseGetResponse.withHttpError(
      status: error.response?.statusCode,
      error: error.toString(),
      pageNumber: null,
      pageSize: null,
      totalRecord: null,
    );
  }

  Future<Options> defaultOptions({String? url, String? contentType, String? accept}) async {
    String token = await SecureStorage().readSecureData(AppConstants.accessTokenKey);
    //
    // if (kDebugMode) {
    //   if (isNotNullOrEmpty(url)) {
    //     print('URL: $url');
    //     // log('TOKEN: $token');
    //   }
    // }

    return Options(
      headers: {
        'Authorization': token,
        if (contentType != null) 'Content-Type': contentType,
        if (accept != null) 'Accept': accept,
      },
    );
  }

  Future<bool> isExpiredToken() async {
    _authProvider ??= AuthProvider();
    return !(await _authProvider?.checkAuthenticationStatus() ?? false);
  }
}
