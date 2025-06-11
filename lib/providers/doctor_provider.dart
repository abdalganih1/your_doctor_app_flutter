import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/doctor_profile.dart';
import '../models/doctor_availability.dart';
import '../models/appointment.dart';
import '../models/consultation.dart';
import '../models/public_question.dart';
import '../models/blog_post.dart';
import '../models/pagination.dart';
import '../models/api_response.dart';
// import '../config/config.dart';

class DoctorProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  String? _errorMessage;

  DoctorProfile? _doctorProfile;
  List<DoctorAvailability> _availability = [];
  PaginatedResponse<Appointment>? _appointments;
  PaginatedResponse<Consultation>? _consultations;
  PaginatedResponse<PublicQuestion>? _unansweredQuestions;
  PaginatedResponse<BlogPost>? _blogPosts;

  DoctorProfile? get doctorProfile => _doctorProfile;
  List<DoctorAvailability> get availability => _availability;
  PaginatedResponse<Appointment>? get appointments => _appointments;
  PaginatedResponse<Consultation>? get consultations => _consultations;
  PaginatedResponse<PublicQuestion>? get unansweredQuestions => _unansweredQuestions;
  PaginatedResponse<BlogPost>? get blogPosts => _blogPosts;
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

  Future<void> fetchDoctorProfile() async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final response = await _apiService.get('/doctor/profile');
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        if (responseData is List && responseData.isNotEmpty) {
          _doctorProfile = DoctorProfile.fromMap(responseData[0] as Map<String, dynamic>);
        } else if (responseData is Map<String, dynamic>) {
          _doctorProfile = DoctorProfile.fromMap(responseData);
        } else {
          _setErrorMessage('Received unexpected data format for doctor profile.');
        }
      } else {
        _setErrorMessage(ApiResponse.fromMap(json.decode(response.body)).message);
      }
    } catch (e) {
      _setErrorMessage('Failed to load doctor profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateDoctorProfile(Map<String, dynamic> profileData) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final response = await _apiService.put('/doctor/profile', profileData);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        _doctorProfile = DoctorProfile.fromMap(data['doctor_profile'] as Map<String, dynamic>);
        _setLoading(false);
        return true;
      } else {
        final apiResponse = ApiResponse.fromMap(json.decode(response.body) as Map<String, dynamic>);
        _setErrorMessage(apiResponse.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setErrorMessage('Failed to update doctor profile: $e');
      _setLoading(false);
      return false;
    }
  }
  
  Future<void> fetchDoctorAvailability() async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final response = await _apiService.get('/doctor/schedule/availability');
      if (response.statusCode == 200) {
        _availability = (json.decode(response.body) as List<dynamic>)
            .map((e) => DoctorAvailability.fromMap(e as Map<String, dynamic>))
            .toList();
      } else {
        _setErrorMessage(ApiResponse.fromMap(json.decode(response.body)).message);
      }
    } catch (e) {
      _setErrorMessage('Failed to load doctor availability: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateDoctorAvailability(List<Map<String, dynamic>> slots) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final response = await _apiService.put('/doctor/schedule/availability', {'availability_slots': slots});
      if (response.statusCode == 200) {
        _availability = (json.decode(response.body)['availability'] as List<dynamic>)
            .map((e) => DoctorAvailability.fromMap(e as Map<String, dynamic>))
            .toList();
        _setLoading(false);
        return true;
      } else {
        final apiResponse = ApiResponse.fromMap(json.decode(response.body) as Map<String, dynamic>);
        _setErrorMessage(apiResponse.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setErrorMessage('Failed to update doctor availability: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<void> fetchDoctorAppointments({int page = 1, int perPage = 10}) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final response = await _apiService.get(
        '/doctor/appointments',
        queryParams: {'page': page.toString(), 'per_page': perPage.toString()},
      );
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        // >>> التعديل هنا: التعامل مع استجابة قد تكون قائمة مباشرة أو Paginated <<<
        if (responseData is List) {
          // إذا كانت الاستجابة قائمة مباشرة (كما في الـ Log الذي أرسلته)
          _appointments = PaginatedResponse(
            data: responseData.map((e) => Appointment.fromMap(e as Map<String, dynamic>)).toList(),
            links: PaginationLinks(), // روابط فارغة أو افتراضية
            meta: PaginationMeta(
              currentPage: page,
              from: (page - 1) * perPage + 1,
              lastPage: 1, // لا يمكن تحديدها بدقة بدون بيانات meta
              links: [],
              path: '/doctor/appointments',
              perPage: perPage,
              to: (page - 1) * perPage + responseData.length,
              total: responseData.length, // إجمالي العناصر في هذه القائمة فقط
            ),
          );
        } else if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          // إذا كانت الاستجابة Paginated (تحتوي على 'data', 'links', 'meta')
          _appointments = PaginatedResponse.fromMap(
            responseData,
            (map) => Appointment.fromMap(map),
          );
        } else {
          _setErrorMessage('Received unexpected data format for doctor appointments.');
        }
      } else {
        _setErrorMessage(ApiResponse.fromMap(json.decode(response.body)).message);
      }
    } catch (e) {
      _setErrorMessage('Failed to load doctor appointments: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateAppointmentStatus(int appointmentId, String status, {String? doctorNotes}) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final response = await _apiService.put('/doctor/appointments/$appointmentId/status', {
        'status': status,
        'doctor_notes': doctorNotes,
      });
      if (response.statusCode == 200) {
        await fetchDoctorAppointments(); // Refresh the list
        _setLoading(false);
        return true;
      } else {
        final apiResponse = ApiResponse.fromMap(json.decode(response.body) as Map<String, dynamic>);
        _setErrorMessage(apiResponse.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setErrorMessage('Failed to update appointment status: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<void> fetchDoctorConsultations({int page = 1, int perPage = 10}) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final response = await _apiService.get(
        '/doctor/consultations',
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
              path: '/doctor/consultations',
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
          _setErrorMessage('Received unexpected data format for doctor consultations.');
        }
      } else {
        _setErrorMessage(ApiResponse.fromMap(json.decode(response.body)).message);
      }
    } catch (e) {
      _setErrorMessage('Failed to load doctor consultations: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendConsultationMessage(int consultationId, String messageContent, {String? attachmentUrl, String? attachmentType}) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final response = await _apiService.post('/doctor/consultations/$consultationId/messages', {
        'message_content': messageContent,
        'attachment_url': attachmentUrl,
        'attachment_type': attachmentType,
      });
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
      _setErrorMessage('Failed to send message: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> issuePrescription(int consultationId, String medicationDetails, {String? instructions}) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final response = await _apiService.post('/doctor/consultations/$consultationId/prescriptions', {
        'medication_details': medicationDetails,
        'instructions': instructions,
      });
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
      _setErrorMessage('Failed to issue prescription: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> closeConsultation(int consultationId) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final response = await _apiService.put('/doctor/consultations/$consultationId/close', {});
      if (response.statusCode == 200) {
        await fetchDoctorConsultations(); // Refresh the list
        _setLoading(false);
        return true;
      } else {
        final apiResponse = ApiResponse.fromMap(json.decode(response.body) as Map<String, dynamic>);
        _setErrorMessage(apiResponse.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setErrorMessage('Failed to close consultation: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<void> fetchUnansweredPublicQuestions({int page = 1, int perPage = 10}) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final response = await _apiService.get(
        '/doctor/public-questions/unanswered',
        queryParams: {'page': page.toString(), 'per_page': perPage.toString()},
      );
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        // >>> التعديل هنا <<<
        if (responseData is List) {
          _unansweredQuestions = PaginatedResponse(
            data: responseData.map((e) => PublicQuestion.fromMap(e as Map<String, dynamic>)).toList(),
            links: PaginationLinks(),
            meta: PaginationMeta(
              currentPage: page,
              from: (page - 1) * perPage + 1,
              lastPage: 1,
              links: [],
              path: '/doctor/public-questions/unanswered',
              perPage: perPage,
              to: (page - 1) * perPage + responseData.length,
              total: responseData.length,
            ),
          );
        } else if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          _unansweredQuestions = PaginatedResponse.fromMap(
            responseData,
            (map) => PublicQuestion.fromMap(map),
          );
        } else {
          _setErrorMessage('Received unexpected data format for unanswered public questions.');
        }
      } else {
        _setErrorMessage(ApiResponse.fromMap(json.decode(response.body)).message);
      }
    } catch (e) {
      _setErrorMessage('Failed to load unanswered questions: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> answerPublicQuestion(int questionId, String answerText) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final response = await _apiService.post('/doctor/public-questions/$questionId/answers', {
        'answer_text': answerText,
      });
      if (response.statusCode == 201) {
        await fetchUnansweredPublicQuestions(); // Refresh list
        _setLoading(false);
        return true;
      } else {
        final apiResponse = ApiResponse.fromMap(json.decode(response.body) as Map<String, dynamic>);
        _setErrorMessage(apiResponse.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setErrorMessage('Failed to answer public question: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<void> fetchDoctorBlogPosts({int page = 1, int perPage = 10}) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final response = await _apiService.get(
        '/doctor/blog-posts',
        queryParams: {'page': page.toString(), 'per_page': perPage.toString()},
      );
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        // >>> التعديل هنا <<<
        if (responseData is List) {
          _blogPosts = PaginatedResponse(
            data: responseData.map((e) => BlogPost.fromMap(e as Map<String, dynamic>)).toList(),
            links: PaginationLinks(),
            meta: PaginationMeta(
              currentPage: page,
              from: (page - 1) * perPage + 1,
              lastPage: 1,
              links: [],
              path: '/doctor/blog-posts',
              perPage: perPage,
              to: (page - 1) * perPage + responseData.length,
              total: responseData.length,
            ),
          );
        } else if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          _blogPosts = PaginatedResponse.fromMap(
            responseData,
            (map) => BlogPost.fromMap(map),
          );
        } else {
          _setErrorMessage('Received unexpected data format for doctor blog posts.');
        }
      } else {
        _setErrorMessage(ApiResponse.fromMap(json.decode(response.body)).message);
      }
    } catch (e) {
      _setErrorMessage('Failed to load doctor blog posts: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createBlogPost(Map<String, dynamic> postData) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final response = await _apiService.post('/doctor/blog-posts', postData);
      if (response.statusCode == 201) {
        await fetchDoctorBlogPosts(); // Refresh list
        _setLoading(false);
        return true;
      } else {
        final apiResponse = ApiResponse.fromMap(json.decode(response.body) as Map<String, dynamic>);
        _setErrorMessage(apiResponse.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setErrorMessage('Failed to create blog post: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateBlogPost(int postId, Map<String, dynamic> postData) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final response = await _apiService.put('/doctor/blog-posts/$postId', postData);
      if (response.statusCode == 200) {
        await fetchDoctorBlogPosts(); // Refresh list
        _setLoading(false);
        return true;
      } else {
        final apiResponse = ApiResponse.fromMap(json.decode(response.body) as Map<String, dynamic>);
        _setErrorMessage(apiResponse.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setErrorMessage('Failed to update blog post: $e');
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteBlogPost(int postId) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final response = await _apiService.delete('/doctor/blog-posts/$postId');
      if (response.statusCode == 200) {
        await fetchDoctorBlogPosts(); // Refresh list
        _setLoading(false);
        return true;
      } else {
        final apiResponse = ApiResponse.fromMap(json.decode(response.body) as Map<String, dynamic>);
        _setErrorMessage(apiResponse.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setErrorMessage('Failed to delete blog post: $e');
      _setLoading(false);
      return false;
    }
  }
}