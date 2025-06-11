import 'dart:convert';
import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/env.dart'; // تأكد من المسار الصحيح

class ApiService {
  static const String _authTokenKey = 'authToken';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _authTokenKey);
  }

  Future<void> setToken(String token) async {
    await _secureStorage.write(key: _authTokenKey, value: token);
  }

  Future<void> removeToken() async {
    await _secureStorage.delete(key: _authTokenKey);
  }

  Future<Map<String, String>> _getHeaders({bool requiresAuth = true}) async {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (requiresAuth) {
      String? token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<http.Response> get(String endpoint, {Map<String, String>? queryParams, bool requiresAuth = true}) async {
    final uri = Uri.parse('${Env.apiUrl}$endpoint').replace(queryParameters: queryParams);
    print('GET Request to: $uri');
    final response = await http.get(uri, headers: await _getHeaders(requiresAuth: requiresAuth));
    _logResponse(response);
    return response;
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body, {bool requiresAuth = true}) async {
    final uri = Uri.parse('${Env.apiUrl}$endpoint');
    print('POST Request to: $uri with body: ${json.encode(body)}');
    final response = await http.post(uri, headers: await _getHeaders(requiresAuth: requiresAuth), body: json.encode(body));
    _logResponse(response);
    return response;
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> body, {bool requiresAuth = true}) async {
    final uri = Uri.parse('${Env.apiUrl}$endpoint');
    print('PUT Request to: $uri with body: ${json.encode(body)}');
    final response = await http.put(uri, headers: await _getHeaders(requiresAuth: requiresAuth), body: json.encode(body));
    _logResponse(response);
    return response;
  }

  Future<http.Response> delete(String endpoint, {bool requiresAuth = true}) async {
    final uri = Uri.parse('${Env.apiUrl}$endpoint');
    print('DELETE Request to: $uri');
    final response = await http.delete(uri, headers: await _getHeaders(requiresAuth: requiresAuth));
    _logResponse(response);
    return response;
  }

  void _logResponse(http.Response response) {
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');
  }
}
