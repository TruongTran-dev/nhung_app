import 'dart:io';

import 'package:dio/dio.dart';
import 'package:expensive_management/data/api/api_path.dart';
import 'package:expensive_management/utils/app_constants.dart';
import 'package:expensive_management/utils/secure_storage.dart';
import '../response/base_response.dart';
import 'provider_mixin.dart';

class ExportProvider with ProviderMixin {
  Future<Object> getFileReport({required Map<String, dynamic> query, required String savePath}) async {
    if (await isExpiredToken()) {
      return ExpiredTokenResponse();
    }
    try {
      final response = await dio.get(
        ApiPath.exportData,
        queryParameters: query,
        options: Options(
          headers: {
            'Authorization': await SecureStorage().readSecureData(AppConstants.accessTokenKey),
          },
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );

      final file = File(savePath);

      await file.writeAsBytes(response.data, flush: true);

      return file;
    } catch (error, stacktrace) {
      return errorGetResponse(error, stacktrace, ApiPath.exportData);
    }
  }
}
