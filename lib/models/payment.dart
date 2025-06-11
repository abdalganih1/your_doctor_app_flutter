import 'dart:convert';
import 'user.dart';
import 'consultation.dart'; // Simple version to break circular dependency
import 'appointment.dart'; // Simple version to break circular dependency

// Simple version used in circular references in other models
class PaymentSimple {
  final int id;
  final int userId;
  final double amount;
  final String currency;
  final String paymentMethod;
  final String? transactionReference;
  final String status;
  final String purpose;
  final int? consultationId;
  final int? appointmentId;
  final DateTime? paymentDate;
  final DateTime created_at;
  final DateTime updated_at;

  PaymentSimple({
    required this.id,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    this.transactionReference,
    required this.status,
    required this.purpose,
    this.consultationId,
    this.appointmentId,
    this.paymentDate,
    required this.created_at,
    required this.updated_at,
  });

  factory PaymentSimple.fromMap(Map<String, dynamic> map) {
    return PaymentSimple(
      id: map['id'] as int,
      userId: map['userId'] as int,
      amount: (map['amount'] as num).toDouble(),
      currency: map['currency'] as String,
      paymentMethod: map['paymentMethod'] as String,
      transactionReference: map['transactionReference'] as String?,
      status: map['status'] as String,
      purpose: map['purpose'] as String,
      consultationId: map['consultationId'] as int?,
      appointmentId: map['appointmentId'] as int?,
      paymentDate: map['paymentDate'] != null
          ? DateTime.parse(map['paymentDate'] as String)
          : null,
      created_at: DateTime.parse(map['created_at'] as String),
      updated_at: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'currency': currency,
      'paymentMethod': paymentMethod,
      'transactionReference': transactionReference,
      'status': status,
      'purpose': purpose,
      'consultationId': consultationId,
      'appointmentId': appointmentId,
      'paymentDate': paymentDate?.toIso8601String(),
      'created_at': created_at.toIso8601String(),
      'updated_at': updated_at.toIso8601String(),
    };
  }
}

// Full version of Payment resource
class Payment extends PaymentSimple {
  final User? user;
  final ConsultationSimple? consultation;
  final AppointmentSimple? appointment;

  Payment({
    required super.id,
    required super.userId,
    required super.amount,
    required super.currency,
    required super.paymentMethod,
    super.transactionReference,
    required super.status,
    required super.purpose,
    super.consultationId,
    super.appointmentId,
    super.paymentDate,
    required super.created_at,
    required super.updated_at,
    this.user,
    this.consultation,
    this.appointment,
  });

factory Payment.fromMap(Map<String, dynamic> map) {
  return Payment(
    id: map['payment_id'] as int,
    userId: map['user_id'] as int,
    amount: (map['amount'] as num).toDouble(),
    currency: map['currency'] as String,
    paymentMethod: map['payment_method'] as String,
    transactionReference: map['transaction_reference'] as String?,
    status: map['status'] as String,
    purpose: map['purpose'] as String,
    consultationId: map['consultation_id'] as int?,
    appointmentId: map['appointment_id'] as int?,
    paymentDate: map['payment_date'] != null
        ? DateTime.parse(map['payment_date'] as String)
        : null,
    created_at: DateTime.parse(map['created_at'] as String),
    updated_at: DateTime.parse(map['updated_at'] as String),
    user: map['user'] != null
        ? User.fromMap(map['user'] as Map<String, dynamic>)
        : null,
    consultation: map['consultation'] != null
        ? ConsultationSimple.fromMap(
            map['consultation'] as Map<String, dynamic>)
        : null,
    appointment: map['appointment'] != null
        ? AppointmentSimple.fromMap(
            map['appointment'] as Map<String, dynamic>)
        : null,
  );
}


  @override
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = super.toMap();
    data['user'] = user?.toMap();
    data['consultation'] = consultation?.toMap();
    data['appointment'] = appointment?.toMap();
    return data;
  }

  String toJson() => json.encode(toMap());
  factory Payment.fromJson(String source) =>
      Payment.fromMap(json.decode(source) as Map<String, dynamic>);
}
