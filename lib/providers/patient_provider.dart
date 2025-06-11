import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/appointment.dart';
import '../models/consultation.dart';
import '../models/prescription.dart';
import '../models/public_question.dart';
import '../models/pagination.dart';
import '../models/api_response.dart';
// import '../config/config.dart';

class PatientProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _errorMessage;

  PaginatedResponse<Appointment>? _appointments;
  PaginatedResponse<Consultation>? _consultations;
  PaginatedResponse<Prescription>? _prescriptions;
  PaginatedResponse<PublicQuestion>? _publicQuestions; // For questions posted by current patient

  PaginatedResponse<Appointment>? get appointments => _appointments;
  PaginatedResponse<Consultation>? get consultations => _consultations;
  PaginatedResponse<Prescription>? get prescriptions => _prescriptions;
  PaginatedResponse<PublicQuestion>? get publicQuestions => _publicQuestions;
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

  Future<void> fetchAppointments({int page = 1, int perPage = 10}) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final response = await _apiService.get(
        '/patient/appointments',
        queryParams: {'page': page.toString(), 'per_page': perPage.toString()},
      );
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        // التعامل مع استجابة قد تكون قائمة مباشرة أو Paginated
        if (responseData is List) {
          _appointments = PaginatedResponse(
            data: responseData.map((e) => Appointment.fromMap(e as Map<String, dynamic>)).toList(),
            links: PaginationLinks(), // روابط فارغة أو افتراضية
            meta: PaginationMeta(
              currentPage: page,
              from: (page - 1) * perPage + 1,
              lastPage: 1, // لا يمكن تحديدها بدقة بدون بيانات meta
              links: [],
              path: '/patient/appointments',
              perPage: perPage,
              to: (page - 1) * perPage + responseData.length,
              total: responseData.length, // إجمالي العناصر في هذه القائمة فقط
            ),
          );
        } else if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          _appointments = PaginatedResponse.fromMap(
            responseData,
            (map) => Appointment.fromMap(map),
          );
        } else {
          _setErrorMessage('Received unexpected data format for patient appointments.');
        }
      } else {
        _setErrorMessage(ApiResponse.fromMap(json.decode(response.body)).message);
      }
    } catch (e) {
      _setErrorMessage('Failed to load appointments: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> bookAppointment(int doctorId, DateTime datetime, int duration, String? notes) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final response = await _apiService.post('/patient/appointments', {
        'doctor_id': doctorId,
        'appointment_datetime': datetime.toIso8601String(),
        'duration_minutes': duration,
        'patient_notes': notes,
      });
      if (response.statusCode == 201) {
        await fetchAppointments(); // Refresh the list
        _setLoading(false);
        return true;
      } else {
        final apiResponse = ApiResponse.fromMap(json.decode(response.body) as Map<String, dynamic>);
        _setErrorMessage(apiResponse.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setErrorMessage('Failed to book appointment: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> cancelAppointment(int appointmentId) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final response = await _apiService.put('/patient/appointments/$appointmentId/cancel', {});
      if (response.statusCode == 200) {
        await fetchAppointments(); // Refresh the list
        _setLoading(false);
        return true;
      } else {
        final apiResponse = ApiResponse.fromMap(json.decode(response.body) as Map<String, dynamic>);
        _setErrorMessage(apiResponse.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setErrorMessage('Failed to cancel appointment: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<void> fetchConsultations({int page = 1, int perPage = 10}) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final response = await _apiService.get(
        '/patient/consultations',
        queryParams: {'page': page.toString(), 'per_page': perPage.toString()},
      );
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        // >>> التعديل هنا <<<
        if (responseData is List) {
          _consultations = PaginatedResponse(
            data: responseData.map((e) => Consultation.fromMap(e as Map<String, dynamic>)).toList(),
            links: PaginationLinks(),
            meta: PaginationMeta(
              currentPage: page,
              from: (page - 1) * perPage + 1,
              lastPage: 1,
              links: [],
              path: '/patient/consultations',
              perPage: perPage,
              to: (page - 1) * perPage + responseData.length,
              total: responseData.length,
            ),
          );
        } else if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          _consultations = PaginatedResponse.fromMap(
            responseData,
            (map) => Consultation.fromMap(map),
          );
        } else {
          _setErrorMessage('Received unexpected data format for patient consultations.');
        }
      } else {
        _setErrorMessage(ApiResponse.fromMap(json.decode(response.body)).message);
      }
    } catch (e) {
      _setErrorMessage('Failed to load consultations: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> requestConsultation(int doctorUserId) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final response = await _apiService.post('/patient/consultations', {
        'doctor_user_id': doctorUserId,
      });
      if (response.statusCode == 201) {
        await fetchConsultations(); // Refresh the list
        _setLoading(false);
        return true;
      } else {
        final apiResponse = ApiResponse.fromMap(json.decode(response.body) as Map<String, dynamic>);
        _setErrorMessage(apiResponse.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setErrorMessage('Failed to request consultation: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<void> fetchPrescriptions({int page = 1, int perPage = 10}) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final response = await _apiService.get(
        '/patient/prescriptions',
        queryParams: {'page': page.toString(), 'per_page': perPage.toString()},
      );
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        // >>> التعديل هنا <<<
        if (responseData is List) {
          _prescriptions = PaginatedResponse(
            data: responseData.map((e) => Prescription.fromMap(e as Map<String, dynamic>)).toList(),
            links: PaginationLinks(),
            meta: PaginationMeta(
              currentPage: page,
              from: (page - 1) * perPage + 1,
              lastPage: 1,
              links: [],
              path: '/patient/prescriptions',
              perPage: perPage,
              to: (page - 1) * perPage + responseData.length,
              total: responseData.length,
            ),
          );
        } else if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          _prescriptions = PaginatedResponse.fromMap(
            responseData,
            (map) => Prescription.fromMap(map),
          );
        } else {
          _setErrorMessage('Received unexpected data format for patient prescriptions.');
        }
      } else {
        _setErrorMessage(ApiResponse.fromMap(json.decode(response.body)).message);
      }
    } catch (e) {
      _setErrorMessage('Failed to load prescriptions: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchPublicQuestions({int page = 1, int perPage = 10}) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final response = await _apiService.get(
        '/public-questions', // Public endpoint for all users, but patient can post
        queryParams: {'page': page.toString(), 'per_page': perPage.toString()},
      );
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        // >>> التعديل هنا <<<
        if (responseData is List) {
          _publicQuestions = PaginatedResponse(
            data: responseData.map((e) => PublicQuestion.fromMap(e as Map<String, dynamic>)).toList(),
            links: PaginationLinks(),
            meta: PaginationMeta(
              currentPage: page,
              from: (page - 1) * perPage + 1,
              lastPage: 1,
              links: [],
              path: '/public-questions',
              perPage: perPage,
              to: (page - 1) * perPage + responseData.length,
              total: responseData.length,
            ),
          );
        } else if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          _publicQuestions = PaginatedResponse.fromMap(
            responseData,
            (map) => PublicQuestion.fromMap(map),
          );
        } else {
          _setErrorMessage('Received unexpected data format for public questions.');
        }
      } else {
        _setErrorMessage(ApiResponse.fromMap(json.decode(response.body)).message);
      }
    } catch (e) {
      _setErrorMessage('Failed to load public questions: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> postPublicQuestion(String title, String details) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final response = await _apiService.post('/patient/public-questions', {
        'title': title,
        'details': details,
      });
      if (response.statusCode == 201) {
        await fetchPublicQuestions(); // Refresh the list
        _setLoading(false);
        return true;
      } else {
        final apiResponse = ApiResponse.fromMap(json.decode(response.body) as Map<String, dynamic>);
        _setErrorMessage(apiResponse.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setErrorMessage('Failed to post public question: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> initiatePayment(Map<String, dynamic> paymentData) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final response = await _apiService.post('/patient/payments/initiate', paymentData);
      if (response.statusCode == 201) {
        _setLoading(false);
        return true;
      } else {
        final apiResponse = ApiResponse.fromMap(json.decode(response.body) as Map<String, dynamic>);
        _setErrorMessage(apiResponse.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setErrorMessage('Failed to initiate payment: $e');
      _setLoading(false);
      return false;
    }
  }
}