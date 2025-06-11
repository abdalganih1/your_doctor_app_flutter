import 'dart:convert';
import 'user.dart';
// import 'consultation.dart'; // Simple version to break circular dependency

class Prescription {
  final int id;
  final int consultationId;
  final int patientUserId;
  final int doctorUserId;
  final String medicationDetails;
  final String? instructions;
  final DateTime issueDate;
  final DateTime created_at;
  final DateTime updated_at;
  final User? patient;
  final User? doctor;

  Prescription({
    required this.id,
    required this.consultationId,
    required this.patientUserId,
    required this.doctorUserId,
    required this.medicationDetails,
    this.instructions,
    required this.issueDate,
    required this.created_at,
    required this.updated_at,
    this.patient,
    this.doctor,
  });

factory Prescription.fromMap(Map<String, dynamic> map) {
  return Prescription(
    id: map['prescription_id'] as int,
    consultationId: map['consultation_id'] as int,
    patientUserId: map['patient_user_id'] as int,
    doctorUserId: map['doctor_user_id'] as int,
    medicationDetails: map['medication_details'] as String,
    instructions: map['instructions'] as String?,
    issueDate: DateTime.parse(map['issue_date'] as String),
    created_at: DateTime.parse(map['created_at'] as String),
    updated_at: DateTime.parse(map['updated_at'] as String),
    patient: map['patient'] != null
        ? User.fromMap(map['patient'] as Map<String, dynamic>)
        : null,
    doctor: map['doctor'] != null
        ? User.fromMap(map['doctor'] as Map<String, dynamic>)
        : null,
  );
}


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'consultationId': consultationId,
      'patientUserId': patientUserId,
      'doctorUserId': doctorUserId,
      'medicationDetails': medicationDetails,
      'instructions': instructions,
      'issueDate': issueDate.toIso8601String().split('T')[0], // Only date
      'created_at': created_at.toIso8601String(),
      'updated_at': updated_at.toIso8601String(),
      'patient': patient?.toMap(),
      'doctor': doctor?.toMap(),
    };
  }

  String toJson() => json.encode(toMap());
  factory Prescription.fromJson(String source) =>
      Prescription.fromMap(json.decode(source) as Map<String, dynamic>);
}
