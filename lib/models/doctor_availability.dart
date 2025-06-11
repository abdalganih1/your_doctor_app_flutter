import 'dart:convert';

class DoctorAvailability {
  final int id;
  final int doctorId;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final bool isAvailable;

  DoctorAvailability({
    required this.id,
    required this.doctorId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
  });

factory DoctorAvailability.fromMap(Map<String, dynamic> map) {
  return DoctorAvailability(
    id: map['availability_id'] as int,
    doctorId: map['doctor_id'] as int,
    dayOfWeek: map['day_of_week'] as int,
    startTime: map['start_time'] as String,
    endTime: map['end_time'] as String,
    isAvailable: map['is_available'] as bool,
  );
}


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctorId': doctorId,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'isAvailable': isAvailable,
    };
  }

  String toJson() => json.encode(toMap());
  factory DoctorAvailability.fromJson(String source) => DoctorAvailability.fromMap(json.decode(source) as Map<String, dynamic>);
}
