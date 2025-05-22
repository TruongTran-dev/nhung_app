import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:either_dart/either.dart';
import 'package:expensive_management/data/api/api_path.dart';
import 'package:expensive_management/src/core/utils/app_utils.dart';
import 'package:expensive_management/src/shared/utils/async_job_retrier.dart';
import 'package:expensive_management/src/shared/utils/network_info.dart';
import 'package:flutter/foundation.dart';

class Failure {
  final String message;
  final int? statusCode;

  Failure(this.message, {this.statusCode});
}

class DioProvider {
  final Dio _dio;
  static const int _maxRetries = 3;
  static const int _retryDelayMs = 1000;

  // Singleton pattern

  DioProvider() : _dio = Dio() {
    // Initialize Dio with default options
    _dio.options = _createBaseOptions();

    _dio.interceptors.addAll([
      _createAuthInterceptor(),
      _createLoggingInterceptor(),
      _createRetryInterceptor(),
    ]);

    // Configure HTTP client to allow localhost connections
    // ignore: no_leading_underscores_for_local_identifiers
    final _clientAdapter = _dio.httpClientAdapter as IOHttpClientAdapter;
    _clientAdapter.createHttpClient = () {
      final client = HttpClient()..badCertificateCallback = (cert, host, port) => true;

      // Allow connections to localhost/127.0.0.1
      client.findProxy = (uri) {
        return 'DIRECT';
      };

      return client;
    };
  }

  BaseOptions _createBaseOptions() => BaseOptions(
        baseUrl: ApiPath.apiDomain,
        connectTimeout: Duration(seconds: 5),
        receiveTimeout: Duration(seconds: 5),
        sendTimeout: Duration(seconds: 5),
        validateStatus: (status) => status != null && status < 501,
      );

  InterceptorsWrapper _createAuthInterceptor() => InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            options.headers.addAll(_createAuthHeaders());
            handler.next(options);
          } catch (e) {
            AppUtils.logout();
            handler.reject(DioException(
              requestOptions: options,
              error: 'Authentication failed',
            ));
          }
        },
      );

  Map<String, String> _createAuthHeaders() => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  InterceptorsWrapper _createLoggingInterceptor() => InterceptorsWrapper(
        onRequest: (options, handler) => handler.next(options),
        onResponse: (response, handler) => handler.next(response),
        onError: (e, handler) => handler.next(e),
      );

  InterceptorsWrapper _createRetryInterceptor() => InterceptorsWrapper(
        onError: (e, handler) {
          if (e.response != null && e.response?.statusCode != null && e.response!.statusCode! >= 500) {
            if (e.requestOptions is Response) {
              handler.resolve(e.requestOptions as Response);
            }
            return;
          }
          handler.next(e);
        },
      );

  // Check internet connection
  Future<bool> _hasInternetConnection() async {
    final isNotConnected = await NetworkInfo().isNotConnected;
    if (isNotConnected) {
      return false;
    }

    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  // Set auth token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Log request and response details
  void _logRequest(String method, String path, dynamic data, Map<String, dynamic>? queryParameters) {
    if (kDebugMode) {
      log('📡 REQUEST [$method] $path - data: $data - param: $queryParameters');
    }
  }

  void _logResponse(Response response) {
    if (kDebugMode) {
      log('✅ RESPONSE [${response.statusCode}] ${response.requestOptions.path} - data: ${response.data}');
    }
  }

  void _logError(String method, String path, dynamic error) {
    if (kDebugMode && error is DioException) {
      log('❌ ERROR [$method] $path: code: ${error.response?.statusCode} - ${error.message}');
      if (error.response?.data != null) {
        log('📊 Error Data: ${error.response?.data}');
      }
    } else {
      log('❌ ERROR [$method] $path: ${error.toString()}');
    }
  }

  // Generic GET request
  Future<Either<Failure, Response<T>>> get<T>(
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    if (!await _hasInternetConnection()) {
      return Left(Failure('No internet connection. Please check your network.'));
    }

    final AsyncJobRetrier<Either<Failure, Response<T>>> asyncJobRetrier = AsyncJobRetrier(
      asyncJob: () async {
        options ??= Options(headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        });
        _logRequest('GET', path, data, queryParameters);
        Response<T> response = await _dio.get(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
        );
        _logResponse(response);
        return _handlerServerResponse<T>(response);
      },
      retries: _maxRetries,
      delayCalculator: (retryCount) => Duration(milliseconds: _retryDelayMs * retryCount),
      buildError: (error) {
        _logError('GET', path, error);
        return Left(_handleError(error));
      },
    );
    return await asyncJobRetrier.execute();
  }

  // Generic POST request
  Future<Either<Failure, Response>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    if (!await _hasInternetConnection()) {
      return Left(Failure('No internet connection. Please check your network.'));
    }

    final AsyncJobRetrier<Either<Failure, Response>> asyncJobRetrier = AsyncJobRetrier(
        asyncJob: () async {
          options ??= Options(headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          });
          _logRequest('POST', path, data, queryParameters);
          Response response = await _dio.post(
            path,
            data: data,
            queryParameters: queryParameters,
            options: options,
          );
          _logResponse(response);
          return _handlerServerResponse(response);
        },
        retries: _maxRetries,
        delayCalculator: (retryCount) => Duration(milliseconds: _retryDelayMs * retryCount),
        buildError: (error) {
          _logError('POST', path, error);
          return Left(_handleError(error));
        });
    return await asyncJobRetrier.execute();
  }

  // Generic PUT request
  Future<Either<Failure, Response>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    if (!await _hasInternetConnection()) {
      return Left(Failure('No internet connection. Please check your network.'));
    }

    final AsyncJobRetrier<Either<Failure, Response>> asyncJobRetrier = AsyncJobRetrier(
      asyncJob: () async {
        options ??= Options(headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        });
        _logRequest('PUT', path, data, queryParameters);
        Response response = await _dio.put(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
        );
        _logResponse(response);
        return _handlerServerResponse(response);
      },
      retries: _maxRetries,
      delayCalculator: (retryCount) => Duration(milliseconds: _retryDelayMs * retryCount),
      buildError: (error) {
        _logError('PUT', path, error);
        return Left(_handleError(error));
      },
    );
    return await asyncJobRetrier.execute();
  }

  // Generic DELETE request
  Future<Either<Failure, Response>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    if (!await _hasInternetConnection()) {
      return Left(Failure('No internet connection. Please check your network.'));
    }

    final AsyncJobRetrier<Either<Failure, Response>> asyncJobRetrier = AsyncJobRetrier(
      asyncJob: () async {
        options ??= Options(headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        });
        _logRequest('DELETE', path, data, queryParameters);
        Response response = await _dio.delete(
          path,
          data: data,
          queryParameters: queryParameters,
          options: options,
        );
        _logResponse(response);
        return _handlerServerResponse(response);
      },
      retries: _maxRetries,
      delayCalculator: (retryCount) => Duration(milliseconds: _retryDelayMs * retryCount),
      buildError: (error) {
        _logError('DELETE', path, error);
        return Left(_handleError(error));
      },
    );
    return await asyncJobRetrier.execute();
  }

  // Error handling
  Failure _handleError(dynamic error) {
    if (error is DioException) {
      return _handlerDioError(error);
    } else {
      return Failure('Unknown error. Please try again.');
    }
  }

  Failure _handlerDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return Failure('Connection timed out. Please try again.');
      case DioExceptionType.sendTimeout:
        return Failure('Request timed out. Please try again.');
      case DioExceptionType.receiveTimeout:
        return Failure('Response timed out. Please try again.');
      case DioExceptionType.badCertificate:
        return Failure('Bad certificate. Please try again.');
      case DioExceptionType.badResponse:
        final response = e.response;
        if (response?.statusCode != null && response?.data != null) {
          final statusCode = response!.statusCode!;
          final data = response.data;
          if (data is Map) {
            // Handle nested errors array structure
            if (data.containsKey('errors') && data['errors'] is List && (data['errors'] as List).isNotEmpty) {
              final firstError = (data['errors'] as List).first;
              if (firstError is Map) {
                return ServerError(
                  key: firstError['errorCode']?.toString() ?? '',
                  message: firstError['errorMessage']?.toString() ?? '',
                  statusCode: statusCode,
                );
              }
            }
            // Maintain backward compatibility with the original format
            else if (data.containsKey('errorMessage')) {
              return ServerError(
                key: data['errorCode']?.toString() ?? '',
                message: data['errorMessage']?.toString() ?? '',
                statusCode: statusCode,
              );
            }
          }
        }
        return Failure('Server error. Please try again.');
      case DioExceptionType.cancel:
        return Failure('Request cancelled. Please try again.');
      case DioExceptionType.connectionError:
        return Failure('No internet connection. Please check your network.');
      case DioExceptionType.unknown:
        return Failure('Unknown error. Please try again.');
    }
  }

  Either<Failure, Response<T>> _handlerServerResponse<T>(Response<T> response) {
    final int? statusCode = response.statusCode;

    // Success cases
    if (statusCode == 200 || statusCode == 201 || statusCode == 202) {
      return Right(response);
    }

    // Error cases
    if (response.data is Map) {
      final data = response.data as Map;
      if (data.containsKey('errorMessage')) {
        return Left(ServerError(
          key: data['errorCode']?.toString() ?? '',
          message: data['errorMessage']?.toString() ?? '',
          statusCode: statusCode,
        ));
      }
    }

    // Default error case
    return Left(Failure('Unknown error. Please try again.', statusCode: statusCode));
  }
}

class ServerError extends Failure {
  final String key;

  ServerError({
    required this.key,
    required String message,
    int? statusCode,
  }) : super(message, statusCode: statusCode);
}
