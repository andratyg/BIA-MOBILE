import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final Dio _dio = ApiService.instance.dio;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConfig.login,
        data: {'email': email, 'password': password},
      );
      final data = response.data;
      final token = data['access_token'] as String?;
      if (token != null) {
        await StorageService.saveToken(token);
        final userName = data['user']?['name'] as String?;
        if (userName != null) {
          await StorageService.saveUserName(userName);
        }
      }
      return data;
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Gagal login. Coba lagi.';
      throw Exception(message);
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
      final data = response.data;
      final token = data['access_token'] as String?;
      if (token != null) {
        await StorageService.saveToken(token);
        await StorageService.saveUserName(name);
      }
      return data;
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ??
          (e.response?.data?['errors'] != null
              ? (e.response!.data['errors'] as Map).values.first[0]
              : 'Gagal registrasi. Coba lagi.');
      throw Exception(msg);
    }
  }

  Future<String?> getUserName() async {
    try {
      final response = await _dio.get(ApiConfig.getUserName);
      return response.data['name'] as String?;
    } on DioException {
      return await StorageService.getUserName();
    }
  }

  Future<void> logout() async {
    await StorageService.clearAll();
  }
}
