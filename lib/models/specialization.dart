import 'dart:convert';

class Specialization {
  final int id;
  final String nameAr;
  final String? nameEn;
  final String? description;
  final String? iconUrl;

  Specialization({
    required this.id,
    required this.nameAr,
    this.nameEn,
    this.description,
    this.iconUrl,
  });

  factory Specialization.fromMap(Map<String, dynamic> map) {
    return Specialization(
      id: map['specialization_id'] as int,
      nameAr: map['name_ar'] as String,
      nameEn: map['name_en'] as String?,
      description: map['description'] as String?,
      iconUrl: map['icon_url'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'description': description,
      'iconUrl': iconUrl,
    };
  }

  String toJson() => json.encode(toMap());
  factory Specialization.fromJson(String source) => Specialization.fromMap(json.decode(source) as Map<String, dynamic>);
}
