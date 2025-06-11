import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/message.dart';
import '../models/api_response.dart';
import './auth_provider.dart';

class ChatProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _errorMessage;
  List<Message> _messages = [];
  int? _currentConsultationId;
  final AuthProvider _authProvider;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ChatProvider(this._authProvider);

  Future<void> _setLoading(bool value) async {
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> loadMessagesForConsultation(int consultationId) async {
    _currentConsultationId = consultationId;
    _setLoading(true);
    _setErrorMessage(null);
    try {
      if (_authProvider.user == null) {
        _setErrorMessage('المستخدم غير مسجل الدخول.');
        _setLoading(false);
        return;
      }

      String endpoint;
      if (_authProvider.user!.role == 'patient') {
        endpoint = '/patient/consultations/$consultationId/messages';
      } else if (_authProvider.user!.role == 'doctor') {
        endpoint = '/doctor/consultations/$consultationId/messages';
      } else {
        _setErrorMessage('دور المستخدم غير مصرح به.');
        _setLoading(false);
        return;
      }

      final response = await _apiService.get(endpoint);

      if (response.statusCode == 200) {
        _messages = (json.decode(response.body) as List<dynamic>)
            .map((e) => Message.fromMap(e as Map<String, dynamic>))
            .toList();
        _messages.sort((a, b) => a.sentAt.compareTo(b.sentAt));
      } else {
        _setErrorMessage(ApiResponse.fromMap(json.decode(response.body)).message);
      }
    } catch (e) {
      _setErrorMessage('Failed to load messages: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendMessage(String messageContent, {String? attachmentUrl, String? attachmentType}) async {
    if (_currentConsultationId == null) {
      _setErrorMessage('لا توجد استشارة حالية لإرسال رسالة.');
      return false;
    }
    if (_authProvider.user == null) {
      _setErrorMessage('المستخدم غير مسجل الدخول.');
      return false;
    }

    _setLoading(true);
    _setErrorMessage(null);
    try {
      String endpoint;
      if (_authProvider.user!.role == 'patient') {
        endpoint = '/patient/consultations/$_currentConsultationId/messages';
      } else if (_authProvider.user!.role == 'doctor') {
        endpoint = '/doctor/consultations/$_currentConsultationId/messages';
      } else {
        _setErrorMessage('دور المستخدم غير مصرح به لإرسال رسالة.');
        _setLoading(false);
        return false;
      }

      final response = await _apiService.post(endpoint, {
        'message_content': messageContent,
        'attachment_url': attachmentUrl,
        'attachment_type': attachmentType,
      });

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseBody = json.decode(response.body) as Map<String, dynamic>;
        
        // >>> التعديل هنا: التحقق من وجود 'data' أولاً، ثم 'message_data' <<<
        final Map<String, dynamic>? messageDataMap;
        if (responseBody.containsKey('data')) {
            messageDataMap = responseBody['data'] as Map<String, dynamic>?;
        } else if (responseBody.containsKey('message_data')) {
            messageDataMap = responseBody['message_data'] as Map<String, dynamic>?;
        } else {
            messageDataMap = null; // لم يتم العثور على المفتاح المتوقع
        }

        if (messageDataMap != null) {
            _messages.add(Message.fromMap(messageDataMap));
            _messages.sort((a, b) => a.sentAt.compareTo(b.sentAt));
            _setLoading(false);
            notifyListeners();
            return true;
        } else {
            _setErrorMessage('Received invalid message data from API (missing "data" or "message_data" key).');
            _setLoading(false);
            return false;
        }
      } else {
        final apiResponse = ApiResponse.fromMap(json.decode(response.body) as Map<String, dynamic>);
        _setErrorMessage(apiResponse.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setErrorMessage('Failed to send message: $e');
      _setLoading(false);
      return false;
    }
  }

  void clearMessages() {
    _messages = [];
    _currentConsultationId = null;
    notifyListeners();
  }
}