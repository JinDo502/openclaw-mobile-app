import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String code;
  final String message;
  final dynamic details;

  ApiException({required this.code, required this.message, this.details});

  @override
  String toString() => 'ApiException($code): $message';
}

class ApiClient {
  ApiClient({required this.baseUrl}) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
      ),
    );
  }

  final String baseUrl;
  late final Dio dio;

  Future<T> getOkData<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final res = await dio.get(path, queryParameters: queryParameters);
    final data = res.data;
    if (data is Map<String, dynamic>) {
      final ok = data['ok'];
      if (ok == true) return data['data'] as T;
      if (ok == false) {
        final err = (data['error'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
        throw ApiException(
          code: (err['code'] ?? 'UNKNOWN').toString(),
          message: (err['message'] ?? 'Unknown error').toString(),
          details: err['details'],
        );
      }
    }
    // For endpoints that don't wrap ok/data
    return data as T;
  }
}
