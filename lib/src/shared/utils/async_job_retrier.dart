import 'dart:ui';

import 'package:expensive_management/src/core/common/dio_provider.dart';

/// Created by: 7-Productions
/// - Author: hieubh
/// - Contact: hieuitdevs@gmail.com
/// - Description: Async job retrier for the application.
class AsyncJobRetrier<T> {
  final Future<T> Function() asyncJob;
  final int retries;
  final Duration Function(int attempt) delayCalculator;
  final bool Function(dynamic error)? shouldRetry;
  final T Function(dynamic error)? buildError;
  final VoidCallback? onFinally;
  AsyncJobRetrier({
    required this.asyncJob,
    this.retries = 3,
    Duration Function(int attempt)? delayCalculator,
    this.shouldRetry,
    this.buildError,
    this.onFinally,
  }) : delayCalculator = delayCalculator ?? ((attempt) => Duration(seconds: 2 * attempt));

  Future<T> execute() async {
    int attempt = 0;
    while (attempt < retries) {
      try {
        final result = await asyncJob();
        onFinally?.call();
        return result;
      } catch (error) {
        attempt++;
        if (attempt >= retries || (shouldRetry != null && !shouldRetry!(error))) {
          if (buildError != null) {
            onFinally?.call();
            return buildError!(error);
          }
          rethrow;
        }
        await Future.delayed(delayCalculator(attempt));
      }
    }
    if (buildError != null) {
      onFinally?.call();
      return buildError!(UnknownError('Failed to complete the async job after $retries attempts'));
    }
    onFinally?.call();
    throw UnknownError('Failed to complete the async job after $retries attempts');
  }
}

class UnknownError extends Failure {
  UnknownError(super.message);
}
