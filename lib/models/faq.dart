import 'dart:convert';
import 'user.dart';

class Faq {
  final int id;
  final String question;
  final String answer;
  final String? category;
  final int? createdByAdminId;
  final DateTime created_at;
  final DateTime updated_at;
  final User? createdByAdmin; // Admin user who created it

  Faq({
    required this.id,
    required this.question,
    required this.answer,
    this.category,
    this.createdByAdminId,
    required this.created_at,
    required this.updated_at,
    this.createdByAdmin,
  });

  factory Faq.fromMap(Map<String, dynamic> map) {
    return Faq(
      id: map['faq_id'] as int,
      question: map['question'] as String,
      answer: map['answer'] as String,
      category: map['category'] as String?,
      createdByAdminId: map['created_by_admin_id'] as int?,
      created_at: DateTime.parse(map['created_at'] as String),
      updated_at: DateTime.parse(map['updated_at'] as String),
      createdByAdmin: map['created_by_admin_id'] != null
          ? User.fromMap(map['created_by_admin_id'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'category': category,
      'createdByAdminId': createdByAdminId,
      'created_at': created_at.toIso8601String(),
      'updated_at': updated_at.toIso8601String(),
      'createdByAdmin': createdByAdmin?.toMap(),
    };
  }

  String toJson() => json.encode(toMap());
  factory Faq.fromJson(String source) =>
      Faq.fromMap(json.decode(source) as Map<String, dynamic>);
}
