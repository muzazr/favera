class User {
  final String id;
  final String email;
  final String name;
  final bool onboardingCompleted;
  final String? avatarUrl;
  final String? familyId;
  final String role;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.onboardingCompleted,
    this.avatarUrl,
    this.familyId,
    this.role = 'user',
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      name: (json['display_name'] as String?) ?? (json['name'] as String?) ?? '',
      onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
      avatarUrl: json['avatar_url'] as String?,
      familyId: json['family_id'] as String?,
      role: json['role'] as String? ?? 'user',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'display_name': name,
      'name': name,
      'onboarding_completed': onboardingCompleted,
      'avatar_url': avatarUrl,
      'family_id': familyId,
      'role': role,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? name,
    bool? onboardingCompleted,
    String? avatarUrl,
    String? familyId,
    String? role,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      familyId: familyId ?? this.familyId,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
