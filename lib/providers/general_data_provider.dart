import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:your_doctor_app_flutter/models/doctor_profile.dart';
import '../services/api_service.dart';
import '../models/specialization.dart';
import '../models/faq.dart';
import '../models/blog_post.dart';
import '../models/pagination.dart'; // تأكد من استيراد pagination.dart
import '../models/api_response.dart';

class GeneralDataProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Specialization> _specializations = [];
  List<Faq> _faqs = [];
  List<BlogPost> _blogPosts = [];
  bool _isLoading = false;
  String? _errorMessage;
  PaginatedResponse<BlogPost>? _paginatedBlogPosts;
  List<DoctorProfile> _allDoctors = []; // <<< إضافة قائمة لجميع الأطباء

  List<Specialization> get specializations => _specializations;
  List<Faq> get faqs => _faqs;
  List<BlogPost> get blogPosts => _blogPosts;
  PaginatedResponse<BlogPost>? get paginatedBlogPosts => _paginatedBlogPosts;
  List<DoctorProfile> get allDoctors => _allDoctors; // <<< getter لجميع الأطباء

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

  Future<void> fetchAllSpecializations() async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final response = await _apiService.get('/specializations', requiresAuth: false);
      if (response.statusCode == 200) {
        _specializations = (json.decode(response.body) as List<dynamic>)
            .map((e) => Specialization.fromMap(e as Map<String, dynamic>))
            .toList();
      } else {
        _setErrorMessage(ApiResponse.fromMap(json.decode(response.body)).message);
      }
    } catch (e) {
      _setErrorMessage('Failed to load specializations: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchAllFaqs() async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final response = await _apiService.get('/faqs', requiresAuth: false);
      if (response.statusCode == 200) {
        _faqs = (json.decode(response.body) as List<dynamic>)
            .map((e) => Faq.fromMap(e as Map<String, dynamic>))
            .toList();
      } else {
        _setErrorMessage(ApiResponse.fromMap(json.decode(response.body)).message);
      }
    } catch (e) {
      _setErrorMessage('Failed to load FAQs: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchBlogPosts({int page = 1, int perPage = 10}) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final response = await _apiService.get('/blog-posts',
          queryParams: {'page': page.toString(), 'per_page': perPage.toString()}, requiresAuth: false);
      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        // >>> التعديل هنا: التعامل مع استجابة قد تكون قائمة مباشرة أو Paginated <<<
        if (responseData is List) {
          // إذا كانت الاستجابة قائمة مباشرة (كما في الـ Log الذي أرسلته)
          _paginatedBlogPosts = PaginatedResponse(
            data: responseData.map((e) => BlogPost.fromMap(e as Map<String, dynamic>)).toList(),
            links: PaginationLinks(), // روابط فارغة أو افتراضية
            meta: PaginationMeta(
              currentPage: page,
              from: (page - 1) * perPage + 1,
              lastPage: 1, // لا يمكن تحديدها بدقة بدون بيانات meta
              links: [],
              path: '/blog-posts', // مسار افتراضي
              perPage: perPage,
              to: (page - 1) * perPage + responseData.length,
              total: responseData.length, // إجمالي العناصر في هذه القائمة فقط
            ),
          );
        } else if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          // إذا كانت الاستجابة Paginated (تحتوي على 'data', 'links', 'meta')
          _paginatedBlogPosts = PaginatedResponse.fromMap(
            responseData,
            (map) => BlogPost.fromMap(map),
          );
        } else {
          _setErrorMessage('Received unexpected data format for blog posts.');
        }

        _blogPosts = _paginatedBlogPosts!.data; // تأكد أن البيانات يتم تعيينها
      } else {
        _setErrorMessage(ApiResponse.fromMap(json.decode(response.body)).message);
      }
    } catch (e) {
      _setErrorMessage('Failed to load blog posts: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addBlogComment(int postId, String commentText) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final response = await _apiService.post('/blog-posts/$postId/comments', {
        'comment_text': commentText,
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
      _setErrorMessage('Failed to add comment: $e');
      _setLoading(false);
      return false;
    }
  }
  
  // <<< إضافة دالة لجلب جميع الأطباء للمريض >>>
  Future<void> fetchDoctorsForPatientBooking({String? name, int? specializationId, String? specializationName, int page = 1, int perPage = 10}) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      final Map<String, String> queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };
      if (name != null && name.isNotEmpty) queryParams['name'] = name;
      if (specializationId != null) queryParams['specialization_id'] = specializationId.toString();
      if (specializationName != null && specializationName.isNotEmpty) queryParams['specialization_name'] = specializationName;

      final response = await _apiService.get('/doctors', queryParams: queryParams, requiresAuth: false);

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        // هنا نفترض أن API '/doctors' يرجع PaginatedResponse كما هو موثق
        // إذا كان يرجع قائمة مباشرة، فطبق نفس منطق التحقق هنا
        if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
           _allDoctors = (responseData['data'] as List<dynamic>)
                .map((e) => DoctorProfile.fromMap(e as Map<String, dynamic>))
                .toList();
            // يمكنك تخزين PaginationResponse كاملة هنا إذا كنت تحتاجها
        } else if (responseData is List) {
            _allDoctors = responseData.map((e) => DoctorProfile.fromMap(e as Map<String, dynamic>)).toList();
        } else {
            _setErrorMessage('Received unexpected data format for doctors.');
        }

      } else {
        _setErrorMessage(ApiResponse.fromMap(json.decode(response.body)).message);
      }
    } catch (e) {
      _setErrorMessage('Failed to load doctors: $e');
    } finally {
      _setLoading(false);
    }
  }
}