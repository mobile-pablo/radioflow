import 'package:dio/dio.dart';
import 'package:domain/domain.dart';

Failure mapDioException(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionError:
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
      return const NetworkFailure();
    case DioExceptionType.badResponse:
      return error.response?.statusCode == 404
          ? const NotFoundFailure()
          : const ServerFailure();
    case DioExceptionType.cancel:
    case DioExceptionType.badCertificate:
    case DioExceptionType.unknown:
      return const ServerFailure();
  }
}
