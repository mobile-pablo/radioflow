import 'package:dio/dio.dart';

import 'host_failover_interceptor.dart';
import 'logging_interceptor.dart';
import 'radio_browser_hosts.dart';

Dio createRadioBrowserDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: RadioBrowserHosts.random(),
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 20),
      responseType: ResponseType.json,
      headers: const {'User-Agent': RadioBrowserHosts.userAgent},
    ),
  );
  dio.interceptors.addAll([
    HostFailoverInterceptor(dio),
    const LoggingInterceptor(),
  ]);
  return dio;
}
