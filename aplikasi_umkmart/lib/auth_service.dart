import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'api_service.dart';
import '../utils/constants.dart';
import '../models/models.dart';

class AuthService {
  Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: '818664854372-u4nfb9fse9vk8sc4b007hhvvo0i7atm6.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );
      
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return {
          'success': false, 
          'message': 'Login Google dibatalkan oleh pengguna.',
          'error_type': 'canceled'
        };
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      if (idToken == null) {
        return {
          'success': false, 
          'message': 'Gagal mengambil ID Token dari Google. Silakan coba lagi.',
          'error_type': 'token_error'
        };
      }

      final dio = await ApiService.getClient();
      final response = await dio.post('/auth/google', data: {
        'id_token': idToken,
      });

      final data = response.data;
      String? token;
      Map<String, dynamic>? userData;

      if (data is Map<String, dynamic>) {
        token = data['token'] as String? ??
            data['access_token'] as String? ??
            data['data']?['token'] as String? ??
            data['data']?['access_token'] as String?;

        final rawUser = data['user'] ??
            data['data']?['user'] ??
            data['data'];

        if (rawUser is Map<String, dynamic>) {
          userData = rawUser;
        }
      }

      if (token == null || userData == null) {
        // Fallback for seamless local user experience if backend succeeds but structure is non-standard
        return {
          'success': false, 
          'message': 'Gagal memproses otentikasi akun di server UMKMart.',
          'error_type': 'server_error'
        };
      }

      final user = UserModel.fromJson(userData);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.tokenKey, token);
      await prefs.setString(AppConstants.userKey, jsonEncode(userData));
      return {'success': true, 'user': user};
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return {
          'success': false,
          'message': 'Tidak ada koneksi internet. Pastikan server aktif dan HP berada di jaringan WiFi yang sama.',
          'error_type': 'connection'
        };
      }
      return {
        'success': false,
        'message': 'Gagal memproses login Google di server UMKMart.',
        'error_type': 'server_error'
      };
    } catch (e) {
      final errStr = e.toString();
      if (errStr.contains('sign_in_canceled')) {
        return {
          'success': false,
          'message': 'Login Google dibatalkan oleh pengguna.',
          'error_type': 'canceled'
        };
      } else if (errStr.contains('network_error')) {
        return {
          'success': false,
          'message': 'Tidak ada koneksi internet. Silakan periksa koneksi Anda.',
          'error_type': 'connection'
        };
      } else if (errStr.contains('sign_in_failed') || errStr.contains('10:') || errStr.contains('DEVELOPER_ERROR')) {
        return {
          'success': false,
          'message': 'Login Google belum tersedia. Silakan hubungi administrator.',
          'error_type': 'config_error'
        };
      }
      return {
        'success': false,
        'message': 'Gagal menghubungkan ke akun Google. Silakan coba lagi.',
        'error_type': 'unknown'
      };
    }
  }

  Future<Map<String, dynamic>> loginWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['public_profile', 'email'],
      );
      
      if (result.status == LoginStatus.cancelled) {
        return {
          'success': false, 
          'message': 'Login Facebook dibatalkan oleh pengguna.',
          'error_type': 'canceled'
        };
      }
      
      if (result.status != LoginStatus.success) {
        return {
          'success': false, 
          'message': 'Gagal masuk lewat Facebook: ${result.message}',
          'error_type': 'facebook_error'
        };
      }

      final String? accessToken = result.accessToken?.tokenString;
      if (accessToken == null) {
        return {
          'success': false, 
          'message': 'Gagal mengambil Access Token dari Facebook.',
          'error_type': 'token_error'
        };
      }

      final dio = await ApiService.getClient();
      final response = await dio.post('/auth/facebook', data: {
        'access_token': accessToken,
      });

      final data = response.data;
      String? token;
      Map<String, dynamic>? userData;

      if (data is Map<String, dynamic>) {
        token = data['token'] as String? ??
            data['access_token'] as String? ??
            data['data']?['token'] as String? ??
            data['data']?['access_token'] as String?;

        final rawUser = data['user'] ??
            data['data']?['user'] ??
            data['data'];

        if (rawUser is Map<String, dynamic>) {
          userData = rawUser;
        }
      }

      if (token == null || userData == null) {
        return {
          'success': false, 
          'message': 'Gagal memproses otentikasi akun di server UMKMart.',
          'error_type': 'server_error'
        };
      }

      final user = UserModel.fromJson(userData);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.tokenKey, token);
      await prefs.setString(AppConstants.userKey, jsonEncode(userData));
      return {'success': true, 'user': user};
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return {
          'success': false,
          'message': 'Tidak ada koneksi internet. Pastikan server aktif dan HP berada di jaringan WiFi yang sama.',
          'error_type': 'connection'
        };
      }
      return {
        'success': false,
        'message': 'Gagal memproses login Facebook di server UMKMart.',
        'error_type': 'server_error'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal login lewat Facebook. Silakan coba lagi.',
        'error_type': 'unknown'
      };
    }
  }

  Future<Map<String, dynamic>> loginMockSocial(String provider) async {
    try {
      await Future.delayed(const Duration(milliseconds: 1000));

      final userData = {
        'id': provider == 'google' ? 888 : 999,
        'nama': provider == 'google' ? 'Google Partner' : 'Facebook Partner',
        'email': '${provider}@umkmart.com',
        'role': 'kasir',
      };

      final user = UserModel.fromJson(userData);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.tokenKey, 'mock_${provider}_token_987654');
      await prefs.setString(AppConstants.userKey, jsonEncode(userData));

      return {'success': true, 'user': user};
    } catch (e) {
      return {'success': false, 'message': 'Social login failed: $e'};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // PENTING: Hapus token lama sebelum login baru
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.tokenKey);
      await prefs.remove(AppConstants.userKey);

      // Reset dio headers (hapus Authorization lama)
      ApiService.clearAuthHeader();

      final dio = await ApiService.getClient();
      final response = await dio.post('/login', data: {
        'email': email,
        'password': password,
      });

      final data = response.data;
      String? token;
      Map<String, dynamic>? userData;

      if (data is Map<String, dynamic>) {
        token = data['token'] as String? ??
            data['access_token'] as String? ??
            data['data']?['token'] as String? ??
            data['data']?['access_token'] as String?;

        final rawUser = data['user'] ??
            data['data']?['user'] ??
            data['data'];

        if (rawUser is Map<String, dynamic>) {
          userData = rawUser;
        }
      }

      if (token == null) {
        return {
          'success': false,
          'message': 'Token tidak ditemukan dalam respons server',
          'error_type': 'unknown'
        };
      }

      if (userData == null) {
        return {
          'success': false,
          'message': 'Data user tidak ditemukan dalam respons server',
          'error_type': 'unknown'
        };
      }

      final user = UserModel.fromJson(userData);
      await prefs.setString(AppConstants.tokenKey, token);
      await prefs.setString(AppConstants.userKey, jsonEncode(userData));
      return {'success': true, 'user': user};
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return {
          'success': false,
          'message': 'Tidak dapat terhubung ke server.\nPastikan server aktif dan HP berada di jaringan WiFi yang sama.',
          'error_type': 'connection'
        };
      } else if (e.response?.statusCode == 401) {
        return {
          'success': false,
          'message': 'Email atau password salah.',
          'error_type': 'auth'
        };
      } else if (e.response?.statusCode == 422) {
        return {
          'success': false,
          'message': 'Format email tidak valid.',
          'error_type': 'validation'
        };
      }
      return {
        'success': false,
        'message': 'Terjadi kesalahan. Silakan coba lagi.',
        'error_type': 'unknown'
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: $e',
        'error_type': 'unknown'
      };
    }
  }

  Future<Map<String, dynamic>> register({
    required String nama,
    required String email,
    required String password,
    String role = 'kasir',
  }) async {
    try {
      final dio = await ApiService.getClient();
      final response = await dio.post('/register', data: {
        'nama': nama,
        'email': email,
        'password': password,
        'role': role,
      });

      final data = response.data;
      String? message;
      if (data is Map<String, dynamic>) {
        message = data['message'] as String?;
      }

      return {
        'success': true,
        'message': message ?? 'Registrasi berhasil! Silakan login.',
      };
    } on DioException catch (e) {
      String message = 'Registrasi gagal';
      String errorType = 'unknown';

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        message = 'Tidak dapat terhubung ke server.\nPastikan server aktif dan HP berada di jaringan WiFi yang sama.';
        errorType = 'connection';
      } else if (e.response != null) {
        final data = e.response!.data;
        if (data is Map<String, dynamic>) {
          if (data['errors'] != null && data['errors'] is Map) {
            final errors = data['errors'] as Map;
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              message = firstError.first.toString();
            }
          } else {
            message = data['message'] as String? ?? 'Registrasi gagal';
          }
        }
        if (e.response!.statusCode == 422) {
          message = message.isNotEmpty ? message : 'Data tidak valid';
          errorType = 'validation';
        }
      }
      return {'success': false, 'message': message, 'error_type': errorType};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e', 'error_type': 'unknown'};
    }
  }

  Future<void> logout() async {
    try {
      final dio = await ApiService.getClient();
      await dio.post('/logout');
    } catch (_) {
      // Tetap bersihkan data lokal meski API gagal terhubung
    } finally {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.tokenKey);
      await prefs.remove(AppConstants.userKey);
      ApiService.clearAuthHeader();
    }
  }

  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(AppConstants.userKey);
    if (data == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(data));
    } catch (_) {
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey) != null;
  }
}