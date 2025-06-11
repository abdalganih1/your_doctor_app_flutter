import 'dart:convert';
import 'user.dart';

class PublicQuestionAnswer {
  final int id;
  final int questionId;
  final int authorUserId;
  final String answerText;
  final DateTime created_at;
  final DateTime updated_at;
  final User? author; // Author can be a patient or doctor

  PublicQuestionAnswer({
    required this.id,
    required this.questionId,
    required this.authorUserId,
    required this.answerText,
    required this.created_at,
    required this.updated_at,
    this.author,
  });

factory PublicQuestionAnswer.fromMap(Map<String, dynamic> map) {
  return PublicQuestionAnswer(
    id: map['answer_id'] as int,
    questionId: map['question_id'] as int,
    authorUserId: map['author_user_id'] as int,
    answerText: map['answer_text'] as String,
    created_at: DateTime.parse(map['created_at'] as String),
    updated_at: DateTime.parse(map['updated_at'] as String),
    author: map['author'] != null
        ? User.fromMap(map['author'] as Map<String, dynamic>)
        : null,
  );
}


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questionId': questionId,
      'authorUserId': authorUserId,
      'answerText': answerText,
      'created_at': created_at.toIso8601String(),
      'updated_at': updated_at.toIso8601String(),
      'author': author?.toMap(),
    };
  }

  String toJson() => json.encode(toMap());
  factory PublicQuestionAnswer.fromJson(String source) =>
      PublicQuestionAnswer.fromMap(json.decode(source) as Map<String, dynamic>);
}
