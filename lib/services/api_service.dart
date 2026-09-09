import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'storage_service.dart';

class ApiService {
  static ApiService? _instance;
  late final Dio _dio;

  // Callback untuk auto-logout saat 401
  static Function()? onUnauthorized;

  ApiService._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await StorageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            onUnauthorized?.call();
          }
          return handler.next(error);
        },
      ),
    );
  }

  static ApiService get instance {
    _instance ??= ApiService._();
    return _instance!;
  }

  Dio get dio => _dio;

  // Helper method untuk post multipart
  Future<Response> postMultipart(
    String path,
    FormData formData, {
    ProgressCallback? onSendProgress,
  }) async {
    return await _dio.post(
      path,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
      onSendProgress: onSendProgress,
    );
  }
}
