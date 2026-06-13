import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../main.dart';

class ServerSettings {
  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('server_url') ?? AppConstants.baseUrl;
  }

  static Future<void> setBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_url', url);
  }
}

class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    ),
  );

  static bool _interceptorAdded = false;
  static int _retryCount = 0;

  static void clearAuthHeader() {
    _dio.options.headers.remove('Authorization');
  }

  static void _setupInterceptors() {
    if (_interceptorAdded) return;
    _interceptorAdded = true;

    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) async {
        // 1. Retry Logic (Max 2 retries) on connection problems
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.connectionError) {
          if (_retryCount < 2) {
            _retryCount++;
            try {
              final options = error.requestOptions;
              final response = await _dio.request(
                options.path,
                data: options.data,
                queryParameters: options.queryParameters,
                options: Options(
                  method: options.method,
                  headers: options.headers,
                ),
              );
              _retryCount = 0; // Reset count on success
              return handler.resolve(response);
            } catch (_) {
              // Let it proceed to the next handler if retry fails
            }
          }
        }
        _retryCount = 0; // Reset count on non-network/timeout failures

        // 2. Token Expired (401 Unauthorized) -> Auto Logout & Redirect
        if (error.response?.statusCode == 401) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove(AppConstants.tokenKey);
          await prefs.remove(AppConstants.userKey);
          clearAuthHeader();
          
          // Safely redirect to Login Screen using global key
          UmkmartApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/login',
            (route) => false,
          );
        }

        return handler.next(error);
      },
    ));
  }

  static Future<Dio> getClient() async {
    _setupInterceptors();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }

    // Set dynamic base URL from SharedPreferences ServerSettings
    final dynamicUrl = await ServerSettings.getBaseUrl();
    _dio.options.baseUrl = dynamicUrl;

    return _dio;
  }
}