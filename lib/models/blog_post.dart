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
  final DateTime? published_at;
  final DateTime created_at;
  final DateTime updated_at;
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
    this.published_at,
    required this.created_at,
    required this.updated_at,
    this.authorDoctor,
    required this.comments,
  });

  factory BlogPost.fromMap(Map<String, dynamic> map) {
    return BlogPost(
      id: map['post_id'] as int,
      authorDoctorId: map['author_doctor_id'] as int,
      title: map['title'] as String,
      content: map['content'] as String,
      featuredImageUrl: map['featured_image_url'] as String?,
      videoUrl: map['video_url'] as String?,
      status: map['status'] as String,
      published_at: map['published_at'] != null
          ? DateTime.parse(map['published_at'] as String)
          : null,
      created_at: DateTime.parse(map['created_at'] as String),
      updated_at: DateTime.parse(map['updated_at'] as String),
      authorDoctor: map['author_doctor'] != null
          ? DoctorProfile.fromMap(map['author_doctor'] as Map<String, dynamic>)
          : null,
      comments: (map['comments'] as List<dynamic>?)
              ?.map((e) => BlogComment.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
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
      'published_at': published_at?.toIso8601String(),
      'created_at': created_at.toIso8601String(),
      'updated_at': updated_at.toIso8601String(),
      'authorDoctor': authorDoctor?.toMap(),
      'comments': comments.map((e) => e.toMap()).toList(),
    };
  }

  String toJson() => json.encode(toMap());
  factory BlogPost.fromJson(String source) =>
      BlogPost.fromMap(json.decode(source) as Map<String, dynamic>);
}
