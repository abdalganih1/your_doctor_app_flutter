import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:your_doctor_app_flutter/models/message.dart';
import '../providers/chat_provider.dart';
import '../providers/auth_provider.dart'; // لجلب User ID للمستخدم الحالي
import '../models/consultation.dart'; // لاستقبال كائن الاستشارة

class ChatScreen extends StatefulWidget {
  final Consultation consultation;

  const ChatScreen({super.key, required this.consultation});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChatMessages();
    });
  }

  void _loadChatMessages() {
    Provider.of<ChatProvider>(context, listen: false).loadMessagesForConsultation(widget.consultation.id);
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final String messageText = _messageController.text.trim();
    _messageController.clear(); // مسح حقل الإدخال فوراً

    // إرسال الرسالة عبر المزود
    bool success = await chatProvider.sendMessage(messageText);

    if (success) {
      // قم بالتمرير إلى الأسفل فور إرسال الرسالة
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      // عرض رسالة خطأ إذا فشل الإرسال
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(chatProvider.errorMessage ?? 'فشل إرسال الرسالة.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context); // للتعرف على المستخدم الحالي

    final currentUserId = authProvider.user?.id; // معرف المستخدم الذي سجل الدخول

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الدردشة مع ${widget.consultation.doctor?.name ?? widget.consultation.patient?.name ?? 'المستخدم'}',
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: chatProvider.isLoading && chatProvider.messages.isEmpty // فقط عند التحميل الأولي
                ? const Center(child: CircularProgressIndicator())
                : chatProvider.messages.isEmpty
                    ? const Center(child: Text('لا توجد رسائل في هذه الاستشارة بعد.'))
                    : ListView.builder(
                        controller: _scrollController, // ربط الـ ScrollController
                        padding: const EdgeInsets.all(8.0),
                        itemCount: chatProvider.messages.length,
                        itemBuilder: (context, index) {
                          final message = chatProvider.messages[index];
                          final bool isMe = message.senderUserId == currentUserId;
                          return _buildMessageBubble(message, isMe);
                        },
                      ),
          ),
          _buildMessageInput(context),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[200] : Colors.grey[300],
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isMe ? 'أنا' : message.sender?.name ?? 'مستخدم',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isMe ? Colors.blue[800] : Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4.0),
            Text(message.messageContent),
            const SizedBox(height: 4.0),
            Text(
              DateFormat('HH:mm').format(message.sentAt),
              style: const TextStyle(fontSize: 10.0, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'اكتب رسالتك...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              ),
              minLines: 1,
              maxLines: 5,
            ),
          ),
          const SizedBox(width: 8.0),
          FloatingActionButton(
            onPressed: _sendMessage,
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    // مهم: مسح الرسائل من المزود عند الخروج من الشاشة
    Provider.of<ChatProvider>(context, listen: false).clearMessages();
    super.dispose();
  }
}