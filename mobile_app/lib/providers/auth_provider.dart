import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../services/api_client.dart';
import '../models/models.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated, loading }

class AuthProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  AuthStatus _status = AuthStatus.uninitialized;
  User? _currentUser;
  String? _errorMessage;

  AuthStatus get status => _status;
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;

  Future<void> initAuth() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final token = await _apiClient.getToken();
      if (token == null || token.isEmpty) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return;
      }

      final response = await _apiClient.dio.get('/auth/me');
      if (response.statusCode == 200) {
        _currentUser = User.fromJson(response.data);
        _status = AuthStatus.authenticated;
      } else {
        await _apiClient.clearToken();
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      await _apiClient.clearToken();
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.dio.post('/auth/login', data: {
        'email': email.trim(),
        'password': password,
      });

      if (response.statusCode == 200) {
        final token = response.data['access_token'];
        await _apiClient.saveToken(token);
        _currentUser = User(
          id: response.data['user_id'],
          messId: response.data['mess_id'],
          fullName: response.data['full_name'],
          email: response.data['email'],
          role: response.data['role'],
          isActive: true,
        );
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null && e.response?.data['detail'] != null) {
        _errorMessage = e.response?.data['detail'];
      } else {
        _errorMessage = "Network or server error. Please check backend connection.";
      }
    } catch (e) {
      _errorMessage = "An unexpected error occurred: ${e.toString()}";
    }

    _status = AuthStatus.unauthenticated;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    try {
      await _apiClient.dio.post('/auth/logout');
    } catch (_) {}
    await _apiClient.clearToken();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
