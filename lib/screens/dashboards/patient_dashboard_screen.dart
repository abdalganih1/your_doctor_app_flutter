import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_doctor_app_flutter/models/blog_post.dart';
import 'package:your_doctor_app_flutter/models/doctor_profile.dart'; // تأكد من استيراد DoctorProfile
import 'package:your_doctor_app_flutter/screens/chat_screen.dart';
import '../../providers/patient_provider.dart';
import '../../models/appointment.dart';
import '../../models/consultation.dart';
import '../../models/prescription.dart';
import '../../models/public_question.dart';
import '../../providers/general_data_provider.dart';
import 'package:intl/intl.dart';
import '../../config/config.dart';

class PatientDashboardScreen extends StatefulWidget {
  const PatientDashboardScreen({super.key});

  @override
  State<PatientDashboardScreen> createState() => _PatientDashboardScreenState();
}

class _PatientDashboardScreenState extends State<PatientDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _doctorSearchController = TextEditingController();
  final TextEditingController _newQuestionTitleController =
      TextEditingController();
  final TextEditingController _newQuestionDetailsController =
      TextEditingController();
  final TextEditingController _appointmentNotesController =
      TextEditingController();
  final TextEditingController _paymentAmountController =
      TextEditingController();
  final TextEditingController _paymentRefController = TextEditingController();
  final TextEditingController _paymentPurposeController =
      TextEditingController();

  int? _selectedDoctorForAppointment;
  DateTime? _selectedAppointmentDate;
  TimeOfDay? _selectedAppointmentTime;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPatientData();
    });
  }

  void _loadPatientData() {
    final patientProvider =
        Provider.of<PatientProvider>(context, listen: false);
    final generalProvider =
        Provider.of<GeneralDataProvider>(context, listen: false);

    patientProvider.fetchAppointments();
    patientProvider.fetchConsultations();
    patientProvider.fetchPrescriptions();
    patientProvider.fetchPublicQuestions();
    generalProvider.fetchDoctorsForPatientBooking();
    generalProvider.fetchBlogPosts();
    generalProvider.fetchAllSpecializations();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = _selectedAppointmentDate ?? now;
    final DateTime firstDate = now;
    final DateTime lastDate = DateTime(now.year + 10, now.month, now.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(firstDate) ? firstDate : initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
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
    final generalProvider =
        Provider.of<GeneralDataProvider>(context, listen: false);
    final List<DoctorProfile> doctors = generalProvider.allDoctors;

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
                  items: doctors
                      .map<DropdownMenuItem<int>>((doctor) {
                        return DropdownMenuItem<int>(
                          value: doctor.id,
                          child: Text(
                              'د. ${doctor.user?.name ?? 'غير معروف'} (${doctor.specialization?.nameAr ?? 'غير محدد'})'),
                        );
                      }).toList(),
                  onChanged: (int? newValue) {
                    _selectedDoctorForAppointment = newValue;
                  },
                ),
                ListTile(
                  title: Text(_selectedAppointmentDate == null
                      ? 'اختر التاريخ'
                      : DateFormat('yyyy-MM-dd')
                          .format(_selectedAppointmentDate!)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(dialogContext),
                ),
                ListTile(
                  title: Text(_selectedAppointmentTime == null
                      ? 'اختر الوقت'
                      : _selectedAppointmentTime!.format(dialogContext)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () => _selectTime(dialogContext),
                ),
                TextField(
                  controller: _appointmentNotesController,
                  decoration: const InputDecoration(
                      labelText: 'ملاحظات المريض (اختياري)'),
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
                if (_selectedDoctorForAppointment != null &&
                    _selectedAppointmentDate != null &&
                    _selectedAppointmentTime != null) {
                  final DateTime fullDateTime = DateTime(
                    _selectedAppointmentDate!.year,
                    _selectedAppointmentDate!.month,
                    _selectedAppointmentDate!.day,
                    _selectedAppointmentTime!.hour,
                    _selectedAppointmentTime!.minute,
                  );
                  if (!dialogContext.mounted) return;
                  bool success = await Provider.of<PatientProvider>(
                          dialogContext,
                          listen: false)
                      .bookAppointment(
                    _selectedDoctorForAppointment!,
                    fullDateTime,
                    30, // Default duration
                    _appointmentNotesController.text,
                  );
                  if (success) {
                    if (!dialogContext.mounted) return;
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم حجز الموعد بنجاح!')));
                  } else {
                    if (!dialogContext.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(Provider.of<PatientProvider>(
                                    dialogContext,
                                    listen: false)
                                .errorMessage ??
                            'فشل حجز الموعد.')));
                  }
                } else {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                          content: Text('الرجاء ملء جميع الحقول المطلوبة.')));
                }
              },
            ),
          ],
        );
      },
    );
  }

  // >>> دالة جديدة: عرض استشارة جديدة مع طبيب <<<
  void _showConsultationDialog(BuildContext context, DoctorProfile doctor) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('بدء استشارة مع د. ${doctor.user?.name ?? 'غير معروف'}'),
          content: const Text('هل أنت متأكد أنك تريد بدء استشارة جديدة مع هذا الطبيب؟'),
          actions: <Widget>[
            TextButton(
              child: const Text('إلغاء'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text('تأكيد البدء'),
              onPressed: () async {
                // تأكد أن user ID الطبيب ليس null قبل المتابعة
                if (doctor.user?.id == null) {
                  if (!dialogContext.mounted) return;
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(content: Text('معلومات الطبيب غير مكتملة. لا يمكن بدء الاستشارة.')));
                  return;
                }
                if (!dialogContext.mounted) return;
                bool success = await Provider.of<PatientProvider>(dialogContext, listen: false).requestConsultation(
                  doctor.user!.id, // نستخدم user ID للطبيب لطلب الاستشارة
                );
                if (success) {
                  if (!dialogContext.mounted) return;
                  Navigator.of(dialogContext).pop();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم طلب الاستشارة بنجاح!')));
                } else {
                  if (!dialogContext.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(Provider.of<PatientProvider>(dialogContext, listen: false).errorMessage ?? 'فشل طلب الاستشارة.')));
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
        return StatefulBuilder(
          builder: (context, setStateInDialog) {
            final patientProvider =
                Provider.of<PatientProvider>(context, listen: false);
            final consultations = patientProvider.consultations?.data ?? [];
            final appointments = patientProvider.appointments?.data ?? [];

            final List<DropdownMenuItem<int>> consultationItems =
                consultations.map((consultation) {
              return DropdownMenuItem<int>(
                value: consultation.id,
                child: Text(
                    'استشارة مع د. ${consultation.doctor?.name ?? 'غير معروف'} (${consultation.id})'),
              );
            }).toList();

            final List<DropdownMenuItem<int>> appointmentItems =
                appointments.map((appointment) {
              return DropdownMenuItem<int>(
                value: appointment.id,
                child: Text(
                    'موعد مع د. ${appointment.doctor?.user?.name ?? 'غير معروف'} (${appointment.id})'),
              );
            }).toList();

            if (consultationItems.isNotEmpty &&
                selectedConsultationId == null &&
                _paymentPurposeController.text == 'consultation') {
              selectedConsultationId = consultationItems.first.value;
            } else if (appointmentItems.isNotEmpty &&
                selectedAppointmentId == null &&
                _paymentPurposeController.text == 'appointment_booking') {
              selectedAppointmentId = appointmentItems.first.value;
            }

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
                      decoration: const InputDecoration(
                          labelText: 'رقم مرجع الحوالة (اختياري)'),
                    ),
                    DropdownButtonFormField<String>(
                      value: _paymentPurposeController.text.isEmpty
                          ? null
                          : _paymentPurposeController.text,
                      decoration: const InputDecoration(labelText: 'الغرض'),
                      items: const [
                        DropdownMenuItem(
                            value: 'consultation', child: Text('استشارة')),
                        DropdownMenuItem(
                            value: 'appointment_booking',
                            child: Text('حجز موعد')),
                      ],
                      onChanged: (value) {
                        setStateInDialog(() {
                          _paymentPurposeController.text = value!;
                          selectedConsultationId = null;
                          selectedAppointmentId = null;
                          if (_paymentPurposeController.text ==
                                  'consultation' &&
                              consultationItems.isNotEmpty) {
                            selectedConsultationId =
                                consultationItems.first.value;
                          } else if (_paymentPurposeController.text ==
                                  'appointment_booking' &&
                              appointmentItems.isNotEmpty) {
                            selectedAppointmentId =
                                appointmentItems.first.value;
                          }
                        });
                      },
                    ),
                    if (_paymentPurposeController.text == 'consultation')
                      DropdownButtonFormField<int>(
                        decoration:
                            const InputDecoration(labelText: 'اختر استشارة'),
                        value: selectedConsultationId,
                        items: consultationItems,
                        onChanged: (newValue) {
                          setStateInDialog(() {
                            selectedConsultationId = newValue;
                          });
                        },
                        hint: consultationItems.isEmpty
                            ? const Text('لا توجد استشارات متاحة')
                            : null,
                        isExpanded: true,
                      ),
                    if (_paymentPurposeController.text == 'appointment_booking')
                      DropdownButtonFormField<int>(
                        decoration:
                            const InputDecoration(labelText: 'اختر موعد'),
                        value: selectedAppointmentId,
                        items: appointmentItems,
                        onChanged: (newValue) {
                          setStateInDialog(() {
                            selectedAppointmentId = newValue;
                          });
                        },
                        hint: appointmentItems.isEmpty
                            ? const Text('لا توجد مواعيد متاحة')
                            : null,
                        isExpanded: true,
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
                    if (_paymentAmountController.text.isEmpty ||
                        _paymentPurposeController.text.isEmpty) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('الرجاء ملء جميع الحقول المطلوبة.')));
                      return;
                    }

                    Map<String, dynamic> paymentData = {
                      'amount': double.parse(_paymentAmountController.text),
                      'currency': AppConfig.defaultCurrency,
                      'payment_method': 'bank_transfer',
                      'purpose': _paymentPurposeController.text,
                      'transaction_reference':
                          _paymentRefController.text.isNotEmpty
                              ? _paymentRefController.text
                              : null,
                    };

                    if (_paymentPurposeController.text == 'consultation' &&
                        selectedConsultationId != null) {
                      paymentData['consultation_id'] = selectedConsultationId;
                    } else if (_paymentPurposeController.text ==
                            'appointment_booking' &&
                        selectedAppointmentId != null) {
                      paymentData['appointment_id'] = selectedAppointmentId;
                    } else {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('الرجاء ربط الدفعة باستشارة أو موعد.')));
                      return;
                    }

                    if (!dialogContext.mounted) return;
                    bool success =
                        await patientProvider.initiatePayment(paymentData);
                    if (success) {
                      if (!dialogContext.mounted) return;
                      Navigator.of(dialogContext).pop();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('تم تسجيل طلب الدفع بنجاح!')));
                    } else {
                      if (!dialogContext.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(patientProvider.errorMessage ??
                              'فشل بدء عملية الدفع.')));
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
              patientProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildAppointmentsList(
                      patientProvider.appointments?.data ?? []),
              patientProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildConsultationsList(
                      patientProvider.consultations?.data ?? []),
              patientProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildPrescriptionsList(
                      patientProvider.prescriptions?.data ?? []),
              patientProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildPublicQuestionsList(
                      patientProvider.publicQuestions?.data ?? []),
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
                              decoration: const InputDecoration(
                                  labelText: 'عنوان السؤال'),
                            ),
                            TextField(
                              controller: _newQuestionDetailsController,
                              decoration: const InputDecoration(
                                  labelText: 'تفاصيل الأعراض'),
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
                              if (!dialogContext.mounted) return;
                              bool success =
                                  await patientProvider.postPublicQuestion(
                                _newQuestionTitleController.text,
                                _newQuestionDetailsController.text,
                              );
                              if (success) {
                                if (!dialogContext.mounted) return;
                                Navigator.of(dialogContext).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('تم طرح السؤال بنجاح!')));
                              } else {
                                if (!dialogContext.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            patientProvider.errorMessage ??
                                                'فشل طرح السؤال.')));
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
                Text(
                    'موعد مع د. ${appointment.doctor?.user?.name ?? 'غير معروف'}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                    'الاختصاص: ${appointment.doctor?.specialization?.nameAr ?? 'غير محدد'}'),
                Text(
                    'التاريخ والوقت: ${DateFormat('yyyy-MM-dd HH:mm').format(appointment.appointmentDatetime)}'),
                Text('الحالة: ${appointment.status}'),
                Text('ملاحظاتي: ${appointment.patientNotes ?? 'لا توجد'}'),
                if (appointment.status == 'scheduled')
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!context.mounted) return;
                        bool success = await Provider.of<PatientProvider>(
                                context,
                                listen: false)
                            .cancelAppointment(appointment.id);
                        if (success) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('تم إلغاء الموعد.')));
                        } else {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(Provider.of<PatientProvider>(
                                          context,
                                          listen: false)
                                      .errorMessage ??
                                  'فشل الإلغاء.')));
                        }
                      },
                      child: const Text('إلغاء الموعد'),
                    ),
                  ),
                // إضافة زر "بدء استشارة" بعد اكتمال الموعد (اختياري)
                if (appointment.status == 'completed' && appointment.doctor?.user != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: () => _showConsultationDialog(context, appointment.doctor!), // استخدام user ID للطبيب
                      child: const Text('بدء استشارة جديدة مع هذا الطبيب'),
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
                Text(
                    'استشارة مع د. ${consultation.doctor?.name ?? 'غير معروف'}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                    'بداية الاستشارة: ${DateFormat('yyyy-MM-dd HH:mm').format(consultation.startTime)}'),
                Text('الحالة: ${consultation.status}'),
                if (consultation.endTime != null)
                  Text(
                      'نهاية الاستشارة: ${DateFormat('yyyy-MM-dd HH:mm').format(consultation.endTime!)}'),
                // >>> إضافة زر الدردشة هنا <<<
                if (consultation.status == 'active')
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => ChatScreen(consultation: consultation),
                          ),
                        );
                      },
                      child: const Text('بدء الدردشة'),
                    ),
                  ),
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
                Text('وصفة من د. ${prescription.doctor?.name ?? 'غير معروف'}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                    'تاريخ الإصدار: ${DateFormat('yyyy-MM-dd').format(prescription.issueDate)}'),
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
                Text('سؤالي: ${question.title}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('التفاصيل: ${question.details}'),
                Text(
                    'تاريخ الطرح: ${DateFormat('yyyy-MM-dd HH:mm').format(question.created_at)}'),
                const Text('الإجابات:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                if (question.answers.isEmpty)
                  const Text('  لا توجد إجابات بعد.')
                else
                  ...question.answers.map((answer) => Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                        child: Text(
                            '  ${answer.author?.name ?? 'غير معروف'}: ${answer.answerText}'),
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
                Text('العنوان: ${post.title}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                    'الكاتب: د. ${post.authorDoctor?.user?.name ?? 'غير معروف'}'),
                Text(
                    'تاريخ النشر: ${post.published_at != null ? DateFormat('yyyy-MM-dd').format(post.published_at!) : 'غير منشور'}'),
                Text(
                    'المحتوى (مختصر): ${post.content.length > 100 ? '${post.content.substring(0, 100)}...' : post.content}'),
                // You might add a button to view full post details or comments
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _doctorSearchController.dispose();
    _newQuestionTitleController.dispose();
    _newQuestionDetailsController.dispose();
    _appointmentNotesController.dispose();
    _paymentAmountController.dispose();
    _paymentRefController.dispose();
    _paymentPurposeController.dispose();
    super.dispose();
  }
}