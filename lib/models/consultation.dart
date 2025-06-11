import 'dart:convert';
import 'user.dart';
import 'message.dart';
import 'prescription.dart';
import 'payment.dart'; // Simple version to break circular dependency

// Simple version used in circular references in other models
class ConsultationSimple {
  final int id;
  final int patientUserId;
  final int doctorUserId;
  final DateTime startTime;
  final DateTime? endTime;
  final String status;
  final int? paymentId;
  final DateTime created_at;
  final DateTime updated_at;

  ConsultationSimple({
    required this.id,
    required this.patientUserId,
    required this.doctorUserId,
    required this.startTime,
    this.endTime,
    required this.status,
    this.paymentId,
    required this.created_at,
    required this.updated_at,
  });

  factory ConsultationSimple.fromMap(Map<String, dynamic> map) {
  return ConsultationSimple(
    id: map['consultation_id'] as int,
    patientUserId: map['patient_user_id'] as int,
    doctorUserId: map['doctor_user_id'] as int,
    startTime: DateTime.parse(map['start_time'] as String),
    endTime: map['end_time'] != null
        ? DateTime.parse(map['end_time'] as String)
        : null,
    status: map['status'] as String,
    paymentId: map['payment_id'] as int?,
    created_at: DateTime.parse(map['created_at'] as String),
    updated_at: DateTime.parse(map['updated_at'] as String),
  );
}


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientUserId': patientUserId,
      'doctorUserId': doctorUserId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'status': status,
      'paymentId': paymentId,
      'created_at': created_at.toIso8601String(),
      'updated_at': updated_at.toIso8601String(),
    };
  }
}

// Full version of Consultation resource
class Consultation extends ConsultationSimple {
  final User? patient;
  final User? doctor; // This doctor is a User model
  final List<Message> messages;
  final List<Prescription> prescriptions;
  final PaymentSimple? payment;

  Consultation({
    required super.id,
    required super.patientUserId,
    required super.doctorUserId,
    required super.startTime,
    super.endTime,
    required super.status,
    super.paymentId,
    required super.created_at,
    required super.updated_at,
    this.patient,
    this.doctor,
    required this.messages,
    required this.prescriptions,
    this.payment,
  });

factory Consultation.fromMap(Map<String, dynamic> map) {
  return Consultation(
    id: map['consultation_id'] as int,
    patientUserId: map['patient_user_id'] as int,
    doctorUserId: map['doctor_user_id'] as int,
    startTime: DateTime.parse(map['start_time'] as String),
    endTime: map['end_time'] != null
        ? DateTime.parse(map['end_time'] as String)
        : null,
    status: map['status'] as String,
    paymentId: map['payment_id'] as int?,
    created_at: DateTime.parse(map['created_at'] as String),
    updated_at: DateTime.parse(map['updated_at'] as String),
    patient: map['patient'] != null
        ? User.fromMap(map['patient'] as Map<String, dynamic>)
        : null,
    doctor: map['doctor'] != null
        ? User.fromMap(map['doctor'] as Map<String, dynamic>)
        : null,
    messages: (map['messages'] as List<dynamic>?)
            ?.map((e) => Message.fromMap(e as Map<String, dynamic>))
            .toList() ??
        [],
    prescriptions: (map['prescriptions'] as List<dynamic>?)
            ?.map((e) => Prescription.fromMap(e as Map<String, dynamic>))
            .toList() ??
        [],
    payment: map['payment'] != null
        ? PaymentSimple.fromMap(map['payment'] as Map<String, dynamic>)
        : null,
  );
}


  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = super.toMap();
    data['patient'] = patient?.toMap();
    data['doctor'] = doctor?.toMap();
    data['messages'] = messages.map((e) => e.toMap()).toList();
    data['prescriptions'] = prescriptions.map((e) => e.toMap()).toList();
    data['payment'] = payment?.toMap();
    return data;
  }

  String toJson() => json.encode(toMap());
  factory Consultation.fromJson(String source) =>
      Consultation.fromMap(json.decode(source) as Map<String, dynamic>);
}
