class Professional {
  final String id;
  final String name;
  final String
      category; // 'psikolog', 'konselor_finansial', 'mediator', 'layanan_darurat'
  final String specialization;
  final String city;
  final String? externalUrl;
  final double rating;
  final bool isVerified;
  final int experienceYears;
  final String schedule;
  final String? bio;
  final String? whatsappUrl;
  final String? instagramUrl;

  const Professional({
    required this.id,
    required this.name,
    required this.category,
    required this.specialization,
    required this.city,
    this.externalUrl,
    this.rating = 4.9,
    this.isVerified = true,
    this.experienceYears = 8,
    this.schedule = 'Senin - Jumat (10:00 - 16:00)',
    this.bio,
    this.whatsappUrl,
    this.instagramUrl,
  });

  factory Professional.fromJson(Map<String, dynamic> json) {
    return Professional(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      specialization: json['specialization'] as String,
      city: json['city'] as String,
      externalUrl: json['external_url'] as String?,
      rating: (json['rating'] as num? ?? 4.9).toDouble(),
      isVerified: json['is_verified'] as bool? ?? true,
      experienceYears: (json['experience_years'] as num? ?? 8).toInt(),
      schedule: json['schedule'] as String? ?? 'Senin - Jumat (10:00 - 16:00)',
      bio: json['bio'] as String?,
      whatsappUrl: json['whatsapp_url'] as String?,
      instagramUrl: json['instagram_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'specialization': specialization,
      'city': city,
      'external_url': externalUrl,
      'rating': rating,
      'is_verified': isVerified,
      'experience_years': experienceYears,
      'schedule': schedule,
      'bio': bio,
      'whatsapp_url': whatsappUrl,
      'instagram_url': instagramUrl,
    };
  }
}
