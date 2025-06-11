import 'dart:convert';
import 'user.dart';
import 'public_question_answer.dart';

class PublicQuestion {
  final int id;
  final int authorUserId;
  final String title;
  final String details;
  final DateTime created_at;
  final DateTime updated_at;
  final User? author;
  final List<PublicQuestionAnswer> answers;

  PublicQuestion({
    required this.id,
    required this.authorUserId,
    required this.title,
    required this.details,
    required this.created_at,
    required this.updated_at,
    this.author,
    required this.answers,
  });

factory PublicQuestion.fromMap(Map<String, dynamic> map) {
  return PublicQuestion(
    id: map['question_id'] as int,
    authorUserId: map['author_user_id'] as int,
    title: map['title'] as String,
    details: map['details'] as String,
    created_at: DateTime.parse(map['created_at'] as String),
    updated_at: DateTime.parse(map['updated_at'] as String),
    author: map['author'] != null
        ? User.fromMap(map['author'] as Map<String, dynamic>)
        : null,
    answers: (map['answers'] as List<dynamic>?)
            ?.map((e) => PublicQuestionAnswer.fromMap(e as Map<String, dynamic>))
            .toList() ??
        [],
  );
}


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorUserId': authorUserId,
      'title': title,
      'details': details,
      'created_at': created_at.toIso8601String(),
      'updated_at': updated_at.toIso8601String(),
      'author': author?.toMap(),
      'answers': answers.map((e) => e.toMap()).toList(),
    };
  }

  String toJson() => json.encode(toMap());
  factory PublicQuestion.fromJson(String source) =>
      PublicQuestion.fromMap(json.decode(source) as Map<String, dynamic>);
}
