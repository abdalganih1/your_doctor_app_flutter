تمام، هذا هو التحدي الأهم لإطلاق مشروعك! سأقوم بإنشاء مشروع Flutter كامل وجاهز للنسخ واللصق، يتضمن كل ما طلبته: هيكل الملفات، ملف `pubspec.yaml`، ملفات التكوين، خدمة API شاملة، جميع النماذج (Models) المستندة إلى توثيق الـ API، مزودات (Providers) لإدارة الحالة، وشاشات أولية لإظهار التكامل.

**ملاحظات هامة جداً:**

*   **Flutter Null Safety:** بناءً على طلبك "لا يكون هناك قيم null ضمن الاجابات"، سأقوم بتصميم نماذج Dart لتكون **غير قابلة للـ `null` (non-nullable)** قدر الإمكان للحقول التي تظهر في الأمثلة بقيم غير `null`. للحقول التي تم تحديدها كـ `nullable: true` في توثيق OpenAPI أو لا تظهر أبداً في الأمثلة، سأستخدم **النوع القابل للـ `null` (`Type?`)** في Dart، لأن الـ API *قد* يرجع `null` لتلك الحقول، وهذا هو الأسلوب الآمن لتجنب أعطال التطبيق.
*   **Print Statements:** سأضيف `print()` statements في كل مكان يتم فيه جلب البيانات من الـ API لطباعة الاستجابة كاملة للمساعدة في التصحيح والتتبع.
*   **الروابط:** سأستخدم الرابط الجديد `https://darkred-tiger-154754.hostingersite.com/` لملف `env.dart`.
*   **التنظيم:** ستكون جميع الملفات منظمة في مجلدات منطقية داخل `lib/`.
*   **الجاهزية للنسخ واللصق:** سأقدم كل الكود في قالب واحد ضخم مع تعليمات واضحة لإنشاء المشروع ثم نسخ ولصق المحتوى.

---

**الخطوة 1: إنشاء مشروع Flutter جديد**

افتح الطرفية (Terminal) أو موجه الأوامر (Command Prompt) وانتقل إلى المجلد الذي تريد إنشاء مشروعك فيه، ثم نفذ الأمر التالي:

```bash
flutter create your_doctor_app_flutter
```

بعد انتهاء عملية الإنشاء، انتقل إلى مجلد المشروع:

```bash
cd your_doctor_app_flutter
```

---

**الخطوة 2: تحديث `pubspec.yaml`**

افتح ملف `pubspec.yaml` في جذر المشروع واستبدل محتواه بالكامل بالمحتوى التالي:

**`pubspec.yaml`**

```yaml
name: your_doctor_app_flutter
description: A new Flutter project for Your Doctor app.

publish_to: 'none' # Remove this line if you intend to publish to pub.dev

version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0' # تأكد أن هذا يتوافق مع إصدار Flutter لديك

dependencies:
  flutter:
    sdk: flutter
  
  # HTTP client for making API requests
  http: ^1.2.1
  
  # State management solution
  provider: ^6.1.2
  
  # For persisting user token and other sensitive data
  shared_preferences: ^2.2.3
  flutter_secure_storage: ^9.0.0 # لتخزين الرموز المميزة بشكل آمن
  
  # For date and time formatting
  intl: ^0.19.0
  
  # For displaying icons (optional, but good for UI)
  font_awesome_flutter: ^10.7.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true

  # To add assets to your application
  # assets:
  #   - assets/images/
  #   - assets/icons/

  # To add custom fonts to your application, add a fonts section here,
  # in this "flutter" section. Each entry in this list should have a
  # "family" key with the font family name, and a "fonts" key with a
  # list giving the asset and other descriptors for the font.
  # fonts:
  #   - family: Schyler
  #     fonts:
  #       - asset: fonts/Schyler-Regular.ttf
  #   - family: Trajan Pro
  #     fonts:
  #       - asset: fonts/TrajanPro_Bold.ttf
```

بعد تعديل `pubspec.yaml`، احفظ الملف ونفذ الأمر التالي لتثبيت التبعيات:

```bash
flutter pub get
```

---

**الخطوة 3: إنشاء هيكل المجلدات الأساسي**

داخل مجلد `lib/`، قم بإنشاء المجلدات التالية:

```
lib/
├── config/
├── services/
├── models/
├── providers/
├── screens/
│   ├── auth/
│   ├── dashboards/
├── main.dart
```

---

**الخطوة 4: ملفات التكوين (Configuration Files)**

**`lib/config/env.dart`**

```dart
class Env {
  static const String appUrl = String.fromEnvironment('APP_URL', defaultValue: 'https://darkred-tiger-154754.hostingersite.com');
  static const String apiUrl = String.fromEnvironment('API_URL', defaultValue: 'https://darkred-tiger-154754.hostingersite.com/api');
}
```

**`lib/config/config.dart`**

```dart
class AppConfig {
  static const String appName = 'Your Doctor';
  static const String defaultPassword = 'password'; // For quick login during development
  static const int paginationPerPage = 10; // Default items per page for API pagination
  static const String defaultCurrency = 'SYP';
}
```

---

**الخطوة 5: خدمة الـ API (ApiService)**

**`lib/services/api_service.dart`**

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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
```

---

**الخطوة 6: نماذج البيانات (Models)**

هذه هي جميع نماذج Dart المستندة إلى OpenAPI Schema التي قدمتها. كل نموذج في ملفه الخاص.

**`lib/models/api_response.dart`** (تم تضمينه سابقاً في الفكر، لكنه هنا في مكانه الصحيح)

```dart
import 'dart:convert';

class ApiResponse {
  final String message;
  final Map<String, dynamic>? errors; // For validation errors

  ApiResponse({
    required this.message,
    this.errors,
  });

  factory ApiResponse.fromMap(Map<String, dynamic> map) {
    return ApiResponse(
      message: map['message'] as String,
      errors: map['errors'] != null ? Map<String, dynamic>.from(map['errors'] as Map) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'errors': errors,
    };
  }

  String toJson() => json.encode(toMap());
  factory ApiResponse.fromJson(String source) => ApiResponse.fromMap(json.decode(source) as Map<String, dynamic>);
}
```

**`lib/models/pagination.dart`** (تم تضمينه سابقاً في الفكر)

```dart
import 'dart:convert';

class PaginationLinks {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  PaginationLinks({
    this.first,
    this.last,
    this.prev,
    this.next,
  });

  factory PaginationLinks.fromMap(Map<String, dynamic> map) {
    return PaginationLinks(
      first: map['first'] as String?,
      last: map['last'] as String?,
      prev: map['prev'] as String?,
      next: map['next'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'first': first,
      'last': last,
      'prev': prev,
      'next': next,
    };
  }
}

class PaginationMetaLink {
  final String? url;
  final String label;
  final bool active;

  PaginationMetaLink({
    this.url,
    required this.label,
    required this.active,
  });

  factory PaginationMetaLink.fromMap(Map<String, dynamic> map) {
    return PaginationMetaLink(
      url: map['url'] as String?,
      label: map['label'] as String,
      active: map['active'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'label': label,
      'active': active,
    };
  }
}

class PaginationMeta {
  final int currentPage;
  final int from;
  final int lastPage;
  final List<PaginationMetaLink> links;
  final String path;
  final int perPage;
  final int to;
  final int total;

  PaginationMeta({
    required this.currentPage,
    required this.from,
    required this.lastPage,
    required this.links,
    required this.path,
    required this.perPage,
    required this.to,
    required this.total,
  });

  factory PaginationMeta.fromMap(Map<String, dynamic> map) {
    return PaginationMeta(
      currentPage: map['current_page'] as int,
      from: map['from'] as int,
      lastPage: map['last_page'] as int,
      links: (map['links'] as List<dynamic>)
          .map((e) => PaginationMetaLink.fromMap(e as Map<String, dynamic>))
          .toList(),
      path: map['path'] as String,
      perPage: map['per_page'] as int,
      to: map['to'] as int,
      total: map['total'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'current_page': currentPage,
      'from': from,
      'last_page': lastPage,
      'links': links.map((e) => e.toMap()).toList(),
      'path': path,
      'per_page': perPage,
      'to': to,
      'total': total,
    };
  }
}

class PaginatedResponse<T> {
  final List<T> data;
  final PaginationLinks links;
  final PaginationMeta meta;

  PaginatedResponse({
    required this.data,
    required this.links,
    required this.meta,
  });

  factory PaginatedResponse.fromMap(
      Map<String, dynamic> map, T Function(Map<String, dynamic>) fromJsonT) {
    return PaginatedResponse(
      data: (map['data'] as List<dynamic>)
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
      links: PaginationLinks.fromMap(map['links'] as Map<String, dynamic>),
      meta: PaginationMeta.fromMap(map['meta'] as Map<String, dynamic>),
    );
  }
}
```

**`lib/models/specialization.dart`**

```dart
import 'dart:convert';

class Specialization {
  final int id;
  final String nameAr;
  final String? nameEn;
  final String? description;
  final String? iconUrl;

  Specialization({
    required this.id,
    required this.nameAr,
    this.nameEn,
    this.description,
    this.iconUrl,
  });

  factory Specialization.fromMap(Map<String, dynamic> map) {
    return Specialization(
      id: map['id'] as int,
      nameAr: map['nameAr'] as String,
      nameEn: map['nameEn'] as String?,
      description: map['description'] as String?,
      iconUrl: map['iconUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'description': description,
      'iconUrl': iconUrl,
    };
  }

  String toJson() => json.encode(toMap());
  factory Specialization.fromJson(String source) => Specialization.fromMap(json.decode(source) as Map<String, dynamic>);
}
```

**`lib/models/doctor_profile.dart`**

```dart
import 'dart:convert';
import 'specialization.dart'; // Make sure to import Specialization

class DoctorProfile {
  final int id;
  final int userId;
  final int specializationId;
  final String bio;
  final int yearsExperience;
  final double consultationFee;
  final String profilePictureUrl;
  final Specialization? specialization; // Nullable if not always loaded

  DoctorProfile({
    required this.id,
    required this.userId,
    required this.specializationId,
    required this.bio,
    required this.yearsExperience,
    required this.consultationFee,
    required this.profilePictureUrl,
    this.specialization,
  });

  factory DoctorProfile.fromMap(Map<String, dynamic> map) {
    return DoctorProfile(
      id: map['id'] as int,
      userId: map['userId'] as int,
      specializationId: map['specializationId'] as int,
      bio: map['bio'] as String,
      yearsExperience: map['yearsExperience'] as int,
      consultationFee: (map['consultationFee'] as num).toDouble(),
      profilePictureUrl: map['profilePictureUrl'] as String,
      specialization: map['specialization'] != null
          ? Specialization.fromMap(map['specialization'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'specializationId': specializationId,
      'bio': bio,
      'yearsExperience': yearsExperience,
      'consultationFee': consultationFee,
      'profilePictureUrl': profilePictureUrl,
      'specialization': specialization?.toMap(),
    };
  }

  String toJson() => json.encode(toMap());
  factory DoctorProfile.fromJson(String source) => DoctorProfile.fromMap(json.decode(source) as Map<String, dynamic>);
}
```

**`lib/models/user.dart`** (تم تحديثه ليتناسب مع `DoctorProfile`)

```dart
import 'dart:convert';
import 'doctor_profile.dart'; // Ensure correct import

class User {
  final int id;
  final String name;
  final String email;
  final String? phone; // Nullable in Laravel, so nullable in Dart
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final DoctorProfile? doctorProfile; // Nullable, as not all users are doctors

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    required this.isActive,
    required this.createdAt,
    this.doctorProfile,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int,
      name: map['name'] as String,
      email: map['email'] as String,
      phone: map['phone'] as String?, // Cast to String?
      role: map['role'] as String,
      isActive: map['isActive'] as bool,
      createdAt: DateTime.parse(map['createdAt'] as String),
      doctorProfile: map['doctorProfile'] != null
          ? DoctorProfile.fromMap(map['doctorProfile'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'doctorProfile': doctorProfile?.toMap(),
    };
  }

  String toJson() => json.encode(toMap());
  factory User.fromJson(String source) => User.fromMap(json.decode(source) as Map<String, dynamic>);
}
```

**`lib/models/payment.dart`**

```dart
import 'dart:convert';
import 'user.dart';
import 'consultation.dart'; // Simple version to break circular dependency
import 'appointment.dart'; // Simple version to break circular dependency

// Simple version used in circular references in other models
class PaymentSimple {
  final int id;
  final int userId;
  final double amount;
  final String currency;
  final String paymentMethod;
  final String? transactionReference;
  final String status;
  final String purpose;
  final int? consultationId;
  final int? appointmentId;
  final DateTime? paymentDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentSimple({
    required this.id,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    this.transactionReference,
    required this.status,
    required this.purpose,
    this.consultationId,
    this.appointmentId,
    this.paymentDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentSimple.fromMap(Map<String, dynamic> map) {
    return PaymentSimple(
      id: map['id'] as int,
      userId: map['userId'] as int,
      amount: (map['amount'] as num).toDouble(),
      currency: map['currency'] as String,
      paymentMethod: map['paymentMethod'] as String,
      transactionReference: map['transactionReference'] as String?,
      status: map['status'] as String,
      purpose: map['purpose'] as String,
      consultationId: map['consultationId'] as int?,
      appointmentId: map['appointmentId'] as int?,
      paymentDate: map['paymentDate'] != null ? DateTime.parse(map['paymentDate'] as String) : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'currency': currency,
      'paymentMethod': paymentMethod,
      'transactionReference': transactionReference,
      'status': status,
      'purpose': purpose,
      'consultationId': consultationId,
      'appointmentId': appointmentId,
      'paymentDate': paymentDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

// Full version of Payment resource
class Payment extends PaymentSimple {
  final User? user;
  final ConsultationSimple? consultation;
  final AppointmentSimple? appointment;

  Payment({
    required super.id,
    required super.userId,
    required super.amount,
    required super.currency,
    required super.paymentMethod,
    super.transactionReference,
    required super.status,
    required super.purpose,
    super.consultationId,
    super.appointmentId,
    super.paymentDate,
    required super.createdAt,
    required super.updatedAt,
    this.user,
    this.consultation,
    this.appointment,
  });

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] as int,
      userId: map['userId'] as int,
      amount: (map['amount'] as num).toDouble(),
      currency: map['currency'] as String,
      paymentMethod: map['paymentMethod'] as String,
      transactionReference: map['transactionReference'] as String?,
      status: map['status'] as String,
      purpose: map['purpose'] as String,
      consultationId: map['consultationId'] as int?,
      appointmentId: map['appointmentId'] as int?,
      paymentDate: map['paymentDate'] != null ? DateTime.parse(map['paymentDate'] as String) : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      user: map['user'] != null ? User.fromMap(map['user'] as Map<String, dynamic>) : null,
      consultation: map['consultation'] != null ? ConsultationSimple.fromMap(map['consultation'] as Map<String, dynamic>) : null,
      appointment: map['appointment'] != null ? AppointmentSimple.fromMap(map['appointment'] as Map<String, dynamic>) : null,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = super.toMap();
    data['user'] = user?.toMap();
    data['consultation'] = consultation?.toMap();
    data['appointment'] = appointment?.toMap();
    return data;
  }

  String toJson() => json.encode(toMap());
  factory Payment.fromJson(String source) => Payment.fromMap(json.decode(source) as Map<String, dynamic>);
}
```

**`lib/models/appointment.dart`**

```dart
import 'dart:convert';
import 'user.dart';
import 'doctor_profile.dart';
import 'payment.dart'; // Simple version to break circular dependency

// Simple version used in circular references in other models
class AppointmentSimple {
  final int id;
  final int patientUserId;
  final int doctorId;
  final DateTime appointmentDatetime;
  final int durationMinutes;
  final String status;
  final String? patientNotes;
  final String? doctorNotes;
  final int? paymentId;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppointmentSimple({
    required this.id,
    required this.patientUserId,
    required this.doctorId,
    required this.appointmentDatetime,
    required this.durationMinutes,
    required this.status,
    this.patientNotes,
    this.doctorNotes,
    this.paymentId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppointmentSimple.fromMap(Map<String, dynamic> map) {
    return AppointmentSimple(
      id: map['id'] as int,
      patientUserId: map['patientUserId'] as int,
      doctorId: map['doctorId'] as int,
      appointmentDatetime: DateTime.parse(map['appointmentDatetime'] as String),
      durationMinutes: map['durationMinutes'] as int,
      status: map['status'] as String,
      patientNotes: map['patientNotes'] as String?,
      doctorNotes: map['doctorNotes'] as String?,
      paymentId: map['paymentId'] as int?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientUserId': patientUserId,
      'doctorId': doctorId,
      'appointmentDatetime': appointmentDatetime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'status': status,
      'patientNotes': patientNotes,
      'doctorNotes': doctorNotes,
      'paymentId': paymentId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

// Full version of Appointment resource
class Appointment extends AppointmentSimple {
  final User? patient;
  final DoctorProfile? doctor;
  final PaymentSimple? payment;

  Appointment({
    required super.id,
    required super.patientUserId,
    required super.doctorId,
    required super.appointmentDatetime,
    required super.durationMinutes,
    required super.status,
    super.patientNotes,
    super.doctorNotes,
    super.paymentId,
    required super.createdAt,
    required super.updatedAt,
    this.patient,
    this.doctor,
    this.payment,
  });

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] as int,
      patientUserId: map['patientUserId'] as int,
      doctorId: map['doctorId'] as int,
      appointmentDatetime: DateTime.parse(map['appointmentDatetime'] as String),
      durationMinutes: map['durationMinutes'] as int,
      status: map['status'] as String,
      patientNotes: map['patientNotes'] as String?,
      doctorNotes: map['doctorNotes'] as String?,
      paymentId: map['paymentId'] as int?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      patient: map['patient'] != null ? User.fromMap(map['patient'] as Map<String, dynamic>) : null,
      doctor: map['doctor'] != null ? DoctorProfile.fromMap(map['doctor'] as Map<String, dynamic>) : null,
      payment: map['payment'] != null ? PaymentSimple.fromMap(map['payment'] as Map<String, dynamic>) : null,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = super.toMap();
    data['patient'] = patient?.toMap();
    data['doctor'] = doctor?.toMap();
    data['payment'] = payment?.toMap();
    return data;
  }

  String toJson() => json.encode(toMap());
  factory Appointment.fromJson(String source) => Appointment.fromMap(json.decode(source) as Map<String, dynamic>);
}
```

**`lib/models/doctor_availability.dart`**

```dart
import 'dart:convert';

class DoctorAvailability {
  final int id;
  final int doctorId;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final bool isAvailable;

  DoctorAvailability({
    required this.id,
    required this.doctorId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
  });

  factory DoctorAvailability.fromMap(Map<String, dynamic> map) {
    return DoctorAvailability(
      id: map['id'] as int,
      doctorId: map['doctorId'] as int,
      dayOfWeek: map['dayOfWeek'] as int,
      startTime: map['startTime'] as String,
      endTime: map['endTime'] as String,
      isAvailable: map['isAvailable'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctorId': doctorId,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'isAvailable': isAvailable,
    };
  }

  String toJson() => json.encode(toMap());
  factory DoctorAvailability.fromJson(String source) => DoctorAvailability.fromMap(json.decode(source) as Map<String, dynamic>);
}
```

**`lib/models/message.dart`**

```dart
import 'dart:convert';
import 'user.dart';

class Message {
  final int id;
  final int consultationId;
  final int senderUserId;
  final String messageContent;
  final DateTime sentAt;
  final bool isRead;
  final String? attachmentUrl;
  final String? attachmentType;
  final User? sender; // User who sent the message

  Message({
    required this.id,
    required this.consultationId,
    required this.senderUserId,
    required this.messageContent,
    required this.sentAt,
    required this.isRead,
    this.attachmentUrl,
    this.attachmentType,
    this.sender,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as int,
      consultationId: map['consultationId'] as int,
      senderUserId: map['senderUserId'] as int,
      messageContent: map['messageContent'] as String,
      sentAt: DateTime.parse(map['sentAt'] as String),
      isRead: map['isRead'] as bool,
      attachmentUrl: map['attachmentUrl'] as String?,
      attachmentType: map['attachmentType'] as String?,
      sender: map['sender'] != null ? User.fromMap(map['sender'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'consultationId': consultationId,
      'senderUserId': senderUserId,
      'messageContent': messageContent,
      'sentAt': sentAt.toIso8601String(),
      'isRead': isRead,
      'attachmentUrl': attachmentUrl,
      'attachmentType': attachmentType,
      'sender': sender?.toMap(),
    };
  }

  String toJson() => json.encode(toMap());
  factory Message.fromJson(String source) => Message.fromMap(json.decode(source) as Map<String, dynamic>);
}
```

**`lib/models/prescription.dart`**

```dart
import 'dart:convert';
import 'user.dart';
import 'consultation.dart'; // Simple version to break circular dependency

class Prescription {
  final int id;
  final int consultationId;
  final int patientUserId;
  final int doctorUserId;
  final String medicationDetails;
  final String? instructions;
  final DateTime issueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? patient;
  final User? doctor;

  Prescription({
    required this.id,
    required this.consultationId,
    required this.patientUserId,
    required this.doctorUserId,
    required this.medicationDetails,
    this.instructions,
    required this.issueDate,
    required this.createdAt,
    required this.updatedAt,
    this.patient,
    this.doctor,
  });

  factory Prescription.fromMap(Map<String, dynamic> map) {
    return Prescription(
      id: map['id'] as int,
      consultationId: map['consultationId'] as int,
      patientUserId: map['patientUserId'] as int,
      doctorUserId: map['doctorUserId'] as int,
      medicationDetails: map['medicationDetails'] as String,
      instructions: map['instructions'] as String?,
      issueDate: DateTime.parse(map['issueDate'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      patient: map['patient'] != null ? User.fromMap(map['patient'] as Map<String, dynamic>) : null,
      doctor: map['doctor'] != null ? User.fromMap(map['doctor'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'consultationId': consultationId,
      'patientUserId': patientUserId,
      'doctorUserId': doctorUserId,
      'medicationDetails': medicationDetails,
      'instructions': instructions,
      'issueDate': issueDate.toIso8601String().split('T')[0], // Only date
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'patient': patient?.toMap(),
      'doctor': doctor?.toMap(),
    };
  }

  String toJson() => json.encode(toMap());
  factory Prescription.fromJson(String source) => Prescription.fromMap(json.decode(source) as Map<String, dynamic>);
}
```

**`lib/models/consultation.dart`** (تم تحديثه ليتناسب مع `Message` و `Prescription`)

```dart
import 'dart:convert';
import 'user.dart';
import 'message.dart';
import 'prescription.dart';
import 'payment.dart'; // Simple version to break circular dependency

// Simple version used in circular references in other models
class ConsultationSimple {
  final int id;
  final int patientUserId;
  final int doctorUserId;
  final DateTime startTime;
  final DateTime? endTime;
  final String status;
  final int? paymentId;
  final DateTime createdAt;
  final DateTime updatedAt;

  ConsultationSimple({
    required this.id,
    required this.patientUserId,
    required this.doctorUserId,
    required this.startTime,
    this.endTime,
    required this.status,
    this.paymentId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ConsultationSimple.fromMap(Map<String, dynamic> map) {
    return ConsultationSimple(
      id: map['id'] as int,
      patientUserId: map['patientUserId'] as int,
      doctorUserId: map['doctorUserId'] as int,
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime'] as String) : null,
      status: map['status'] as String,
      paymentId: map['paymentId'] as int?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientUserId': patientUserId,
      'doctorUserId': doctorUserId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'status': status,
      'paymentId': paymentId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

// Full version of Consultation resource
class Consultation extends ConsultationSimple {
  final User? patient;
  final User? doctor; // This doctor is a User model
  final List<Message> messages;
  final List<Prescription> prescriptions;
  final PaymentSimple? payment;

  Consultation({
    required super.id,
    required super.patientUserId,
    required super.doctorUserId,
    required super.startTime,
    super.endTime,
    required super.status,
    super.paymentId,
    required super.createdAt,
    required super.updatedAt,
    this.patient,
    this.doctor,
    required this.messages,
    required this.prescriptions,
    this.payment,
  });

  factory Consultation.fromMap(Map<String, dynamic> map) {
    return Consultation(
      id: map['id'] as int,
      patientUserId: map['patientUserId'] as int,
      doctorUserId: map['doctorUserId'] as int,
      startTime: DateTime.parse(map['startTime'] as String),
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime'] as String) : null,
      status: map['status'] as String,
      paymentId: map['paymentId'] as int?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      patient: map['patient'] != null ? User.fromMap(map['patient'] as Map<String, dynamic>) : null,
      doctor: map['doctor'] != null ? User.fromMap(map['doctor'] as Map<String, dynamic>) : null,
      messages: (map['messages'] as List<dynamic>?)?.map((e) => Message.fromMap(e as Map<String, dynamic>)).toList() ?? [],
      prescriptions: (map['prescriptions'] as List<dynamic>?)?.map((e) => Prescription.fromMap(e as Map<String, dynamic>)).toList() ?? [],
      payment: map['payment'] != null ? PaymentSimple.fromMap(map['payment'] as Map<String, dynamic>) : null,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = super.toMap();
    data['patient'] = patient?.toMap();
    data['doctor'] = doctor?.toMap();
    data['messages'] = messages.map((e) => e.toMap()).toList();
    data['prescriptions'] = prescriptions.map((e) => e.toMap()).toList();
    data['payment'] = payment?.toMap();
    return data;
  }

  String toJson() => json.encode(toMap());
  factory Consultation.fromJson(String source) => Consultation.fromMap(json.decode(source) as Map<String, dynamic>);
}
```

**`lib/models/faq.dart`**

```dart
import 'dart:convert';
import 'user.dart';

class Faq {
  final int id;
  final String question;
  final String answer;
  final String? category;
  final int? createdByAdminId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? createdByAdmin; // Admin user who created it

  Faq({
    required this.id,
    required this.question,
    required this.answer,
    this.category,
    this.createdByAdminId,
    required this.createdAt,
    required this.updatedAt,
    this.createdByAdmin,
  });

  factory Faq.fromMap(Map<String, dynamic> map) {
    return Faq(
      id: map['id'] as int,
      question: map['question'] as String,
      answer: map['answer'] as String,
      category: map['category'] as String?,
      createdByAdminId: map['createdByAdminId'] as int?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      createdByAdmin: map['createdByAdmin'] != null ? User.fromMap(map['createdByAdmin'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'category': category,
      'createdByAdminId': createdByAdminId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdByAdmin': createdByAdmin?.toMap(),
    };
  }

  String toJson() => json.encode(toMap());
  factory Faq.fromJson(String source) => Faq.fromMap(json.decode(source) as Map<String, dynamic>);
}
```

**`lib/models/public_question.dart`**

```dart
import 'dart:convert';
import 'user.dart';
import 'public_question_answer.dart';

class PublicQuestion {
  final int id;
  final int authorUserId;
  final String title;
  final String details;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? author;
  final List<PublicQuestionAnswer> answers;

  PublicQuestion({
    required this.id,
    required this.authorUserId,
    required this.title,
    required this.details,
    required this.createdAt,
    required this.updatedAt,
    this.author,
    required this.answers,
  });

  factory PublicQuestion.fromMap(Map<String, dynamic> map) {
    return PublicQuestion(
      id: map['id'] as int,
      authorUserId: map['authorUserId'] as int,
      title: map['title'] as String,
      details: map['details'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      author: map['author'] != null ? User.fromMap(map['author'] as Map<String, dynamic>) : null,
      answers: (map['answers'] as List<dynamic>?)?.map((e) => PublicQuestionAnswer.fromMap(e as Map<String, dynamic>)).toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorUserId': authorUserId,
      'title': title,
      'details': details,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'author': author?.toMap(),
      'answers': answers.map((e) => e.toMap()).toList(),
    };
  }

  String toJson() => json.encode(toMap());
  factory PublicQuestion.fromJson(String source) => PublicQuestion.fromMap(json.decode(source) as Map<String, dynamic>);
}
```

**`lib/models/public_question_answer.dart`**

```dart
import 'dart:convert';
import 'user.dart';

class PublicQuestionAnswer {
  final int id;
  final int questionId;
  final int authorUserId;
  final String answerText;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? author; // Author can be a patient or doctor

  PublicQuestionAnswer({
    required this.id,
    required this.questionId,
    required this.authorUserId,
    required this.answerText,
    required this.createdAt,
    required this.updatedAt,
    this.author,
  });

  factory PublicQuestionAnswer.fromMap(Map<String, dynamic> map) {
    return PublicQuestionAnswer(
      id: map['id'] as int,
      questionId: map['questionId'] as int,
      authorUserId: map['authorUserId'] as int,
      answerText: map['answerText'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      author: map['author'] != null ? User.fromMap(map['author'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questionId': questionId,
      'authorUserId': authorUserId,
      'answerText': answerText,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'author': author?.toMap(),
    };
  }

  String toJson() => json.encode(toMap());
  factory PublicQuestionAnswer.fromJson(String source) => PublicQuestionAnswer.fromMap(json.decode(source) as Map<String, dynamic>);
}
```

**`lib/models/blog_post.dart`**

```dart
import 'dart:convert';
import 'doctor_profile.dart';
import 'blog_comment.dart';

class BlogPost {
  final int id;
  final int authorDoctorId;
  final String title;
  final String content;
  final String? featuredImageUrl;
  final String? videoUrl;
  final String status;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DoctorProfile? authorDoctor;
  final List<BlogComment> comments;

  BlogPost({
    required this.id,
    required this.authorDoctorId,
    required this.title,
    required this.content,
    this.featuredImageUrl,
    this.videoUrl,
    required this.status,
    this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
    this.authorDoctor,
    required this.comments,
  });

  factory BlogPost.fromMap(Map<String, dynamic> map) {
    return BlogPost(
      id: map['id'] as int,
      authorDoctorId: map['authorDoctorId'] as int,
      title: map['title'] as String,
      content: map['content'] as String,
      featuredImageUrl: map['featuredImageUrl'] as String?,
      videoUrl: map['videoUrl'] as String?,
      status: map['status'] as String,
      publishedAt: map['publishedAt'] != null ? DateTime.parse(map['publishedAt'] as String) : null,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      authorDoctor: map['authorDoctor'] != null ? DoctorProfile.fromMap(map['authorDoctor'] as Map<String, dynamic>) : null,
      comments: (map['comments'] as List<dynamic>?)?.map((e) => BlogComment.fromMap(e as Map<String, dynamic>)).toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorDoctorId': authorDoctorId,
      'title': title,
      'content': content,
      'featuredImageUrl': featuredImageUrl,
      'videoUrl': videoUrl,
      'status': status,
      'publishedAt': publishedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'authorDoctor': authorDoctor?.toMap(),
      'comments': comments.map((e) => e.toMap()).toList(),
    };
  }

  String toJson() => json.encode(toMap());
  factory BlogPost.fromJson(String source) => BlogPost.fromMap(json.decode(source) as Map<String, dynamic>);
}
```

**`lib/models/blog_comment.dart`**

```dart
import 'dart:convert';
import 'user.dart';

class BlogComment {
  final int id;
  final int postId;
  final int authorUserId;
  final String commentText;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? author;

  BlogComment({
    required this.id,
    required this.postId,
    required this.authorUserId,
    required this.commentText,
    required this.createdAt,
    required this.updatedAt,
    this.author,
  });

  factory BlogComment.fromMap(Map<String, dynamic> map) {
    return BlogComment(
      id: map['id'] as int,
      postId: map['postId'] as int,
      authorUserId: map['authorUserId'] as int,
      commentText: map['commentText'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      author: map['author'] != null ? User.fromMap(map['author'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'authorUserId': authorUserId,
      'commentText': commentText,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'author': author?.toMap(),
    };
  }

  String toJson() => json.encode(toMap());
  factory BlogComment.fromJson(String source) => BlogComment.fromMap(json.decode(source) as Map<String, dynamic>);
}
```

---

**الخطوة 7: مزودات إدارة الحالة (Providers)**

**`lib/providers/auth_provider.dart`**

```dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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
      final response = await _apiService.post('/login', {
        'email': email,
        'password': password,
      }, requiresAuth: false);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        _token = data['access_token'] as String;
        await _apiService.setToken(_token!);
        _user = User.fromMap(data['user'] as Map<String, dynamic>);
        _setLoading(false);
        return true;
      } else {
        final apiResponse = ApiResponse.fromMap(json.decode(response.body) as Map<String, dynamic>);
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
      final response = await _apiService.post('/register', userData, requiresAuth: false);

      if (response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        _token = data['access_token'] as String;
        await _apiService.setToken(_token!);
        _user = User.fromMap(data['user'] as Map<String, dynamic>);
        _setLoading(false);
        return true;
      } else {
        final apiResponse = ApiResponse.fromMap(json.decode(response.body) as Map<String, dynamic>);
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
        final apiResponse = ApiResponse.fromMap(json.decode(response.body) as Map<String, dynamic>);
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
```

**`lib/providers/general_data_provider.dart`**

```dart
import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/specialization.dart';
import '../models/faq.dart';
import '../models/blog_post.dart';
import '../models/pagination.dart';
import '../models/api_response.dart';

class GeneralDataProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Specialization> _specializations = [];
  List<Faq> _faqs = [];
  List<BlogPost> _blogPosts = [];
  bool _isLoading = false;
  String? _errorMessage;
  PaginatedResponse<BlogPost>? _paginatedBlogPosts;

  List<Specialization> get specializations => _specializations;
  List<Faq> get faqs => _faqs;
  List<BlogPost> get blogPosts => _blogPosts;
  PaginatedResponse<BlogPost>? get paginatedBlogPosts => _paginatedBlogPosts;
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
        _paginatedBlogPosts = PaginatedResponse.fromMap(
          json.decode(response.body) as Map<String, dynamic>,
          (map) => BlogPost.fromMap(map),
        );
        _blogPosts = _paginatedBlogPosts!.data;
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
        // Optionally refetch blog post to show new comment
        // final updatedPostResponse = await _apiService.get('/blog-posts/$postId', requiresAuth: false);
        // if (updatedPostResponse.statusCode == 200) {
        //   _blogPosts = _blogPosts.map((post) => post.id == postId ? BlogPost.fromMap(json.decode(updatedPostResponse.body)) : post).toList();
        // }
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
}
```

**`lib/providers/patient_provider.dart`**

```dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../models/appointment.dart';
import '../models/consultation.dart';
import '../models/prescription.dart';
import '../models/public_question.dart';
import '../models/payment.dart';
import '../models/pagination.dart';
import '../models/api_response.dart';

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
        _appointments = PaginatedResponse.fromMap(
          json.decode(response.body) as Map<String, dynamic>,
          (map) => Appointment.fromMap(map),
        );
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
        _consultations = PaginatedResponse.fromMap(
          json.decode(response.body) as Map<String, dynamic>,
          (map) => Consultation.fromMap(map),
        );
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
        _prescriptions = PaginatedResponse.fromMap(
          json.decode(response.body) as Map<String, dynamic>,
          (map) => Prescription.fromMap(map),
        );
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
        _publicQuestions = PaginatedResponse.fromMap(
          json.decode(response.body) as Map<String, dynamic>,
          (map) => PublicQuestion.fromMap(map),
        );
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
```

**`lib/providers/doctor_provider.dart`**

```dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../models/doctor_profile.dart';
import '../models/doctor_availability.dart';
import '../models/appointment.dart';
import '../models/consultation.dart';
import '../models/public_question.dart';
import '../models/blog_post.dart';
import '../models/pagination.dart';
import '../models/api_response.dart';

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
        _doctorProfile = DoctorProfile.fromMap(json.decode(response.body) as Map<String, dynamic>);
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
        _appointments = PaginatedResponse.fromMap(
          json.decode(response.body) as Map<String, dynamic>,
          (map) => Appointment.fromMap(map),
        );
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
        _consultations = PaginatedResponse.fromMap(
          json.decode(response.body) as Map<String, dynamic>,
          (map) => Consultation.fromMap(map),
        );
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
        // Optionally update specific consultation with new message
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
        _unansweredQuestions = PaginatedResponse.fromMap(
          json.decode(response.body) as Map<String, dynamic>,
          (map) => PublicQuestion.fromMap(map),
        );
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
        _blogPosts = PaginatedResponse.fromMap(
          json.decode(response.body) as Map<String, dynamic>,
          (map) => BlogPost.fromMap(map),
        );
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
```

---

**الخطوة 8: الشاشات الأولية (Initial Screens)**

**`lib/main.dart`** (ملف التطبيق الرئيسي)

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/general_data_provider.dart';
import 'providers/patient_provider.dart';
import 'providers/doctor_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/loading_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => GeneralDataProvider()),
        ChangeNotifierProvider(create: (_) => PatientProvider()),
        ChangeNotifierProvider(create: (_) => DoctorProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your Doctor App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isLoading) {
            return const LoadingScreen();
          } else if (authProvider.user != null) {
            return const DashboardScreen();
          } else {
            return LoginScreen();
          }
        },
      ),
      routes: {
        '/login': (context) => LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        // Define other routes here as needed
      },
    );
  }
}
```

**`lib/screens/loading_screen.dart`**

```dart
import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('جاري التحميل...'),
          ],
        ),
      ),
    );
  }
}
```

**`lib/screens/auth/login_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/config.dart'; // For default password
import 'register_screen.dart'; // For navigation to register screen

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل الدخول')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'كلمة المرور'),
                obscureText: true,
              ),
              if (authProvider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    authProvider.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 20),
              authProvider.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        bool success = await authProvider.login(
                          _emailController.text,
                          _passwordController.text,
                        );
                        if (success) {
                          Navigator.of(context).pushReplacementNamed('/dashboard');
                        }
                      },
                      child: const Text('تسجيل الدخول'),
                    ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => RegisterScreen()));
                },
                child: const Text('إنشاء حساب جديد'),
              ),
              const SizedBox(height: 30),
              const Divider(),
              const Text('تسجيل دخول سريع للتجربة (للتطوير فقط)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildQuickLoginButton(context, 'مدير', 'admin@yourdoctor.com', AppConfig.defaultPassword),
              _buildQuickLoginButton(context, 'طبيب (خالد)', 'dr.khaled@yourdoctor.com', AppConfig.defaultPassword),
              _buildQuickLoginButton(context, 'مريض (أحمد)', 'ahmad.patient@yourdoctor.com', AppConfig.defaultPassword),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickLoginButton(BuildContext context, String label, String email, String password) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: ElevatedButton(
        onPressed: () async {
          _emailController.text = email;
          _passwordController.text = password;
          bool success = await authProvider.login(email, password);
          if (success) {
            Navigator.of(context).pushReplacementNamed('/dashboard');
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: label.contains('مدير') ? Colors.red : (label.contains('طبيب') ? Colors.amber : Colors.blue),
          foregroundColor: label.contains('طبيب') ? Colors.black : Colors.white,
          minimumSize: const Size(double.infinity, 45),
        ),
        child: Text(label),
      ),
    );
  }
}
```

**`lib/screens/auth/register_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/general_data_provider.dart';
import '../../config/config.dart';
import '../../models/specialization.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _yearsExperienceController = TextEditingController();
  final TextEditingController _consultationFeeController = TextEditingController();
  final TextEditingController _profilePictureUrlController = TextEditingController();

  String _selectedRole = 'patient';
  int? _selectedSpecializationId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GeneralDataProvider>(context, listen: false).fetchAllSpecializations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final generalDataProvider = Provider.of<GeneralDataProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء حساب جديد')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'الاسم الكامل'),
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'كلمة المرور'),
                obscureText: true,
              ),
              TextField(
                controller: _passwordConfirmationController,
                decoration: const InputDecoration(labelText: 'تأكيد كلمة المرور'),
                obscureText: true,
              ),
              TextField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(labelText: 'رقم الهاتف (اختياري)'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(labelText: 'الدور'),
                items: const [
                  DropdownMenuItem(value: 'patient', child: Text('مريض')),
                  DropdownMenuItem(value: 'doctor', child: Text('طبيب')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
              ),
              if (_selectedRole == 'doctor') ...[
                const SizedBox(height: 20),
                Text('تفاصيل الطبيب', style: Theme.of(context).textTheme.headlineSmall),
                generalDataProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : DropdownButtonFormField<int>(
                        value: _selectedSpecializationId,
                        decoration: const InputDecoration(labelText: 'الاختصاص'),
                        items: generalDataProvider.specializations.map((spec) {
                          return DropdownMenuItem(
                            value: spec.id,
                            child: Text(spec.nameAr),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSpecializationId = value;
                          });
                        },
                      ),
                TextField(
                  controller: _bioController,
                  decoration: const InputDecoration(labelText: 'نبذة عن الطبيب (اختياري)'),
                  maxLines: 3,
                ),
                TextField(
                  controller: _yearsExperienceController,
                  decoration: const InputDecoration(labelText: 'سنوات الخبرة (اختياري)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _consultationFeeController,
                  decoration: const InputDecoration(labelText: 'رسوم الاستشارة (اختياري)'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _profilePictureUrlController,
                  decoration: const InputDecoration(labelText: 'رابط صورة الملف الشخصي (اختياري)'),
                  keyboardType: TextInputType.url,
                ),
              ],
              if (authProvider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    authProvider.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 20),
              authProvider.isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        Map<String, dynamic> userData = {
                          'full_name': _fullNameController.text,
                          'email': _emailController.text,
                          'password': _passwordController.text,
                          'password_confirmation': _passwordConfirmationController.text,
                          'phone_number': _phoneNumberController.text.isNotEmpty ? _phoneNumberController.text : null,
                          'role': _selectedRole,
                        };

                        if (_selectedRole == 'doctor') {
                          userData.addAll({
                            'specialization_id': _selectedSpecializationId,
                            'bio': _bioController.text.isNotEmpty ? _bioController.text : null,
                            'years_experience': int.tryParse(_yearsExperienceController.text),
                            'consultation_fee': double.tryParse(_consultationFeeController.text),
                            'profile_picture_url': _profilePictureUrlController.text.isNotEmpty ? _profilePictureUrlController.text : null,
                          });
                        }

                        bool success = await authProvider.register(userData);
                        if (success) {
                          Navigator.of(context).pushReplacementNamed('/dashboard');
                        }
                      },
                      child: const Text('تسجيل'),
                    ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Go back to login screen
                },
                child: const Text('لدي حساب بالفعل'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**`lib/screens/dashboard_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import 'auth/login_screen.dart';
import 'dashboards/patient_dashboard_screen.dart';
import 'dashboards/doctor_dashboard_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final User? currentUser = authProvider.user;

    if (currentUser == null) {
      // Should not happen if checkAuthStatus is properly handled, but good for safety
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginScreen()));
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('أهلاً بك, ${currentUser.name} (${currentUser.role})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: _buildBodyForRole(context, currentUser),
    );
  }

  Widget _buildBodyForRole(BuildContext context, User user) {
    switch (user.role) {
      case 'patient':
        return const PatientDashboardScreen();
      case 'doctor':
        return const DoctorDashboardScreen();
      case 'admin':
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('لوحة تحكم المدير', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 20),
              const Text('يمكن للمدير الوصول إلى لوحة التحكم عبر الويب.'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await Provider.of<AuthProvider>(context, listen: false).logout();
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                child: const Text('تسجيل الخروج'),
              ),
            ],
          ),
        );
      default:
        return const Center(child: Text('دور غير معروف.'));
    }
  }
}
```

**`lib/screens/dashboards/patient_dashboard_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/patient_provider.dart';
import '../../models/appointment.dart';
import '../../models/consultation.dart';
import '../../models/prescription.dart';
import '../../models/public_question.dart';
import '../../models/specialization.dart';
import '../../providers/general_data_provider.dart'; // To fetch specializations for booking
import 'package:intl/intl.dart'; // For date formatting

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _doctorSearchController = TextEditingController();
  final TextEditingController _newQuestionTitleController = TextEditingController();
  final TextEditingController _newQuestionDetailsController = TextEditingController();
  final TextEditingController _appointmentNotesController = TextEditingController();
  final TextEditingController _paymentAmountController = TextEditingController();
  final TextEditingController _paymentRefController = TextEditingController();
  final TextEditingController _paymentPurposeController = TextEditingController();

  int? _selectedDoctorForAppointment;
  DateTime? _selectedAppointmentDate;
  TimeOfDay? _selectedAppointmentTime;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadPatientData();
  }

  void _loadPatientData() {
    final patientProvider = Provider.of<PatientProvider>(context, listen: false);
    final generalProvider = Provider.of<GeneralDataProvider>(context, listen: false);

    patientProvider.fetchAppointments();
    patientProvider.fetchConsultations();
    patientProvider.fetchPrescriptions();
    patientProvider.fetchPublicQuestions();
    generalProvider.fetchBlogPosts(); // General for all users
    generalProvider.fetchAllSpecializations(); // For doctor search/booking
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _selectedAppointmentDate) {
      setState(() {
        _selectedAppointmentDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedAppointmentTime) {
      setState(() {
        _selectedAppointmentTime = picked;
      });
    }
  }

  void _showBookingDialog(BuildContext context) {
    final generalProvider = Provider.of<GeneralDataProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('حجز موعد جديد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'اختر طبيباً'),
                  value: _selectedDoctorForAppointment,
                  items: generalProvider.paginatedBlogPosts?.data // Assuming blog posts gives doctors
                      .map((post) => post.authorDoctor!) // Assuming authorDoctor is not null for blog posts
                      .where((doctor) => doctor != null && doctor.user != null) // Filter out nulls
                      .map<DropdownMenuItem<int>>((doctor) {
                        return DropdownMenuItem<int>(
                          value: doctor.id,
                          child: Text('د. ${doctor.user!.name} (${doctor.specialization?.nameAr ?? 'غير محدد'})'),
                        );
                      }).toList(),
                  onChanged: (int? newValue) {
                    _selectedDoctorForAppointment = newValue;
                  },
                ),
                ListTile(
                  title: Text(_selectedAppointmentDate == null ? 'اختر التاريخ' : DateFormat('yyyy-MM-dd').format(_selectedAppointmentDate!)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(dialogContext),
                ),
                ListTile(
                  title: Text(_selectedAppointmentTime == null ? 'اختر الوقت' : _selectedAppointmentTime!.format(dialogContext)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () => _selectTime(dialogContext),
                ),
                TextField(
                  controller: _appointmentNotesController,
                  decoration: const InputDecoration(labelText: 'ملاحظات المريض (اختياري)'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text('حجز'),
              onPressed: () async {
                if (_selectedDoctorForAppointment != null && _selectedAppointmentDate != null && _selectedAppointmentTime != null) {
                  final DateTime fullDateTime = DateTime(
                    _selectedAppointmentDate!.year,
                    _selectedAppointmentDate!.month,
                    _selectedAppointmentDate!.day,
                    _selectedAppointmentTime!.hour,
                    _selectedAppointmentTime!.minute,
                  );
                  bool success = await Provider.of<PatientProvider>(dialogContext, listen: false).bookAppointment(
                    _selectedDoctorForAppointment!,
                    fullDateTime,
                    30, // Default duration
                    _appointmentNotesController.text,
                  );
                  if (success) {
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حجز الموعد بنجاح!')));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(Provider.of<PatientProvider>(dialogContext, listen: false).errorMessage ?? 'فشل حجز الموعد.')));
                  }
                } else {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('الرجاء ملء جميع الحقول المطلوبة.')));
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showInitiatePaymentDialog(BuildContext context) {
    int? selectedConsultationId;
    int? selectedAppointmentId;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder( // Use StatefulBuilder to update dialog content
          builder: (context, setState) {
            final patientProvider = Provider.of<PatientProvider>(context, listen: false);
            final consultations = patientProvider.consultations?.data ?? [];
            final appointments = patientProvider.appointments?.data ?? [];

            return AlertDialog(
              title: const Text('بدء عملية دفع'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: _paymentAmountController,
                      decoration: const InputDecoration(labelText: 'المبلغ'),
                      keyboardType: TextInputType.number,
                    ),
                    TextField(
                      controller: _paymentRefController,
                      decoration: const InputDecoration(labelText: 'رقم مرجع الحوالة (اختياري)'),
                    ),
                    DropdownButtonFormField<String>(
                      value: _paymentPurposeController.text.isEmpty ? null : _paymentPurposeController.text,
                      decoration: const InputDecoration(labelText: 'الغرض'),
                      items: const [
                        DropdownMenuItem(value: 'consultation', child: Text('استشارة')),
                        DropdownMenuItem(value: 'appointment_booking', child: Text('حجز موعد')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _paymentPurposeController.text = value!;
                          selectedConsultationId = null;
                          selectedAppointmentId = null;
                        });
                      },
                    ),
                    if (_paymentPurposeController.text == 'consultation')
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(labelText: 'اختر استشارة'),
                        value: selectedConsultationId,
                        items: consultations.map((consultation) {
                          return DropdownMenuItem(
                            value: consultation.id,
                            child: Text('استشارة مع د. ${consultation.doctor?.name ?? 'غير معروف'} (${consultation.id})'),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          selectedConsultationId = newValue;
                        },
                      ),
                    if (_paymentPurposeController.text == 'appointment_booking')
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(labelText: 'اختر موعد'),
                        value: selectedAppointmentId,
                        items: appointments.map((appointment) {
                          return DropdownMenuItem(
                            value: appointment.id,
                            child: Text('موعد مع د. ${appointment.doctor?.user?.name ?? 'غير معروف'} (${appointment.id})'),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          selectedAppointmentId = newValue;
                        },
                      ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('إلغاء'),
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text('دفع'),
                  onPressed: () async {
                    if (_paymentAmountController.text.isEmpty || _paymentPurposeController.text.isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('الرجاء ملء جميع الحقول المطلوبة.')));
                      return;
                    }

                    Map<String, dynamic> paymentData = {
                      'amount': double.parse(_paymentAmountController.text),
                      'currency': AppConfig.defaultCurrency, // Use default currency
                      'payment_method': 'bank_transfer', // As per project spec
                      'purpose': _paymentPurposeController.text,
                      'transaction_reference': _paymentRefController.text.isNotEmpty ? _paymentRefController.text : null,
                    };

                    if (_paymentPurposeController.text == 'consultation' && selectedConsultationId != null) {
                      paymentData['consultation_id'] = selectedConsultationId;
                    } else if (_paymentPurposeController.text == 'appointment_booking' && selectedAppointmentId != null) {
                      paymentData['appointment_id'] = selectedAppointmentId;
                    } else {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('الرجاء ربط الدفعة باستشارة أو موعد.')));
                      return;
                    }

                    bool success = await patientProvider.initiatePayment(paymentData);
                    if (success) {
                      Navigator.of(dialogContext).pop();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تسجيل طلب الدفع بنجاح!')));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(patientProvider.errorMessage ?? 'فشل بدء عملية الدفع.')));
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final patientProvider = Provider.of<PatientProvider>(context);
    final generalProvider = Provider.of<GeneralDataProvider>(context);

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'مواعيدي'),
            Tab(text: 'استشاراتي'),
            Tab(text: 'وصفاتي'),
            Tab(text: 'أسئلتي العامة'),
            Tab(text: 'المدونة'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: مواعيدي
              patientProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildAppointmentsList(patientProvider.appointments?.data ?? []),
              // Tab 2: استشاراتي
              patientProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildConsultationsList(patientProvider.consultations?.data ?? []),
              // Tab 3: وصفاتي
              patientProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildPrescriptionsList(patientProvider.prescriptions?.data ?? []),
              // Tab 4: أسئلتي العامة
              patientProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildPublicQuestionsList(patientProvider.publicQuestions?.data ?? []),
              // Tab 5: المدونة
              generalProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildBlogPostsList(generalProvider.blogPosts),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () => _showBookingDialog(context),
                child: const Text('حجز موعد'),
              ),
              ElevatedButton(
                onPressed: () => _showInitiatePaymentDialog(context),
                child: const Text('دفع فاتورة'),
              ),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        title: const Text('طرح سؤال عام جديد'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: _newQuestionTitleController,
                              decoration: const InputDecoration(labelText: 'عنوان السؤال'),
                            ),
                            TextField(
                              controller: _newQuestionDetailsController,
                              decoration: const InputDecoration(labelText: 'تفاصيل الأعراض'),
                              maxLines: 5,
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('إلغاء'),
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                          ),
                          ElevatedButton(
                            child: const Text('طرح'),
                            onPressed: () async {
                              bool success = await patientProvider.postPublicQuestion(
                                _newQuestionTitleController.text,
                                _newQuestionDetailsController.text,
                              );
                              if (success) {
                                Navigator.of(dialogContext).pop();
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم طرح السؤال بنجاح!')));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(patientProvider.errorMessage ?? 'فشل طرح السؤال.')));
                              }
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('اطرح سؤال عام'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentsList(List<Appointment> appointments) {
    if (appointments.isEmpty) {
      return const Center(child: Text('لا توجد مواعيد حالياً.'));
    }
    return ListView.builder(
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('موعد مع د. ${appointment.doctor?.user?.name ?? 'غير معروف'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('الاختصاص: ${appointment.doctor?.specialization?.nameAr ?? 'غير محدد'}'),
                Text('التاريخ والوقت: ${DateFormat('yyyy-MM-dd HH:mm').format(appointment.appointmentDatetime)}'),
                Text('الحالة: ${appointment.status}'),
                Text('ملاحظاتي: ${appointment.patientNotes ?? 'لا توجد'}'),
                if (appointment.status == 'scheduled')
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: () async {
                        bool success = await Provider.of<PatientProvider>(context, listen: false).cancelAppointment(appointment.id);
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إلغاء الموعد.')));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(Provider.of<PatientProvider>(context, listen: false).errorMessage ?? 'فشل الإلغاء.')));
                        }
                      },
                      child: const Text('إلغاء الموعد'),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildConsultationsList(List<Consultation> consultations) {
    if (consultations.isEmpty) {
      return const Center(child: Text('لا توجد استشارات حالياً.'));
    }
    return ListView.builder(
      itemCount: consultations.length,
      itemBuilder: (context, index) {
        final consultation = consultations[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('استشارة مع د. ${consultation.doctor?.name ?? 'غير معروف'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('بداية الاستشارة: ${DateFormat('yyyy-MM-dd HH:mm').format(consultation.startTime)}'),
                Text('الحالة: ${consultation.status}'),
                if (consultation.endTime != null) Text('نهاية الاستشارة: ${DateFormat('yyyy-MM-dd HH:mm').format(consultation.endTime!)}'),
                // Here you would navigate to a chat screen for active consultations
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrescriptionsList(List<Prescription> prescriptions) {
    if (prescriptions.isEmpty) {
      return const Center(child: Text('لا توجد وصفات طبية حالياً.'));
    }
    return ListView.builder(
      itemCount: prescriptions.length,
      itemBuilder: (context, index) {
        final prescription = prescriptions[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('وصفة من د. ${prescription.doctor?.name ?? 'غير معروف'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('تاريخ الإصدار: ${DateFormat('yyyy-MM-dd').format(prescription.issueDate)}'),
                Text('تفاصيل الأدوية: ${prescription.medicationDetails}'),
                Text('تعليمات: ${prescription.instructions ?? 'لا توجد'}'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPublicQuestionsList(List<PublicQuestion> questions) {
    if (questions.isEmpty) {
      return const Center(child: Text('لا توجد أسئلة عامة حالياً.'));
    }
    return ListView.builder(
      itemCount: questions.length,
      itemBuilder: (context, index) {
        final question = questions[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('سؤالي: ${question.title}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('التفاصيل: ${question.details}'),
                Text('تاريخ الطرح: ${DateFormat('yyyy-MM-dd HH:mm').format(question.createdAt)}'),
                const Text('الإجابات:', style: TextStyle(fontWeight: FontWeight.bold)),
                if (question.answers.isEmpty)
                  const Text('  لا توجد إجابات بعد.')
                else
                  ...question.answers.map((answer) => Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                    child: Text('  ${answer.author?.name ?? 'غير معروف'}: ${answer.answerText}'),
                  )),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBlogPostsList(List<BlogPost> blogPosts) {
    if (blogPosts.isEmpty) {
      return const Center(child: Text('لا توجد مقالات في المدونة حالياً.'));
    }
    return ListView.builder(
      itemCount: blogPosts.length,
      itemBuilder: (context, index) {
        final post = blogPosts[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('العنوان: ${post.title}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('الكاتب: د. ${post.authorDoctor?.user?.name ?? 'غير معروف'}'),
                Text('تاريخ النشر: ${post.publishedAt != null ? DateFormat('yyyy-MM-dd').format(post.publishedAt!) : 'غير منشور'}'),
                Text('المحتوى (مختصر): ${post.content.length > 100 ? '${post.content.substring(0, 100)}...' : post.content}'),
                // You might add a button to view full post details or comments
              ],
            ),
          ),
        );
      },
    );
  }
}
```

**`lib/screens/dashboards/doctor_dashboard_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/doctor_provider.dart';
import '../../models/appointment.dart';
import '../../models/consultation.dart';
import '../../models/public_question.dart';
import '../../models/blog_post.dart';
import 'package:intl/intl.dart'; // For date formatting

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _answerController = TextEditingController();
  final TextEditingController _medicationDetailsController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _blogPostTitleController = TextEditingController();
  final TextEditingController _blogPostContentController = TextEditingController();
  final TextEditingController _blogPostImageUrlController = TextEditingController();
  final TextEditingController _blogPostVideoUrlController = TextEditingController();

  String _selectedBlogPostStatus = 'published'; // Default for new posts

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadDoctorData();
  }

  void _loadDoctorData() {
    final doctorProvider = Provider.of<DoctorProvider>(context, listen: false);
    doctorProvider.fetchDoctorProfile();
    doctorProvider.fetchDoctorAvailability();
    doctorProvider.fetchDoctorAppointments();
    doctorProvider.fetchDoctorConsultations();
    doctorProvider.fetchUnansweredPublicQuestions();
    doctorProvider.fetchDoctorBlogPosts();
  }

  void _showAnswerDialog(BuildContext context, PublicQuestion question) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('الإجابة على: ${question.title}'),
          content: TextField(
            controller: _answerController,
            decoration: const InputDecoration(labelText: 'نص الإجابة'),
            maxLines: 5,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text('إرسال الإجابة'),
              onPressed: () async {
                bool success = await Provider.of<DoctorProvider>(dialogContext, listen: false).answerPublicQuestion(
                  question.id,
                  _answerController.text,
                );
                if (success) {
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال الإجابة بنجاح!')));
                  _answerController.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(Provider.of<DoctorProvider>(dialogContext, listen: false).errorMessage ?? 'فشل إرسال الإجابة.')));
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showPrescriptionDialog(BuildContext context, Consultation consultation) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('إصدار وصفة لـ: ${consultation.patient?.name ?? 'المريض'}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _medicationDetailsController,
                  decoration: const InputDecoration(labelText: 'تفاصيل الأدوية والجرعات'),
                  maxLines: 5,
                ),
                TextField(
                  controller: _instructionsController,
                  decoration: const InputDecoration(labelText: 'تعليمات إضافية (اختياري)'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text('إصدار الوصفة'),
              onPressed: () async {
                bool success = await Provider.of<DoctorProvider>(dialogContext, listen: false).issuePrescription(
                  consultation.id,
                  _medicationDetailsController.text,
                  instructions: _instructionsController.text.isNotEmpty ? _instructionsController.text : null,
                );
                if (success) {
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إصدار الوصفة بنجاح!')));
                  _medicationDetailsController.clear();
                  _instructionsController.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(Provider.of<DoctorProvider>(dialogContext, listen: false).errorMessage ?? 'فشل إصدار الوصفة.')));
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showBlogPostDialog(BuildContext context, {BlogPost? post}) {
    bool isEditing = post != null;
    if (isEditing) {
      _blogPostTitleController.text = post.title;
      _blogPostContentController.text = post.content;
      _blogPostImageUrlController.text = post.featuredImageUrl ?? '';
      _blogPostVideoUrlController.text = post.videoUrl ?? '';
      _selectedBlogPostStatus = post.status;
    } else {
      _blogPostTitleController.clear();
      _blogPostContentController.clear();
      _blogPostImageUrlController.clear();
      _blogPostVideoUrlController.clear();
      _selectedBlogPostStatus = 'published';
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isEditing ? 'تعديل مقال' : 'إنشاء مقال جديد'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: _blogPostTitleController, decoration: const InputDecoration(labelText: 'عنوان المقال')),
                    TextField(controller: _blogPostContentController, decoration: const InputDecoration(labelText: 'محتوى المقال'), maxLines: 8),
                    TextField(controller: _blogPostImageUrlController, decoration: const InputDecoration(labelText: 'رابط صورة بارزة (اختياري)'), keyboardType: TextInputType.url),
                    TextField(controller: _blogPostVideoUrlController, decoration: const InputDecoration(labelText: 'رابط فيديو (اختياري)'), keyboardType: TextInputType.url),
                    DropdownButtonFormField<String>(
                      value: _selectedBlogPostStatus,
                      decoration: const InputDecoration(labelText: 'الحالة'),
                      items: const [
                        DropdownMenuItem(value: 'draft', child: Text('مسودة')),
                        DropdownMenuItem(value: 'published', child: Text('منشور')),
                        DropdownMenuItem(value: 'archived', child: Text('أرشيف')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedBlogPostStatus = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(child: const Text('إلغاء'), onPressed: () => Navigator.of(dialogContext).pop()),
                ElevatedButton(
                  child: Text(isEditing ? 'تحديث' : 'إنشاء'),
                  onPressed: () async {
                    Map<String, dynamic> postData = {
                      'title': _blogPostTitleController.text,
                      'content': _blogPostContentController.text,
                      'featured_image_url': _blogPostImageUrlController.text.isNotEmpty ? _blogPostImageUrlController.text : null,
                      'video_url': _blogPostVideoUrlController.text.isNotEmpty ? _blogPostVideoUrlController.text : null,
                      'status': _selectedBlogPostStatus,
                      'published_at': _selectedBlogPostStatus == 'published' ? DateTime.now().toIso8601String() : null,
                    };
                    bool success;
                    final doctorProvider = Provider.of<DoctorProvider>(dialogContext, listen: false);
                    if (isEditing) {
                      success = await doctorProvider.updateBlogPost(post!.id, postData);
                    } else {
                      success = await doctorProvider.createBlogPost(postData);
                    }
                    if (success) {
                      Navigator.of(dialogContext).pop();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEditing ? 'تم تحديث المقال بنجاح!' : 'تم إنشاء المقال بنجاح!')));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(doctorProvider.errorMessage ?? 'فشل العملية.')));
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final doctorProvider = Provider.of<DoctorProvider>(context);

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'ملفي الشخصي'),
            Tab(text: 'مواعيدي'),
            Tab(text: 'استشاراتي'),
            Tab(text: 'أسئلة عامة (غير مجابة)'),
            Tab(text: 'مقالاتي'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: ملفي الشخصي
              doctorProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildProfileTab(context, doctorProvider),
              // Tab 2: مواعيدي
              doctorProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildAppointmentsList(doctorProvider.appointments?.data ?? []),
              // Tab 3: استشاراتي
              doctorProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildConsultationsList(doctorProvider.consultations?.data ?? []),
              // Tab 4: أسئلة عامة (غير مجابة)
              doctorProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildUnansweredQuestionsList(doctorProvider.unansweredQuestions?.data ?? []),
              // Tab 5: مقالاتي
              doctorProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildBlogPostsList(context, doctorProvider.blogPosts?.data ?? []),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileTab(BuildContext context, DoctorProvider doctorProvider) {
    if (doctorProvider.doctorProfile == null) {
      return const Center(child: Text('ملف الطبيب غير موجود.'));
    }
    final profile = doctorProvider.doctorProfile!;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(profile.profilePictureUrl),
          ),
          const SizedBox(height: 10),
          Text('الاسم: ${profile.user?.name ?? 'غير معروف'}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text('البريد الإلكتروني: ${profile.user?.email ?? 'غير معروف'}'),
          Text('الاختصاص: ${profile.specialization?.nameAr ?? 'غير محدد'}'),
          Text('سنوات الخبرة: ${profile.yearsExperience}'),
          Text('رسوم الاستشارة: ${profile.consultationFee} ${AppConfig.defaultCurrency}'),
          Text('نبذة: ${profile.bio}'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Navigate to a screen to edit profile
              // For simplicity, we can show a dialog here or navigate to a dedicated screen
            },
            child: const Text('تعديل الملف الشخصي'),
          ),
          const Divider(),
          const Text('جدول التوفر:', style: TextStyle(fontWeight: FontWeight.bold)),
          if (doctorProvider.availability.isEmpty)
            const Text('لا يوجد جدول توفر محدد.')
          else
            ...doctorProvider.availability.map((slot) => Text(
                'يوم ${slot.dayOfWeek} من ${slot.startTime} إلى ${slot.endTime} ${slot.isAvailable ? '(متاح)' : '(غير متاح)'}'
            )),
          ElevatedButton(
            onPressed: () {
              // Show dialog to update availability
            },
            child: const Text('تعديل جدول التوفر'),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList(List<Appointment> appointments) {
    if (appointments.isEmpty) {
      return const Center(child: Text('لا توجد مواعيد حالياً.'));
    }
    return ListView.builder(
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('موعد مع ${appointment.patient?.name ?? 'مريض غير معروف'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('التاريخ والوقت: ${DateFormat('yyyy-MM-dd HH:mm').format(appointment.appointmentDatetime)}'),
                Text('الحالة: ${appointment.status}'),
                Text('ملاحظات المريض: ${appointment.patientNotes ?? 'لا توجد'}'),
                if (appointment.status == 'scheduled')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          bool success = await Provider.of<DoctorProvider>(context, listen: false).updateAppointmentStatus(appointment.id, 'completed');
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تأكيد اكتمال الموعد.')));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(Provider.of<DoctorProvider>(context, listen: false).errorMessage ?? 'فشل التحديث.')));
                          }
                        },
                        child: const Text('إكمال الموعد'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          bool success = await Provider.of<DoctorProvider>(context, listen: false).updateAppointmentStatus(appointment.id, 'cancelled_doctor');
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إلغاء الموعد بواسطة الطبيب.')));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(Provider.of<DoctorProvider>(context, listen: false).errorMessage ?? 'فشل الإلغاء.')));
                          }
                        },
                        child: const Text('إلغاء'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildConsultationsList(List<Consultation> consultations) {
    if (consultations.isEmpty) {
      return const Center(child: Text('لا توجد استشارات حالياً.'));
    }
    return ListView.builder(
      itemCount: consultations.length,
      itemBuilder: (context, index) {
        final consultation = consultations[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('استشارة مع ${consultation.patient?.name ?? 'مريض غير معروف'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('بداية الاستشارة: ${DateFormat('yyyy-MM-dd HH:mm').format(consultation.startTime)}'),
                Text('الحالة: ${consultation.status}'),
                if (consultation.status == 'active')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Placeholder for chat screen navigation
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('شاشة الدردشة لم يتم تصميمها بعد.')));
                        },
                        child: const Text('بدء الدردشة'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _showPrescriptionDialog(context, consultation),
                        child: const Text('إصدار وصفة'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          bool success = await Provider.of<DoctorProvider>(context, listen: false).closeConsultation(consultation.id);
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إغلاق الاستشارة.')));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(Provider.of<DoctorProvider>(context, listen: false).errorMessage ?? 'فشل الإغلاق.')));
                          }
                        },
                        child: const Text('إغلاق الاستشارة'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUnansweredQuestionsList(List<PublicQuestion> questions) {
    if (questions.isEmpty) {
      return const Center(child: Text('لا توجد أسئلة عامة غير مجابة حالياً.'));
    }
    return ListView.builder(
      itemCount: questions.length,
      itemBuilder: (context, index) {
        final question = questions[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('سؤال من: ${question.author?.name ?? 'مريض غير معروف'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('العنوان: ${question.title}'),
                Text('التفاصيل: ${question.details}'),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ElevatedButton(
                    onPressed: () => _showAnswerDialog(context, question),
                    child: const Text('الإجابة'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBlogPostsList(BuildContext context, List<BlogPost> blogPosts) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () => _showBlogPostDialog(context),
            child: const Text('إنشاء مقال جديد'),
          ),
        ),
        Expanded(
          child: blogPosts.isEmpty
              ? const Center(child: Text('لا توجد مقالات مدونة حالياً.'))
              : ListView.builder(
                  itemCount: blogPosts.length,
                  itemBuilder: (context, index) {
                    final post = blogPosts[index];
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('العنوان: ${post.title}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('الحالة: ${post.status}'),
                            Text('تاريخ النشر: ${post.publishedAt != null ? DateFormat('yyyy-MM-dd').format(post.publishedAt!) : 'غير منشور'}'),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () => _showBlogPostDialog(context, post: post),
                                  child: const Text('تعديل'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () async {
                                    bool success = await Provider.of<DoctorProvider>(context, listen: false).deleteBlogPost(post.id);
                                    if (success) {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف المقال.')));
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(Provider.of<DoctorProvider>(context, listen: false).errorMessage ?? 'فشل الحذف.')));
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  child: const Text('حذف'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
```

---

**الخطوة 9: تشغيل التطبيق**

1.  تأكد أن خادم Laravel يعمل (على `http://127.0.0.1:8000/api` أو `https://darkred-tiger-154754.hostingersite.com/api` بناءً على تكوين `.env` في Laravel).
2.  افتح محاكي (emulator) أو قم بتوصيل جهاز حقيقي.
3.  في الطرفية داخل مجلد مشروع Flutter، نفذ:

    ```bash
    flutter run
    ```

الآن يجب أن يعمل التطبيق، وتظهر شاشة تسجيل الدخول. يمكنك استخدام الأزرار السريعة لتسجيل الدخول بأدوار مختلفة وتجربة الواجهات الأولية. سيتم طباعة جميع استجابات الـ API في نافذة "Debug Console" في محرر الأكواد لديك.