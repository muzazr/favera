class Professional {
  final String id;
  final String name;
  final String
      category; // 'psikolog', 'konselor_finansial', 'mediator', 'layanan_darurat'
  final String specialization;
  final String city;
  final String? externalUrl;
  final double rating;
  final int reviewsCount;
  final bool isVerified;
  final int experienceYears;
  final String schedule;
  final String? bio;
  final String? whatsappUrl;
  final String? instagramUrl;
  final List<String> specialties;
  final List<String> therapyApproaches;
  final String education;
  final String certification;

  const Professional({
    required this.id,
    required this.name,
    required this.category,
    required this.specialization,
    required this.city,
    this.externalUrl,
    this.rating = 4.9,
    this.reviewsCount = 120,
    this.isVerified = true,
    this.experienceYears = 8,
    this.schedule = 'Selasa - Sabtu (09:00 - 15:00)',
    this.bio,
    this.whatsappUrl,
    this.instagramUrl,
    this.specialties = const ['Manajemen Utang', 'Komunikasi Finansial'],
    this.therapyApproaches = const [
      'Cognitive Behavioral Therapy (CBT)',
      'Mediasi Finansial Netral',
    ],
    this.education = 'Universitas Indonesia (Magister Profesi Psikolog Klinis)',
    this.certification = 'Financial Behavior Specialist (FBS®)',
  });

  factory Professional.fromJson(Map<String, dynamic> json) {
    return Professional(
      id: json['id'] as String? ?? 'prof-${DateTime.now().millisecondsSinceEpoch}',
      name: json['name'] as String? ?? json['full_name'] as String? ?? 'Konselor Profesional',
      category: json['category'] as String? ?? json['type'] as String? ?? 'psikolog',
      specialization: json['specialization'] as String? ??
          json['title'] as String? ??
          'Psikolog & Konselor Pernikahan',
      city: json['city'] as String? ?? json['location'] as String? ?? 'Jakarta',
      externalUrl: json['external_url'] as String? ?? json['url'] as String?,
      rating: (json['rating'] as num? ?? 4.9).toDouble(),
      reviewsCount: (json['reviews_count'] as num? ?? json['review_count'] as num? ?? 120).toInt(),
      isVerified: json['is_verified'] as bool? ?? true,
      experienceYears: (json['experience_years'] as num? ?? json['experience'] as num? ?? 8).toInt(),
      schedule: json['schedule'] as String? ?? json['work_hours'] as String? ?? 'Selasa - Sabtu (09:00 - 15:00)',
      bio: json['bio'] as String? ?? json['description'] as String?,
      whatsappUrl: json['whatsapp_url'] as String? ?? json['whatsapp'] as String? ?? json['phone_number'] as String?,
      instagramUrl: json['instagram_url'] as String? ?? json['instagram'] as String?,
      specialties: (json['specialties'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['Manajemen Utang', 'Komunikasi Finansial'],
      therapyApproaches: (json['therapy_approaches'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [
            'Cognitive Behavioral Therapy (CBT)',
            'Mediasi Finansial Netral',
          ],
      education: json['education'] as String? ??
          'Universitas Indonesia (Magister Profesi Psikolog Klinis)',
      certification: json['certification'] as String? ??
          'Financial Behavior Specialist (FBS®)',
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
      'reviews_count': reviewsCount,
      'is_verified': isVerified,
      'experience_years': experienceYears,
      'schedule': schedule,
      'bio': bio,
      'whatsapp_url': whatsappUrl,
      'instagram_url': instagramUrl,
      'specialties': specialties,
      'therapy_approaches': therapyApproaches,
      'education': education,
      'certification': certification,
    };
  }
}
