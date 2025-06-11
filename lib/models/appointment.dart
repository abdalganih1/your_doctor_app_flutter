import 'dart:convert';
import 'user.dart';
import 'doctor_profile.dart';
import 'payment.dart'; // Simple version to break circular dependency

// Simple version used in circular references in other models
class AppointmentSimple {
  final int id;
  final int patientUserId;
  final int doctorId;
  final DateTime appointmentDatetime;
  final int durationMinutes;
  final String status;
  final String? patientNotes;
  final String? doctorNotes;
  final int? paymentId;
  final DateTime created_at;
  final DateTime updated_at;

  AppointmentSimple({
    required this.id,
    required this.patientUserId,
    required this.doctorId,
    required this.appointmentDatetime,
    required this.durationMinutes,
    required this.status,
    this.patientNotes,
    this.doctorNotes,
    this.paymentId,
    required this.created_at,
    required this.updated_at,
  });

  factory AppointmentSimple.fromMap(Map<String, dynamic> map) {
    return AppointmentSimple(
      id: map['appointment_id'] as int,
      patientUserId: map['patient_user_id'] as int,
      doctorId: map['doctor_id'] as int,
      appointmentDatetime: DateTime.parse(map['appointment_datetime'] as String),
      durationMinutes: map['duration_minutes'] as int,
      status: map['status'] as String,
      patientNotes: map['patient_notes'] as String?,
      doctorNotes: map['doctor_notes'] as String?,
      paymentId: map['payment_id'] as int?,
      created_at: DateTime.parse(map['created_at'] as String),
      updated_at: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientUserId': patientUserId,
      'doctorId': doctorId,
      'appointmentDatetime': appointmentDatetime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'status': status,
      'patientNotes': patientNotes,
      'doctorNotes': doctorNotes,
      'paymentId': paymentId,
      'created_at': created_at.toIso8601String(),
      'updated_at': updated_at.toIso8601String(),
    };
  }
}

// Full version of Appointment resource
class Appointment extends AppointmentSimple {
  final User? patient;
  final DoctorProfile? doctor;
  final PaymentSimple? payment;

  Appointment({
    required super.id,
    required super.patientUserId,
    required super.doctorId,
    required super.appointmentDatetime,
    required super.durationMinutes,
    required super.status,
    super.patientNotes,
    super.doctorNotes,
    super.paymentId,
    required super.created_at,
    required super.updated_at,
    this.patient,
    this.doctor,
    this.payment,
  });

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['appointment_id'] as int,
      patientUserId: map['patient_user_id'] as int,
      doctorId: map['doctor_id'] as int,
      appointmentDatetime: DateTime.parse(map['appointment_datetime'] as String),
      durationMinutes: map['duration_minutes'] as int,
      status: map['status'] as String,
      patientNotes: map['patient_notes'] as String?,
      doctorNotes: map['doctor_notes'] as String?,
      paymentId: map['payment_id'] as int?,
      created_at: DateTime.parse(map['created_at'] as String),
      updated_at: DateTime.parse(map['updated_at'] as String),
      patient: map['patient'] != null
          ? User.fromMap(map['patient'] as Map<String, dynamic>)
          : null,
      doctor: map['doctor'] != null
          ? DoctorProfile.fromMap(map['doctor'] as Map<String, dynamic>)
          : null,
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
    data['payment'] = payment?.toMap();
    return data;
  }

  String toJson() => json.encode(toMap());
  factory Appointment.fromJson(String source) =>
      Appointment.fromMap(json.decode(source) as Map<String, dynamic>);
}
