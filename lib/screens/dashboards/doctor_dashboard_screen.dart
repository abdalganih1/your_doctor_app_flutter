import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_doctor_app_flutter/screens/chat_screen.dart';
import '../../providers/doctor_provider.dart';
import '../../models/appointment.dart';
import '../../models/consultation.dart';
import '../../models/public_question.dart';
import '../../models/blog_post.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../../config/config.dart'; // Import AppConfig for defaultCurrency

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
    // تأخير استدعاء تحميل البيانات حتى اكتمال بناء الإطار الأول
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDoctorData();
    });
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
                // التحقق من context.mounted قبل استخدام Provider
                if (!dialogContext.mounted) return;
                bool success = await Provider.of<DoctorProvider>(dialogContext, listen: false).answerPublicQuestion(
                  question.id,
                  _answerController.text,
                );
                if (success) {
                  if (!dialogContext.mounted) return;
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال الإجابة بنجاح!')));
                  _answerController.clear();
                } else {
                  if (!dialogContext.mounted) return;
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
                // التحقق من context.mounted قبل استخدام Provider
                if (!dialogContext.mounted) return;
                bool success = await Provider.of<DoctorProvider>(dialogContext, listen: false).issuePrescription(
                  consultation.id,
                  _medicationDetailsController.text,
                  instructions: _instructionsController.text.isNotEmpty ? _instructionsController.text : null,
                );
                if (success) {
                  if (!dialogContext.mounted) return;
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إصدار الوصفة بنجاح!')));
                  _medicationDetailsController.clear();
                  _instructionsController.clear();
                } else {
                  if (!dialogContext.mounted) return;
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
                    // التحقق من context.mounted قبل استخدام Provider
                    if (!dialogContext.mounted) return;
                    if (isEditing) {
                      success = await doctorProvider.updateBlogPost(post.id, postData);
                    } else {
                      success = await doctorProvider.createBlogPost(postData);
                    }
                    if (success) {
                      if (!dialogContext.mounted) return;
                      Navigator.of(dialogContext).pop();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEditing ? 'تم تحديث المقال بنجاح!' : 'تم إنشاء المقال بنجاح!')));
                    } else {
                      if (!dialogContext.mounted) return;
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
          Text('سنوات الخبرة: ${profile.yearsExperience ?? 'غير محدد'}'), // Handle nullable int
          Text('رسوم الاستشارة: ${profile.consultationFee ?? 'غير محدد'} ${AppConfig.defaultCurrency}'), // Handle nullable double
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
                          // التحقق من context.mounted قبل استخدام Provider
                          if (!context.mounted) return;
                          bool success = await Provider.of<DoctorProvider>(context, listen: false).updateAppointmentStatus(appointment.id, 'completed');
                          if (success) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تأكيد اكتمال الموعد.')));
                          } else {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(Provider.of<DoctorProvider>(context, listen: false).errorMessage ?? 'فشل التحديث.')));
                          }
                        },
                        child: const Text('إكمال الموعد'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          // التحقق من context.mounted قبل استخدام Provider
                          if (!context.mounted) return;
                          bool success = await Provider.of<DoctorProvider>(context, listen: false).updateAppointmentStatus(appointment.id, 'cancelled_doctor');
                          if (success) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إلغاء الموعد بواسطة الطبيب.')));
                          } else {
                            if (!context.mounted) return;
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
                if (consultation.endTime != null) Text('نهاية الاستشارة: ${DateFormat('yyyy-MM-dd HH:mm').format(consultation.endTime!)}'),
                if (consultation.status == 'active')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // <<< تحديث زر الدردشة هنا >>>
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (ctx) => ChatScreen(consultation: consultation),
                            ),
                          );
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
                          if (!context.mounted) return;
                          bool success = await Provider.of<DoctorProvider>(context, listen: false).closeConsultation(consultation.id);
                          if (success) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إغلاق الاستشارة.')));
                          } else {
                            if (!context.mounted) return;
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
                            Text('تاريخ النشر: ${post.published_at != null ? DateFormat('yyyy-MM-dd').format(post.published_at!) : 'غير منشور'}'),
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
                                    // التحقق من context.mounted قبل استخدام Provider
                                    if (!context.mounted) return;
                                    bool success = await Provider.of<DoctorProvider>(context, listen: false).deleteBlogPost(post.id);
                                    if (success) {
                                      if (!context.mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف المقال.')));
                                    } else {
                                      if (!context.mounted) return;
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

  @override
  void dispose() {
    _tabController.dispose();
    _answerController.dispose();
    _medicationDetailsController.dispose();
    _instructionsController.dispose();
    _blogPostTitleController.dispose();
    _blogPostContentController.dispose();
    _blogPostImageUrlController.dispose();
    _blogPostVideoUrlController.dispose();
    super.dispose();
  }
}