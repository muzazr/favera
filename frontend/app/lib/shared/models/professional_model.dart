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

  const Professional({
    required this.id,
    required this.name,
    required this.category,
    required this.specialization,
    required this.city,
    this.externalUrl,
    this.rating = 4.8,
    this.isVerified = true,
  });

  factory Professional.fromJson(Map<String, dynamic> json) {
    return Professional(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      specialization: json['specialization'] as String,
      city: json['city'] as String,
      externalUrl: json['external_url'] as String?,
      rating: (json['rating'] as num? ?? 4.8).toDouble(),
      isVerified: json['is_verified'] as bool? ?? true,
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
    };
  }
}
