import 'package:dio/dio.dart';

import 'radio_browser_hosts.dart';

class HostFailoverInterceptor extends Interceptor {
  HostFailoverInterceptor(this._dio);

  final Dio _dio;

  static const String _attemptKey = 'hostAttempt';

  bool _isConnectionIssue(DioExceptionType type) =>
      type == DioExceptionType.connectionError ||
      type == DioExceptionType.connectionTimeout ||
      type == DioExceptionType.receiveTimeout ||
      type == DioExceptionType.sendTimeout;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final attempt = (err.requestOptions.extra[_attemptKey] as int?) ?? 0;
    if (!_isConnectionIssue(err.type) ||
        attempt >= RadioBrowserHosts.mirrors.length - 1) {
      handler.next(err);
      return;
    }

    final nextHost = RadioBrowserHosts.nextAfter(_dio.options.baseUrl);
    _dio.options.baseUrl = nextHost;

    final options = err.requestOptions
      ..baseUrl = nextHost
      ..extra[_attemptKey] = attempt + 1;

    try {
      final response = await _dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }
}
