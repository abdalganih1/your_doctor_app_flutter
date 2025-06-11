import 'dart:convert';
import 'user.dart';

class BlogComment {
  final int id;
  final int postId;
  final int authorUserId;
  final String commentText;
  final DateTime created_at;
  final DateTime updated_at;
  final User? author;

  BlogComment({
    required this.id,
    required this.postId,
    required this.authorUserId,
    required this.commentText,
    required this.created_at,
    required this.updated_at,
    this.author,
  });

  factory BlogComment.fromMap(Map<String, dynamic> map) {
    return BlogComment(
      id: map['id'] as int,
      postId: map['post_id'] as int,
      authorUserId: map['author_doctor_id'] as int,
      commentText: map['comment_text'] as String,
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
      'postId': postId,
      'authorUserId': authorUserId,
      'commentText': commentText,
      'created_at': created_at.toIso8601String(),
      'updated_at': updated_at.toIso8601String(),
      'author': author?.toMap(),
    };
  }

  String toJson() => json.encode(toMap());
  factory BlogComment.fromJson(String source) =>
      BlogComment.fromMap(json.decode(source) as Map<String, dynamic>);
}
