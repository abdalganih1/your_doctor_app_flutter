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
