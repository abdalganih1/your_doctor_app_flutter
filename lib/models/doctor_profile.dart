import 'dart:convert';
import 'specialization.dart';
import 'user.dart';

class DoctorProfile {
  final int id;
  final int userId;
  final int specializationId; // هذا الحقل يجب أن يكون موجوداً دائماً حسب ERD
  final String bio;
  final int? yearsExperience; // >>> تغيير: قد يكون null <<<
  final double? consultationFee; // >>> تغيير: قد يكون null <<<
  final String profilePictureUrl;
  final Specialization? specialization;
  final User? user;

  DoctorProfile({
    required this.id,
    required this.userId,
    required this.specializationId,
    required this.bio,
    this.yearsExperience, // >>> تغيير: لا تتطلب required <<<
    this.consultationFee, // >>> تغيير: لا تتطلب required <<<
    required this.profilePictureUrl,
    this.specialization,
    this.user,
  });

  factory DoctorProfile.fromMap(Map<String, dynamic> map) {

    return DoctorProfile(
      id: map['doctor_id'] as int,
      userId: map['user_id'] as int,
      specializationId: map['specialization_id'] as int,
      bio: map['bio'] as String,
      yearsExperience: map['years_experience'] as int?, // >>> تغيير: Cast as int? <<<
      consultationFee: map['consultation_fee'] != null
          ? double.tryParse(map['consultation_fee'].toString())
          : null,
          profilePictureUrl: map['profile_picture_url'] as String,
      specialization: map['specialization'] != null
          ? Specialization.fromMap(map['specialization'] as Map<String, dynamic>)
          : null,
      user: map['user'] != null
          ? User.fromMap(map['user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'specializationId': specializationId,
      'bio': bio,
      'yearsExperience': yearsExperience,
      'consultationFee': consultationFee,
      'profilePictureUrl': profilePictureUrl,
      'specialization': specialization?.toMap(),
      'user': user?.toMap(),
    };
  }

  String toJson() => json.encode(toMap());
  factory DoctorProfile.fromJson(String source) => DoctorProfile.fromMap(json.decode(source) as Map<String, dynamic>);
}