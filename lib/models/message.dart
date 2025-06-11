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
    id: map['message_id'] as int,
    consultationId: map['consultation_id'] as int,
    senderUserId: map['sender_user_id'] as int,
    messageContent: map['message_content'] as String,
    sentAt:  DateTime.parse((map['sent_at'] as String?) ?? DateTime.now().toIso8601String()),
    isRead: map['is_read'] as bool? ??false,
    attachmentUrl: map['attachment_url'] as String?,
    attachmentType: map['attachment_type'] as String?,
    sender: map['sender'] != null
        ? User.fromMap(map['sender'] as Map<String, dynamic>)
        : null,
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
