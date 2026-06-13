import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../services/api_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _service = AuthService();
  UserModel? user;
  bool isLoading = false;
  String? errorMessage;
  String? errorType; // State to distinguish error types (connection, auth, validation)

  Future<void> updateServerUrl(String url) async {
    await ServerSettings.setBaseUrl(url);
    notifyListeners();
  }

  Future<bool> loginMockSocial(String provider) async {
    isLoading = true;
    errorMessage = null;
    errorType = null;
    notifyListeners();
    final result = await _service.loginMockSocial(provider);
    isLoading = false;
    if (result['success'] == true) {
      user = result['user'] as UserModel?;
      notifyListeners();
      return true;
    } else {
      errorMessage = result['message'] as String? ?? 'Login gagal';
      errorType = result['error_type'] as String?;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    isLoading = true;
    errorMessage = null;
    errorType = null;
    notifyListeners();
    final result = await _service.loginWithGoogle();
    isLoading = false;
    if (result['success'] == true) {
      user = result['user'] as UserModel?;
      notifyListeners();
      return true;
    } else {
      errorMessage = result['message'] as String? ?? 'Login Google gagal';
      errorType = result['error_type'] as String?;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithFacebook() async {
    isLoading = true;
    errorMessage = null;
    errorType = null;
    notifyListeners();
    final result = await _service.loginWithFacebook();
    isLoading = false;
    if (result['success'] == true) {
      user = result['user'] as UserModel?;
      notifyListeners();
      return true;
    } else {
      errorMessage = result['message'] as String? ?? 'Login Facebook gagal';
      errorType = result['error_type'] as String?;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    errorType = null;
    notifyListeners();
    final result = await _service.login(email, password);
    isLoading = false;
    if (result['success'] == true) {
      user = result['user'] as UserModel?;
      notifyListeners();
      return true;
    } else {
      errorMessage = result['message'] as String? ?? 'Login gagal';
      errorType = result['error_type'] as String?;
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>> register({
    required String nama,
    required String email,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    errorType = null;
    notifyListeners();
    final result = await _service.register(
      nama: nama,
      email: email,
      password: password,
    );
    isLoading = false;
    if (result['success'] == false) {
      errorMessage = result['message'] as String? ?? 'Registrasi gagal';
      errorType = result['error_type'] as String?;
    }
    notifyListeners();
    return result;
  }

  Future<void> logout() async {
    await _service.logout();
    user = null;
    notifyListeners();
  }

  Future<void> loadUser() async {
    user = await _service.getUser();
    notifyListeners();
  }
}