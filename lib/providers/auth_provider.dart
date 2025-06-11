import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../models/user.dart';
import '../models/api_response.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> _setLoading(bool value) async {
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final response = await _apiService.post(
          '/login',
          {
            'email': email,
            'password': password,
          },
          requiresAuth: false);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        _token = data['access_token'] as String;
        await _apiService.setToken(_token!);
        _user = User.fromMap(data['user'] as Map<String, dynamic>);
        _setLoading(false);
        print(data);
        return true;
      } else {
        final apiResponse = ApiResponse.fromMap(
            json.decode(response.body) as Map<String, dynamic>);
        _setErrorMessage(apiResponse.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setErrorMessage('An error occurred: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> register(Map<String, dynamic> userData) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final response =
          await _apiService.post('/register', userData, requiresAuth: false);

      if (response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        _token = data['access_token'] as String;
        await _apiService.setToken(_token!);
        _user = User.fromMap(data['user'] as Map<String, dynamic>);
        _setLoading(false);
        return true;
      } else {
        final apiResponse = ApiResponse.fromMap(
            json.decode(response.body) as Map<String, dynamic>);
        _setErrorMessage(apiResponse.message);
        if (apiResponse.errors != null) {
          apiResponse.errors!.forEach((key, value) {
            _setErrorMessage('$_errorMessage\n${value.join(", ")}');
          });
        }
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setErrorMessage('An error occurred: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _apiService.post('/logout', {}); // API will invalidate the token
      await _apiService.removeToken();
      _user = null;
      _token = null;
    } catch (e) {
      _setErrorMessage('Logout error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> checkAuthStatus() async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      _token = await _apiService.getToken();
      if (_token != null) {
        final response = await _apiService.get('/user');
        if (response.statusCode == 200) {
          final data = json.decode(response.body) as Map<String, dynamic>;
          _user = User.fromMap(data);
        } else {
          await _apiService.removeToken();
          _token = null;
          _user = null;
        }
      }
    } catch (e) {
      _setErrorMessage('Auth status check error: $e');
      await _apiService.removeToken();
      _token = null;
      _user = null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> userData) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final response = await _apiService.put('/user/profile', userData);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        _user = User.fromMap(data['user'] as Map<String, dynamic>);
        _setLoading(false);
        return true;
      } else {
        final apiResponse = ApiResponse.fromMap(
            json.decode(response.body) as Map<String, dynamic>);
        _setErrorMessage(apiResponse.message);
        if (apiResponse.errors != null) {
          apiResponse.errors!.forEach((key, value) {
            _setErrorMessage('$_errorMessage\n${value.join(", ")}');
          });
        }
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setErrorMessage('Profile update error: $e');
      _setLoading(false);
      return false;
    }
  }
}
